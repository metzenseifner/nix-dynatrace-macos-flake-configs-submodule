-- jdtls-helpers.lua
-- Smart error detection and cleanup utilities for jdtls

local M = {}

-- Detect common jdtls error patterns and provide helpful hints
M.error_patterns = {
  {
    pattern = "artifactory.*not found",
    hint = "🔌 VPN Connection Required\n\nCan't reach Dynatrace Artifactory.\n\n" ..
        "Quick Fix:\n" ..
        "1. Connect to Dynatrace VPN\n" ..
        "2. Run :LspRestart jdtls\n\n" ..
        "Alternative:\n" ..
        "- Add gradlePluginPortal() fallback to settings.gradle",
    level = vim.log.levels.WARN,
    action = "Check VPN connection"
  },
  {
    pattern = "could not resolve plugin artifact",
    hint = "📦 Plugin Repository Issue\n\nCan't download Gradle plugins.\n\n" ..
        "Possible causes:\n" ..
        "- VPN not connected\n" ..
        "- Artifactory temporarily down\n" ..
        "- Plugin not yet mirrored\n\n" ..
        "Try: :JdtlsCheckNetwork",
    level = vim.log.levels.WARN,
    action = "Check network/VPN"
  },
  {
    pattern = "Unsupported class file major version",
    hint = "☕ Java Version Mismatch\n\nGradle is using wrong Java version.\n\n" ..
        "Quick Fix:\n" ..
        "1. Run :JdtlsCleanCaches\n" ..
        "2. Restart nvim in nix shell: nix develop .#jdk-21\n\n" ..
        "This cleans corrupted Gradle caches.",
    level = vim.log.levels.ERROR,
    action = "Clean caches and restart"
  },
  {
    pattern = "Could not open init generic class cache",
    hint = "🗑️  Corrupted Gradle Cache\n\nGradle cache is corrupted.\n\n" ..
        "Quick Fix: :JdtlsCleanCaches\n\n" ..
        "This will clean all Gradle and Eclipse caches.",
    level = vim.log.levels.ERROR,
    action = "Clean caches"
  },
  {
    pattern = "Cannot download Gradle.*checksum",
    hint = "⚠️  Gradle Wrapper Validation Issue\n\nGradle can't validate wrapper checksums.\n\n" ..
        "This has been disabled in config.\n" ..
        "Run: :JdtlsCleanCaches to clear old metadata.",
    level = vim.log.levels.WARN,
    action = "Clean caches"
  }
}

-- Check network connectivity to Artifactory
M.check_network = function()
  vim.notify("Checking network connectivity...", vim.log.levels.INFO)

  vim.fn.jobstart("curl -I --connect-timeout 5 https://artifactory.lab.dynatrace.org/", {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify(
          "✅ Network OK\n\nArtifactory is reachable.\nTry: :LspRestart jdtls",
          vim.log.levels.INFO,
          { timeout = 3000 }
        )
      else
        vim.notify(
          "❌ Network Issue\n\nCan't reach Artifactory.\n\n" ..
          "Actions:\n" ..
          "1. Connect to Dynatrace VPN\n" ..
          "2. Check your internet connection\n" ..
          "3. Verify: curl -I https://artifactory.lab.dynatrace.org/",
          vim.log.levels.WARN,
          { timeout = 8000 }
        )
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

-- Clean all jdtls/Gradle caches invasively
M.clean_caches = function()
  local project_root = vim.fn.getcwd()

  vim.notify("🧹 Cleaning jdtls/Gradle caches...", vim.log.levels.INFO)

  local commands = {
    -- Stop Gradle daemon
    { cmd = "cd " .. project_root .. " && ./gradlew --stop 2>&1 || true",             desc = "Stopping Gradle daemon" },
    -- Clean project metadata
    { cmd = "cd " .. project_root .. " && rm -rf .settings .project .classpath 2>&1", desc = "Removing Eclipse metadata" },
    { cmd = "cd " .. project_root .. " && rm -rf .gradle 2>&1",                       desc = "Cleaning .gradle" },
    { cmd = "cd " .. project_root .. " && rm -rf buildSrc/.gradle 2>&1",              desc = "Cleaning buildSrc/.gradle" },
    -- Clean user caches
    { cmd = "rm -rf ~/.gradle/caches/7.6.6 2>&1",                                     desc = "Cleaning Gradle 7.6.6 cache" },
    { cmd = "rm -rf ~/.config/gradle/caches 2>&1",                                    desc = "Cleaning Gradle config cache" },
    { cmd = "rm -rf ~/.eclipse 2>&1",                                                 desc = "Cleaning Eclipse workspace" },
    { cmd = "rm -rf ~/.cache/jdtls 2>&1",                                             desc = "Cleaning jdtls cache" },
    { cmd = "rm -rf ~/.local/share/nvim/jdtls 2>&1",                                  desc = "Cleaning jdtls data" },
  }

  local results = {}
  local function run_next(idx)
    if idx > #commands then
      -- All done
      local summary = "✨ Cache Cleanup Complete!\n\n"
      for _, result in ipairs(results) do
        summary = summary .. result .. "\n"
      end
      summary = summary .. "\nNext steps:\n1. Run :LspRestart jdtls\n2. Or reopen Java file"

      vim.notify(summary, vim.log.levels.INFO, { timeout = 5000 })
      return
    end

    local cmd_info = commands[idx]
    vim.fn.jobstart(cmd_info.cmd, {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          table.insert(results, "✓ " .. cmd_info.desc)
        else
          table.insert(results, "⚠ " .. cmd_info.desc .. " (skipped)")
        end
        run_next(idx + 1)
      end,
      stdout_buffered = true,
      stderr_buffered = true,
    })
  end

  run_next(1)
end

-- Analyze LSP error messages and provide smart hints
M.analyze_error = function(message)
  if not message or message == "" then
    return nil
  end

  for _, pattern_info in ipairs(M.error_patterns) do
    if string.find(message, pattern_info.pattern) then
      return pattern_info
    end
  end

  return nil
end

-- Enhanced LSP handler with smart error detection
M.setup_handlers = function()
  -- Override the default LSP error handler
  local original_handler = vim.lsp.handlers["window/showMessage"]

  vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
    -- Call original handler first
    if original_handler then
      original_handler(err, result, ctx, config)
    end

    -- Analyze the message for known error patterns
    if result and result.message then
      local error_info = M.analyze_error(result.message)

      if error_info then
        -- Show enhanced notification with hint
        vim.defer_fn(function()
          vim.notify(
            error_info.hint,
            error_info.level,
            {
              title = "jdtls - " .. error_info.action,
              timeout = 10000,
            }
          )
        end, 500)
      end
    end
  end

  -- Monitor LSP progress for Gradle sync feedback
  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(args)
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)

      if client and client.name == "jdtls" then
        local value = args.data.params.value

        if value then
          -- Track Gradle sync progress
          if value.kind == "begin" and value.title then
            if string.match(value.title, "[Ss]ynchroniz") or
                string.match(value.title, "[Bb]uild") or
                string.match(value.title, "[Gg]radle") then
              vim.notify(
                "🔄 " .. value.title .. "\n" .. (value.message or ""),
                vim.log.levels.INFO,
                { title = "jdtls Gradle Sync", timeout = 3000 }
              )
            end
          elseif value.kind == "report" and value.message then
            -- Show progress updates
            if string.match(value.message, "%d+%%") then
              -- Only show milestone percentages to avoid spam
              local percent = string.match(value.message, "(%d+)%%")
              if percent and (tonumber(percent) % 25 == 0 or tonumber(percent) == 100) then
                vim.notify(
                  value.message,
                  vim.log.levels.INFO,
                  { title = "jdtls Progress", timeout = 2000 }
                )
              end
            end
          elseif value.kind == "end" and value.title then
            if string.match(value.title, "[Ss]ynchroniz") or
                string.match(value.title, "[Bb]uild") or
                string.match(value.title, "[Gg]radle") then
              vim.notify(
                "✅ " .. value.title .. " completed",
                vim.log.levels.INFO,
                { title = "jdtls Gradle Sync", timeout = 3000 }
              )
            end
          end
        end
      end
    end,
  })
end

-- Detect and configure Eclipse formatter settings (called from jdtls on_attach for info only)
M.detect_formatter_config = function()
  local clients = vim.lsp.get_active_clients({ name = "jdtls" })
  if #clients == 0 then
    return false
  end

  local client = clients[1]
  local root_dir = client.config.root_dir

  -- Common Eclipse formatter file names
  local formatter_files = {
    "mc-code-style.xml",
    ".eclipse-formatter.xml",
    "eclipse-formatter.xml",
    "formatter.xml",
  }

  for _, filename in ipairs(formatter_files) do
    local formatter_path = root_dir .. "/" .. filename
    if vim.fn.filereadable(formatter_path) == 1 then
      return true, filename
    end
  end

  return false, nil
end

-- Check Gradle sync status by examining jdtls workspace
M.check_gradle_sync = function()
  vim.notify("🔍 Checking Gradle sync status...", vim.log.levels.INFO)

  -- Get jdtls client
  local clients = vim.lsp.get_active_clients({ name = "jdtls" })
  if #clients == 0 then
    vim.notify(
      "❌ jdtls not running\n\nStart jdtls by opening a Java file.",
      vim.log.levels.WARN
    )
    return
  end

  local client = clients[1]
  local root_dir = client.config.root_dir

  -- Check if Gradle sync has created expected files
  local checks = {
    { path = root_dir .. "/.gradle",                        desc = "Gradle cache directory" },
    { path = root_dir .. "/build-units-service/.classpath", desc = "Eclipse classpath (subproject)" },
    { path = root_dir .. "/.settings",                      desc = "Eclipse settings" },
  }

  local results = {}
  local has_issues = false

  for _, check in ipairs(checks) do
    local exists = vim.fn.isdirectory(check.path) == 1 or vim.fn.filereadable(check.path) == 1
    if exists then
      table.insert(results, "✅ " .. check.desc)
    else
      table.insert(results, "❌ " .. check.desc .. " (missing)")
      has_issues = true
    end
  end

  -- Query workspace symbols to see if subprojects are indexed
  vim.lsp.buf_request(0, "workspace/symbol", { query = "" }, function(err, result, ctx)
    local symbol_count = result and #result or 0

    -- Count symbols by source (try to identify subprojects)
    local by_project = {}
    if result then
      for _, symbol in ipairs(result) do
        if symbol.location and symbol.location.uri then
          local uri = symbol.location.uri
          -- Extract project name from path
          local project = uri:match("/build%-units%-service/") and "build-units-service" or
              uri:match("/build%-units%-service%-dto/") and "build-units-service-dto" or
              uri:match("/client%-generation/") and "client-generation" or
              uri:match("/build%-units%-service%-tools/") and "build-units-service-tools" or
              "root"
          by_project[project] = (by_project[project] or 0) + 1
        end
      end
    end

    local project_summary = "\n\n📦 Indexed symbols by subproject:\n"
    local has_subprojects = false
    for project, count in pairs(by_project) do
      project_summary = project_summary .. string.format("  • %s: %d symbols\n", project, count)
      if project ~= "root" then
        has_subprojects = true
      end
    end

    local report = "📊 Gradle Sync Status\n\n" .. table.concat(results, "\n")
    report = report .. string.format("\n\n🔢 Total workspace symbols: %d", symbol_count)

    if symbol_count > 0 then
      report = report .. project_summary
    end

    if not has_subprojects and symbol_count > 0 then
      report = report .. "\n\n⚠️  WARNING: Only root project symbols found!\n" ..
          "Subprojects may not be indexed.\n\n" ..
          "This explains why you can't find symbols in subprojects.\n\n" ..
          "Actions:\n" ..
          "1. Check LSP log: :edit ~/.local/state/nvim/lsp.log\n" ..
          "2. Look for sync errors\n" ..
          "3. Try: :LspRestart jdtls"
    elseif symbol_count == 0 then
      report = report .. "\n\n❌ NO symbols indexed!\n\n" ..
          "Gradle sync definitely failed.\n\n" ..
          "Actions:\n" ..
          "1. :JdtlsCheckNetwork (verify VPN)\n" ..
          "2. :JdtlsCleanCaches\n" ..
          "3. :LspRestart jdtls"
      has_issues = true
    end

    vim.notify(report, has_issues and vim.log.levels.WARN or vim.log.levels.INFO, { timeout = 12000 })
  end)
end

-- Check environment and provide recommendations
M.check_environment = function()
  local issues = {}
  local warnings = {}

  -- Check if in nix shell
  if vim.fn.getenv("JAVA_HOME") == vim.NIL then
    table.insert(issues, "❌ JAVA_HOME not set")
    table.insert(warnings, "You may not be in nix shell. Run: nix develop .#jdk-21")
  else
    table.insert(issues, "✓ JAVA_HOME: " .. vim.fn.getenv("JAVA_HOME"))
  end

  -- Check for dual-JDK setup
  if vim.fn.getenv("GRADLE_JAVA_HOME") ~= vim.NIL then
    table.insert(issues, "✓ GRADLE_JAVA_HOME: " .. vim.fn.getenv("GRADLE_JAVA_HOME"))
  else
    table.insert(warnings, "⚠️  GRADLE_JAVA_HOME not set (may cause issues with Gradle 7.6.6)")
  end

  -- Check if jdtls is available
  if vim.fn.executable('jdtls') == 1 then
    table.insert(issues, "✓ jdtls found in PATH")
  else
    table.insert(issues, "❌ jdtls not found in PATH")
    table.insert(warnings, "Make sure you're in nix shell: nix develop .#jdk-21")
  end

  -- Display results
  local report = "🔍 jdtls Environment Check\n\n" .. table.concat(issues, "\n")

  if #warnings > 0 then
    report = report .. "\n\n⚠️  Warnings:\n" .. table.concat(warnings, "\n")
  end

  vim.notify(report, vim.log.levels.INFO, { timeout = 8000 })
end

-- Setup all commands
M.setup_commands = function()
  vim.api.nvim_create_user_command("JdtlsCleanCaches", M.clean_caches, {
    desc = "Clean all jdtls and Gradle caches"
  })

  vim.api.nvim_create_user_command("JdtlsCheckNetwork", M.check_network, {
    desc = "Check network connectivity to Artifactory"
  })

  vim.api.nvim_create_user_command("JdtlsCheckEnv", M.check_environment, {
    desc = "Check jdtls environment setup"
  })

  vim.api.nvim_create_user_command("JdtlsCheckSync", M.check_gradle_sync, {
    desc = "Check Gradle sync status"
  })
end

return M
