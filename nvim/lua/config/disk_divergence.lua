-- Divergence between a buffer's text and the file backing it on disk.
--
-- Algebraic shape:
--   State     = Synced | Stale | Conflict | Vanished | Reloaded Time
--   classify  : FileChangedReason -> State
--   observe   : (Buffer, State) -> ()          -- writes b:disk_divergence
--   decay     : (State, Now) -> State          -- Reloaded t ⟶ Synced once t is old
--   render    : State -> (Text, HighlightGroup)
--
--   state(buf) = decay(observe⁻¹(buf), now)
--
-- Plain English: Neovim already notices when a file changes underneath an
-- open buffer -- that is the FileChangedShell family of events, driven by
-- :checktime. What it does *not* do is leave a lasting mark. With the
-- default 'autoread' on, a clean buffer is silently replaced with the new
-- disk contents and you never learn it happened; with 'autoread' off you
-- get a modal prompt that interrupts whatever you were doing. This module
-- keeps a small per-buffer state variable instead, so the fact "the file
-- moved out from under me" becomes something a statusline can show.
--
-- The five states, and how you reach each one:
--
--   Synced    buffer text is the file text. Nothing rendered.
--   Reloaded  disk changed while the buffer was clean, and 'autoread'
--             pulled the new text in. Your view just changed under you --
--             worth knowing, not worth acting on. Fades after a while.
--             This is the `cargo add clap` case.
--   Conflict  disk changed AND you have unsaved edits. The dangerous one:
--             whichever side you save loses the other. Persists.
--   Stale     disk changed, buffer clean, but no reload happened (you have
--             'autoread' off, or only file attributes changed). Persists
--             until you :DiskReload or write.
--   Vanished  the file is gone or unreadable. Persists.
--
-- Why suppress the built-in prompt (v:fcs_choice = ""): the point is to
-- learn about the change by *glancing*, not by answering a dialog. The
-- write-side safety net is untouched -- :w on a file whose timestamp moved
-- still asks "The file has been changed since reading it!!! Do you really
-- want to write to it?" -- so a suppressed read-side prompt cannot cost
-- you someone else's edits.

local uv = vim.uv or vim.loop

local M = {}

-- State tags. Synced is represented by absence, so it has no tag.
local STALE    = "stale"
local CONFLICT = "conflict"
local VANISHED = "vanished"
local RELOADED = "reloaded"

local BUFFER_VAR = "disk_divergence"

local defaults = {
  -- How often to ask "did anything move?" (:checktime over all buffers).
  -- Neovim only volunteers this on focus changes and after shell commands,
  -- which is not enough when the writer is a build tool in another pane.
  -- Set to 0 to poll on events only.
  poll_interval_ms = 2000,

  -- Reloaded is news, not a problem, so it expires. Seconds.
  reloaded_decay_s = 12,

  -- Which transitions also deserve a message, for when the buffer is not
  -- visible in any window and therefore has no statusline to speak from.
  notify_on = {
    [CONFLICT] = true,
    [VANISHED] = true,
    [STALE]    = false,
    [RELOADED] = false,
  },

  -- Deliberately plain text, not nerd-font glyphs: the lualine setup runs
  -- with icons_enabled = false.
  symbols = {
    [CONFLICT] = "≠ DISK",
    [STALE]    = "↺ DISK",
    [VANISHED] = "✗ DISK",
    [RELOADED] = "↺ reloaded",
  },

  highlights = {
    [CONFLICT] = "DiagnosticError",
    [STALE]    = "DiagnosticWarn",
    [VANISHED] = "DiagnosticError",
    [RELOADED] = "DiagnosticHint",
  },
}

local config = vim.deepcopy(defaults)

-- v:fcs_reason ⟶ State. See :h v:fcs_reason.
local classify = {
  conflict = CONFLICT, -- file changed and buffer modified
  deleted  = VANISHED,
  changed  = STALE,    -- contents changed, buffer clean, no reload happened
  mode     = STALE,    -- permissions only
  time     = STALE,    -- timestamp only
}

--- A buffer whose divergence from disk is even a meaningful question:
--- backed by a real file, not a scratch/terminal/quickfix buffer.
local function tracks_a_file(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
      and vim.bo[bufnr].buftype == ""
      and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

-- Content identity, so that a tool which rewrites a file byte-identically
-- (or merely touches it) does not cry wolf. Neovim's own detection is
-- timestamp-and-size based, which `cargo build`, formatters and git
-- checkouts all trip without changing a single byte.
--
--   fingerprint : Text -> Digest
--   Two different questions are asked of it, because the two families of
--   state are asking different things:
--     Stale/Conflict -- is buffer text ≠ disk text *right now*?
--     Reloaded       -- is buffer text ≠ what it was last time I looked?
--   The second cannot be answered by comparing to disk: a reload has just
--   made the two identical by construction.

-- Above this many bytes, decline to hash and report the change unverified.
-- Precision is not worth stalling the UI over a huge log file.
local FINGERPRINT_BYTE_LIMIT = 5 * 1024 * 1024

-- bufnr -> Digest of the text the user last saw as agreeing with disk.
--
-- The baseline is captured at BufReadPre, i.e. *before* any read replaces
-- the buffer. That timing is the whole trick: an 'autoread' reload fires
-- BufReadPre -> (read) -> BufReadPost -> FileChangedShellPost, so by the
-- time we are asked "did anything actually change?", the pre-reload text
-- is the only copy of the old state left anywhere.
local baseline = {}

local function buffer_text(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
end

local function fingerprint(text)
  if #text > FINGERPRINT_BYTE_LIMIT then
    return nil
  end
  return vim.fn.sha256(text)
end

local function set_baseline(bufnr)
  if tracks_a_file(bufnr) then
    baseline[bufnr] = fingerprint(buffer_text(bufnr))
  end
end

--- Capture the outgoing text before a read overwrites it. Skipped for a
--- buffer that holds nothing yet, because that is the *initial* :edit of a
--- file rather than a reload -- there is no old state to preserve, and
--- recording "empty" would make the next external write look like a change
--- even if it was byte-identical.
local function set_baseline_before_read(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local empty = #lines == 0 or (#lines == 1 and lines[1] == "")
  if not empty then
    set_baseline(bufnr)
  end
end

--- Did the buffer's text actually change relative to the baseline? Answers
--- true when it cannot tell (nothing recorded, or file too large), so an
--- unverifiable change is still reported.
local function changed_from_baseline(bufnr)
  local previous = baseline[bufnr]
  local current = fingerprint(buffer_text(bufnr))
  baseline[bufnr] = current
  if previous == nil or current == nil then
    return true
  end
  return previous ~= current
end

--- Does the file on disk actually hold different text than the buffer?
--- Answers true when it cannot tell, which keeps the warning.
---
--- readfile() strips the line terminator, so this comparison is only
--- honest for unix fileformat; dos buffers keep a \r that the buffer lines
--- do not have, and we decline to guess rather than report a false match.
local function text_differs(bufnr)
  if vim.bo[bufnr].fileformat ~= "unix" then
    return true
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if vim.fn.filereadable(path) == 0 then
    return true
  end

  local ok, disk = pcall(vim.fn.readfile, path)
  if not ok or type(disk) ~= "table" then
    return true
  end

  local disk_print = fingerprint(table.concat(disk, "\n"))
  local buffer_print = fingerprint(buffer_text(bufnr))
  if disk_print == nil or buffer_print == nil then
    return true
  end
  return disk_print ~= buffer_print
end

local function raw_state(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr, BUFFER_VAR)
  if not ok or type(value) ~= "table" or value.kind == nil then
    return nil
  end
  return value
end

local function forget(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) and raw_state(bufnr) then
    pcall(vim.api.nvim_buf_del_var, bufnr, BUFFER_VAR)
  end
end

local function notify(bufnr, kind)
  if not config.notify_on[kind] then
    return
  end
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
  local message = ({
    [CONFLICT] = "changed on disk while you have unsaved edits",
    [STALE]    = "changed on disk (buffer not reloaded)",
    [VANISHED] = "is gone from disk",
  })[kind] or kind
  vim.notify(
    string.format("%s %s\n:DiskDiff to compare, :DiskReload to take disk's version", name, message),
    kind == STALE and vim.log.levels.WARN or vim.log.levels.ERROR,
    { title = "disk divergence" }
  )
end

--- observe: record a state on a buffer, notifying only on a real change of
--- state so that repeated polls stay quiet.
local function observe(bufnr, kind)
  if not tracks_a_file(bufnr) then
    return
  end

  if (kind == STALE or kind == CONFLICT) and not text_differs(bufnr) then
    forget(bufnr)
    return
  end

  local previous = raw_state(bufnr)
  vim.api.nvim_buf_set_var(bufnr, BUFFER_VAR, { kind = kind, at = os.time() })

  if not previous or previous.kind ~= kind then
    notify(bufnr, kind)
  end
end

--- state: the current State of a buffer, with Reloaded expired if it is
--- old enough. Returns nil for Synced.
function M.state(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local current = raw_state(bufnr)
  if not current then
    return nil
  end
  if current.kind == RELOADED
    and os.time() - (current.at or 0) > config.reloaded_decay_s then
    forget(bufnr)
    return nil
  end
  return current.kind
end

--- render: State -> Text. Empty string for Synced, which lualine hides.
function M.render(bufnr)
  local kind = M.state(bufnr)
  return kind and (config.symbols[kind] or kind) or ""
end

--- highlight: State -> HighlightGroup name.
function M.highlight(bufnr)
  local kind = M.state(bufnr)
  return kind and config.highlights[kind] or nil
end

--- A :checktime is a text-changing operation (autoread may swap the buffer
--- out from under the cursor), so refuse it in modes where that would be
--- disruptive or outright illegal.
local function safe_to_check()
  if vim.fn.getcmdwintype() ~= "" then
    return false
  end
  local mode = vim.api.nvim_get_mode().mode
  return not (mode:find("^i") or mode:find("^c") or mode:find("^t") or mode:find("^R"))
end

--- Ask Neovim to compare timestamps for every loaded buffer. Bare
--- :checktime covers hidden buffers too, so a file you are not looking at
--- is already marked by the time you switch to it.
function M.check()
  if not safe_to_check() then
    return
  end
  pcall(vim.cmd, "silent! checktime")
end

-- FileChangedShellPost fires after the whole FileChangedShell handling,
-- including the case we classified ourselves. This records which buffers
-- were already classified so Post does not relabel a Conflict as Reloaded.
local classified_this_tick = {}

local poll_timer = nil

local function start_polling()
  if poll_timer then
    poll_timer:stop()
    poll_timer:close()
    poll_timer = nil
  end
  if config.poll_interval_ms <= 0 then
    return
  end
  poll_timer = uv.new_timer()
  poll_timer:start(
    config.poll_interval_ms,
    config.poll_interval_ms,
    function() vim.schedule(M.check) end
  )
end

--- DiskDiff: the classic DiffOrig trick -- read the *disk* version of the
--- current file into a scratch buffer (":read ++edit #" re-reads the
--- alternate file, which is the buffer we came from) and diff the two.
--- This is the affordance the Conflict state needs: see what the tool did
--- before deciding which side wins.
local function open_disk_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  if not tracks_a_file(bufnr) then
    vim.notify("DiskDiff: buffer is not backed by a file", vim.log.levels.WARN)
    return
  end
  local filetype = vim.bo.filetype
  local label = "disk://" .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

  vim.cmd("vertical new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  pcall(vim.api.nvim_buf_set_name, 0, label)
  vim.cmd("silent read ++edit #")
  vim.cmd("silent 0d_")
  vim.bo.filetype = filetype
  vim.cmd("diffthis")
  vim.cmd("wincmd p")
  vim.cmd("diffthis")
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

  local group = vim.api.nvim_create_augroup("DiskDivergence", { clear = true })

  -- Disk changed and Neovim could not silently absorb it.
  vim.api.nvim_create_autocmd("FileChangedShell", {
    group = group,
    callback = function(args)
      local reason = vim.v.fcs_reason
      vim.v.fcs_choice = "" -- do nothing: the badge replaces the prompt
      classified_this_tick[args.buf] = true
      observe(args.buf, classify[reason] or STALE)
    end,
  })

  -- Disk changed and Neovim did absorb it ('autoread' reload).
  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group,
    callback = function(args)
      if classified_this_tick[args.buf] then
        classified_this_tick[args.buf] = nil
        return
      end
      -- The reload already happened, so buffer and disk agree; the only
      -- honest question left is whether the text differs from what was
      -- on screen a moment ago.
      if changed_from_baseline(args.buf) then
        observe(args.buf, RELOADED)
      end
    end,
  })

  -- Writing the buffer, or re-reading it (:e!), resolves the divergence:
  -- one side won and both sides now agree.
  -- Snapshot the outgoing text before any read replaces it, so a reload
  -- can be compared against what was actually on screen.
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = group,
    callback = function(args) set_baseline_before_read(args.buf) end,
  })

  -- Writing the buffer, or re-reading it (:e!), resolves the divergence:
  -- one side won and both sides now agree.
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    group = group,
    callback = function(args)
      forget(args.buf)
      if baseline[args.buf] == nil then
        set_baseline(args.buf) -- initial read of this buffer
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(args)
      classified_this_tick[args.buf] = nil
      baseline[args.buf] = nil
    end,
  })

  -- Event-driven checks, for the moments a change is most likely to have
  -- landed: coming back to the terminal, entering a buffer, leaving insert
  -- mode, closing a :terminal command, or simply sitting still.
  vim.api.nvim_create_autocmd(
    { "FocusGained", "BufEnter", "InsertLeave", "TermLeave", "CursorHold", "CursorHoldI" },
    { group = group, callback = M.check }
  )

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if poll_timer then
        poll_timer:stop()
        poll_timer:close()
        poll_timer = nil
      end
    end,
  })

  -- Baseline any buffer that was already loaded before this ran, so the
  -- first external write to it is a comparison rather than a guess.
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      set_baseline(bufnr)
    end
  end

  start_polling()

  vim.api.nvim_create_user_command("DiskCheck", M.check,
    { desc = "Re-compare open buffers against the files backing them" })

  vim.api.nvim_create_user_command("DiskReload", function()
    vim.cmd("edit!")
  end, { desc = "Discard buffer edits and take the version on disk" })

  vim.api.nvim_create_user_command("DiskDiff", open_disk_diff,
    { desc = "Diff this buffer against the version on disk" })

  vim.api.nvim_create_user_command("DiskState", function()
    local kind = M.state() or "synced"
    vim.notify("disk divergence: " .. kind, vim.log.levels.INFO)
  end, { desc = "Report this buffer's divergence state" })
end

--- A lualine component. Kept here rather than in the bar config because
--- the state is not a statusline concept -- the bar is just one renderer.
M.component = {
  function() return M.render() end,
  cond = function() return M.render() ~= "" end,
  color = function() return M.highlight() end,
}

return M
