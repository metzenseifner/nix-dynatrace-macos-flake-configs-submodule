-- Initialize table to begin adding things to it.
local ExecJob = {} -- weird that we must have this defined outside of ExecJob.new for setmetatable
-- Ensure that when setmetatable is called on ExecJob, it will use ExecJob as index method.
-- ExecJob.__index = ExecJob -- my preference is to not use this shorthand and specify in new method.
-- otherwise you could do setmetatable(newExecJob, ExecJob) as shorthand


-- equiv to: AsyncJob.new = function(opts)end
function ExecJob.new(opts)
  -- Internal table
  local job = {}
  job.stdin = opts.stdin or M.NullPipe()
  job.stdout = opts.stdout or M.NullPipe()
  job.stderr = opts.stderr or M.NullPipe()

  -- populate internal table
  -- TODO

  -- Assign internal table to ExecJob's metadata to make "self" refer to newExecJob table
  -- This says, if index of newExecJob is missing, fallback to ExecJob as a table.
  return setmetatable(job, { __index = ExecJob })
end

--
--  -- Anytime we index AsyncJob, we access an underlying table called AsyncJob.
--  -- Why do this?
--  ExecJob.__index = ExecJob
--
--
--
--  local self = setmetatable({}, ExecJob)
--
--  self.command, self.uv_opts = M.convert_opts(opts)
--
--  self.stdin = opts.stdin or M.NullPipe()
--  self.stdout = opts.stdout or M.NullPipe()
--  self.stderr = opts.stderr or M.NullPipe()
--
--  if opts.cwd and opts.cwd ~= "" then
--    self.uv_opts.cwd = vim.fn.expand(vim.fn.escape(opts.cwd, "$"))
--    -- this is a "illegal" hack for windows. E.g. If the git command returns `/` rather than `\` as delimiter,
--    -- vim.fn.expand might just end up returning an empty string. Weird
--    -- Because empty string is not allowed in libuv the job will not spawn. Solution is we just set it to opts.cwd
--    if self.uv_opts.cwd == "" then
--      self.uv_opts.cwd = opts.cwd
--    end
--  end
--
--  self.uv_opts.stdio = {
--    self.stdin.handle,
--    self.stdout.handle,
--    self.stderr.handle,
--  }
--
--  return self
--end
--
--
