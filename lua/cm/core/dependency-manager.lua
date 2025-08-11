-- Neovim Cross-Platform Dependency Manager
-- Supports: MacOS (Homebrew), Ubuntu (APT), Fedora (DNF)

local M = {}

-- Configuration
M.config = {
  auto_install = true,
  notify_level = vim.log.levels.INFO,
  install_timeout = 300, -- 5 minutes
  check_interval = 86400, -- 24 hours
  max_concurrent_installs = 3,
}

-- System detection
M.system = {
  is_macos = vim.fn.has("mac") == 1,
  is_linux = vim.fn.has("unix") == 1 and vim.fn.has("mac") == 0,
  is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1,
}

-- Enhanced OS detection for Linux distributions
function M.detect_linux_distro()
  if not M.system.is_linux then
    return nil
  end
  
  -- Check /etc/os-release first (modern standard)
  local os_release = vim.fn.readfile("/etc/os-release", "", 50)
  for _, line in ipairs(os_release) do
    if line:match("^ID=") then
      local distro = line:gsub("ID=", ""):gsub('"', ""):lower()
      return distro
    end
  end
  
  -- Fallback methods
  if vim.fn.executable("lsb_release") == 1 then
    local result = vim.fn.system("lsb_release -si"):lower():gsub("\n", "")
    return result
  end
  
  -- Check specific files
  if vim.fn.filereadable("/etc/ubuntu-release") == 1 or vim.fn.filereadable("/etc/debian_version") == 1 then
    return "ubuntu"
  elseif vim.fn.filereadable("/etc/fedora-release") == 1 or vim.fn.filereadable("/etc/redhat-release") == 1 then
    return "fedora"
  end
  
  return "unknown"
end

-- Package managers with enhanced detection
M.package_managers = {
  macos = {
    homebrew = {
      cmd = "brew",
      install_cmd = "brew install",
      update_cmd = "brew update",
      search_cmd = "brew search",
      check_cmd = function(pkg) return vim.fn.system("brew list " .. pkg .. " 2>/dev/null"):find(pkg) ~= nil end,
    },
  },
  ubuntu = {
    apt = {
      cmd = "apt-get",
      install_cmd = "sudo apt-get update && sudo apt-get install -y",
      update_cmd = "sudo apt-get update",
      search_cmd = "apt search",
      check_cmd = function(pkg) return vim.fn.system("dpkg -l " .. pkg .. " 2>/dev/null | grep '^ii'"):len() > 0 end,
    },
  },
  fedora = {
    dnf = {
      cmd = "dnf",
      install_cmd = "sudo dnf install -y",
      update_cmd = "sudo dnf update",
      search_cmd = "dnf search",
      check_cmd = function(pkg) return vim.fn.system("rpm -q " .. pkg .. " 2>/dev/null"):find("not installed") == nil end,
    },
  },
}

-- Comprehensive system dependencies
M.dependencies = {
  -- === CRITICAL DEPENDENCIES (Priority 1) ===
  git = {
    cmd = "git",
    description = "Version control system (critical)",
    priority = 1,
    packages = {
      macos = { homebrew = "git" },
      ubuntu = { apt = "git" },
      fedora = { dnf = "git" },
    },
    post_install = function()
      -- Basic git configuration check
      if vim.fn.system("git config --global user.name"):len() == 0 then
        vim.notify("⚠️  Please configure git: git config --global user.name 'Your Name'", vim.log.levels.WARN)
      end
    end,
  },
  
  ripgrep = {
    cmd = "rg",
    description = "Ultra-fast text search (essential for Telescope)",
    priority = 1,
    packages = {
      macos = { homebrew = "ripgrep" },
      ubuntu = { apt = "ripgrep" },
      fedora = { dnf = "ripgrep" },
    },
    verify = function()
      local result = vim.fn.system("rg --version")
      return result:find("ripgrep") ~= nil
    end,
  },
  
  fd = {
    cmd = "fd",
    description = "Fast file finder (essential for Telescope)",
    priority = 1,
    packages = {
      macos = { homebrew = "fd" },
      ubuntu = { apt = "fd-find" }, -- Different package name on Ubuntu
      fedora = { dnf = "fd-find" },
    },
    post_install = function()
      -- Create symlink for Ubuntu if needed
      if M.detect_linux_distro() == "ubuntu" and not M.cmd_exists("fd") and M.cmd_exists("fdfind") then
        vim.notify("Creating fd symlink...", M.config.notify_level)
        vim.fn.system("mkdir -p ~/.local/bin && ln -sf $(which fdfind) ~/.local/bin/fd")
        vim.env.PATH = vim.env.PATH .. ":~/.local/bin"
      end
    end,
  },
  
  python3 = {
    cmd = "python3",
    description = "Python 3 interpreter (required for many plugins)",
    priority = 1,
    packages = {
      macos = { homebrew = "python@3.12" },
      ubuntu = { apt = "python3 python3-pip python3-venv" },
      fedora = { dnf = "python3 python3-pip python3-virtualenv" },
    },
    verify = function()
      local version = vim.fn.system("python3 --version")
      return version:find("Python 3") ~= nil
    end,
  },
  
  nodejs = {
    cmd = "node",
    description = "Node.js runtime (required for LSP servers)",
    priority = 1,
    packages = {
      macos = { homebrew = "node" },
      ubuntu = { apt = "nodejs npm" },
      fedora = { dnf = "nodejs npm" },
    },
    verify = function()
      local node_version = vim.fn.system("node --version")
      local npm_version = vim.fn.system("npm --version")
      return node_version:find("v") ~= nil and npm_version:len() > 0
    end,
  },
  
  -- === IMPORTANT DEPENDENCIES (Priority 2) ===
  curl = {
    cmd = "curl",
    description = "HTTP client (needed for downloads)",
    priority = 2,
    packages = {
      macos = { homebrew = "curl" },
      ubuntu = { apt = "curl" },
      fedora = { dnf = "curl" },
    },
  },
  
  shellcheck = {
    cmd = "shellcheck",
    description = "Shell script linter",
    priority = 2,
    packages = {
      macos = { homebrew = "shellcheck" },
      ubuntu = { apt = "shellcheck" },
      fedora = { dnf = "ShellCheck" }, -- Different case on Fedora
    },
  },
  
  lazygit = {
    cmd = "lazygit",
    description = "Terminal Git UI",
    priority = 2,
    packages = {
      macos = { homebrew = "lazygit" },
      ubuntu = { apt = "lazygit" },
      fedora = { dnf = "lazygit" },
    },
    fallback_install = {
      ubuntu = function()
        -- Install from GitHub releases if not in package manager
        vim.notify("Installing lazygit from GitHub releases...", M.config.notify_level)
        local cmd = [[
          LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
          curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
          tar xf lazygit.tar.gz lazygit
          sudo install lazygit /usr/local/bin
          rm lazygit lazygit.tar.gz
        ]]
        return vim.fn.system(cmd)
      end,
    },
  },
  
  sqlite3 = {
    cmd = "sqlite3",
    description = "SQLite database CLI",
    priority = 2,
    packages = {
      macos = { homebrew = "sqlite" },
      ubuntu = { apt = "sqlite3" },
      fedora = { dnf = "sqlite" },
    },
  },
  
  -- === OPTIONAL DEPENDENCIES (Priority 3) ===
  tree = {
    cmd = "tree",
    description = "Directory tree display",
    priority = 3,
    packages = {
      macos = { homebrew = "tree" },
      ubuntu = { apt = "tree" },
      fedora = { dnf = "tree" },
    },
  },
  
  wget = {
    cmd = "wget",
    description = "File downloader",
    priority = 3,
    packages = {
      macos = { homebrew = "wget" },
      ubuntu = { apt = "wget" },
      fedora = { dnf = "wget" },
    },
  },
  
  jq = {
    cmd = "jq",
    description = "JSON processor",
    priority = 3,
    packages = {
      macos = { homebrew = "jq" },
      ubuntu = { apt = "jq" },
      fedora = { dnf = "jq" },
    },
  },
}

-- Node.js packages (installed via npm)
M.npm_packages = {
  eslint_d = {
    description = "ESLint daemon (fast JavaScript linting)",
    priority = 1,
    global = true,
  },
  ["@fsouza/prettierd"] = {
    description = "Prettier daemon (fast code formatting)",
    priority = 1,
    global = true,
  },
  eslint = {
    description = "JavaScript linter",
    priority = 2,
    global = true,
  },
  prettier = {
    description = "Code formatter",
    priority = 2,
    global = true,
  },
  stylelint = {
    description = "CSS/SCSS linter",
    priority = 2,
    global = true,
  },
  typescript = {
    description = "TypeScript compiler",
    priority = 2,
    global = true,
  },
  ["typescript-language-server"] = {
    description = "TypeScript LSP server",
    priority = 1,
    global = true,
  },
  ["vscode-langservers-extracted"] = {
    description = "HTML/CSS/JSON LSP servers",
    priority = 1,
    global = true,
  },
}

-- Python packages (installed via pip)
M.python_packages = {
  ruff = {
    description = "Ultra-fast Python linter & formatter",
    priority = 1,
  },
  black = {
    description = "Python code formatter",
    priority = 2,
  },
  isort = {
    description = "Python import sorter",
    priority = 2,
  },
  djlint = {
    description = "Django template linter",
    priority = 2,
  },
  sqlfluff = {
    description = "SQL linter and formatter",
    priority = 2,
  },
  ["python-lsp-server"] = {
    description = "Python LSP server",
    priority = 1,
  },
}

-- Utility functions
function M.cmd_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

function M.get_os_info()
  if M.system.is_macos then
    return "macos", "homebrew"
  elseif M.system.is_linux then
    local distro = M.detect_linux_distro()
    if distro == "ubuntu" or distro:find("debian") then
      return "ubuntu", "apt"
    elseif distro == "fedora" or distro:find("rhel") or distro:find("centos") then
      return "fedora", "dnf"
    end
  end
  return nil, nil
end

function M.get_package_manager()
  local os_name, pm_name = M.get_os_info()
  if os_name and pm_name then
    local pm_config = M.package_managers[os_name][pm_name]
    if M.cmd_exists(pm_config.cmd) then
      return pm_name, pm_config
    end
  end
  return nil, nil
end

function M.install_package_manager()
  if M.system.is_macos and not M.cmd_exists("brew") then
    vim.notify("🍺 Installing Homebrew...", M.config.notify_level)
    local install_cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    
    vim.fn.system(install_cmd)
    
    -- Add Homebrew to PATH for different shells
    local brew_paths = {
      'export PATH="/opt/homebrew/bin:$PATH"',
      'export PATH="/usr/local/bin:$PATH"', -- Intel Macs
    }
    
    local shell_configs = { "~/.zshrc", "~/.bashrc", "~/.bash_profile" }
    for _, config in ipairs(shell_configs) do
      local expanded = vim.fn.expand(config)
      if vim.fn.filereadable(expanded) == 1 then
        for _, path_export in ipairs(brew_paths) do
          vim.fn.system(string.format('grep -q "%s" %s || echo "%s" >> %s', path_export, expanded, path_export, expanded))
        end
        break
      end
    end
    
    -- Update current session
    vim.env.PATH = "/opt/homebrew/bin:/usr/local/bin:" .. (vim.env.PATH or "")
    
    if M.cmd_exists("brew") then
      vim.notify("✅ Homebrew installed successfully!", vim.log.levels.INFO)
      return true
    else
      vim.notify("❌ Failed to install Homebrew", vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

function M.install_system_dependency(name, dep)
  local pm_name, pm = M.get_package_manager()
  if not pm then
    vim.notify("❌ No supported package manager found", vim.log.levels.ERROR)
    return false
  end
  
  local os_name = M.get_os_info()
  local packages = dep.packages[os_name]
  
  if not packages or not packages[pm_name] then
    vim.notify(string.format("⚠️  Package %s not available for %s/%s", name, os_name, pm_name), vim.log.levels.WARN)
    
    -- Try fallback installation
    if dep.fallback_install and dep.fallback_install[os_name] then
      return dep.fallback_install[os_name]()
    end
    return false
  end
  
  vim.notify(string.format("📦 Installing %s (%s)...", name, dep.description), M.config.notify_level)
  
  local install_cmd = string.format("%s %s", pm.install_cmd, packages[pm_name])
  local result = vim.fn.system(install_cmd)
  local success = vim.v.shell_error == 0
  
  if success then
    vim.notify(string.format("✅ Successfully installed %s", name), vim.log.levels.INFO)
    
    -- Run post-install hook if available
    if dep.post_install then
      dep.post_install()
    end
    
    -- Verify installation if verification function exists
    if dep.verify and not dep.verify() then
      vim.notify(string.format("⚠️  %s installed but verification failed", name), vim.log.levels.WARN)
    end
  else
    vim.notify(string.format("❌ Failed to install %s: %s", name, result), vim.log.levels.ERROR)
  end
  
  return success
end

function M.install_npm_package(name, info)
  if not M.cmd_exists("npm") then
    vim.notify("❌ npm not found. Please install Node.js first.", vim.log.levels.ERROR)
    return false
  end
  
  vim.notify(string.format("📦 Installing npm package %s (%s)...", name, info.description), M.config.notify_level)
  
  local global_flag = info.global and "-g" or ""
  local install_cmd = string.format("npm install %s %s", global_flag, name)
  local result = vim.fn.system(install_cmd)
  local success = vim.v.shell_error == 0
  
  if success then
    vim.notify(string.format("✅ Successfully installed npm package %s", name), vim.log.levels.INFO)
  else
    vim.notify(string.format("❌ Failed to install npm package %s: %s", name, result), vim.log.levels.ERROR)
  end
  
  return success
end

function M.install_python_package(name, info)
  local pip_cmd = M.cmd_exists("pip3") and "pip3" or (M.cmd_exists("pip") and "pip" or nil)
  if not pip_cmd then
    vim.notify("❌ pip not found. Please install Python first.", vim.log.levels.ERROR)
    return false
  end
  
  vim.notify(string.format("📦 Installing Python package %s (%s)...", name, info.description), M.config.notify_level)
  
  local install_cmd = string.format("%s install --user %s", pip_cmd, name)
  local result = vim.fn.system(install_cmd)
  local success = vim.v.shell_error == 0
  
  if success then
    vim.notify(string.format("✅ Successfully installed Python package %s", name), vim.log.levels.INFO)
  else
    vim.notify(string.format("❌ Failed to install Python package %s: %s", name, result), vim.log.levels.ERROR)
  end
  
  return success
end

function M.check_and_install_dependencies()
  if not M.config.auto_install then
    return
  end
  
  local os_name, pm_name = M.get_os_info()
  vim.notify(string.format("🔍 Checking dependencies on %s (%s)...", os_name or "unknown", pm_name or "none"), M.config.notify_level)
  
  -- Install package manager if needed
  if not M.install_package_manager() then
    vim.notify("❌ Failed to install package manager", vim.log.levels.ERROR)
    return
  end
  
  local missing_system = {}
  local missing_npm = {}
  local missing_python = {}
  
  -- Check system dependencies
  for name, dep in pairs(M.dependencies) do
    if not M.cmd_exists(dep.cmd) then
      table.insert(missing_system, {name = name, dep = dep, priority = dep.priority})
    end
  end
  
  -- Check npm packages
  for name, info in pairs(M.npm_packages) do
    if not M.cmd_exists(name:gsub("@.*/", ""):gsub("-", "_")) and not M.cmd_exists(name) then
      table.insert(missing_npm, {name = name, info = info, priority = info.priority})
    end
  end
  
  -- Sort by priority (install critical dependencies first)
  table.sort(missing_system, function(a, b) return a.priority < b.priority end)
  table.sort(missing_npm, function(a, b) return a.priority < b.priority end)
  
  -- Install critical system dependencies first
  local critical_system = vim.tbl_filter(function(item) return item.priority == 1 end, missing_system)
  if #critical_system > 0 then
    vim.notify(string.format("🚨 Installing %d critical system dependencies...", #critical_system), M.config.notify_level)
    for _, item in ipairs(critical_system) do
      M.install_system_dependency(item.name, item.dep)
    end
  end
  
  -- Install important system dependencies
  local important_system = vim.tbl_filter(function(item) return item.priority == 2 end, missing_system)
  if #important_system > 0 then
    vim.notify(string.format("📦 Installing %d important system dependencies...", #important_system), M.config.notify_level)
    for _, item in ipairs(important_system) do
      M.install_system_dependency(item.name, item.dep)
    end
  end
  
  -- Install critical npm packages
  local critical_npm = vim.tbl_filter(function(item) return item.priority <= 2 end, missing_npm)
  if #critical_npm > 0 and M.cmd_exists("npm") then
    vim.notify(string.format("📦 Installing %d essential npm packages...", #critical_npm), M.config.notify_level)
    for _, item in ipairs(critical_npm) do
      M.install_npm_package(item.name, item.info)
    end
  end
  
  -- Show optional dependencies
  local optional_system = vim.tbl_filter(function(item) return item.priority >= 3 end, missing_system)
  if #optional_system > 0 then
    local names = vim.tbl_map(function(item) return item.name end, optional_system)
    vim.notify(string.format("💡 Optional system packages available: %s", table.concat(names, ", ")), vim.log.levels.INFO)
  end
  
  -- Show Python packages info
  if M.cmd_exists("pip3") or M.cmd_exists("pip") then
    local py_names = vim.tbl_keys(M.python_packages)
    vim.notify(string.format("🐍 Python packages available for manual install: pip3 install --user %s", table.concat(py_names, " ")), vim.log.levels.INFO)
  end
  
  vim.notify("✅ Dependency check complete!", vim.log.levels.INFO)
end

function M.show_dependency_status()
  local info = {
    string.format("=== Neovim Dependencies Status (%s) ===", M.get_os_info() or "Unknown OS"),
    "",
    "🔧 System Tools:",
  }
  
  for name, dep in pairs(M.dependencies) do
    local status = M.cmd_exists(dep.cmd) and "✅" or "❌"
    local priority_icon = dep.priority == 1 and "🚨" or (dep.priority == 2 and "⚠️" or "💡")
    table.insert(info, string.format("  %s %s %s - %s", status, priority_icon, name, dep.description))
  end
  
  table.insert(info, "")
  table.insert(info, "📦 npm Packages:")
  for name, pkg_info in pairs(M.npm_packages) do
    local cmd_name = name:gsub("@.*/", ""):gsub("-", "_")
    local status = (M.cmd_exists(cmd_name) or M.cmd_exists(name)) and "✅" or "❌"
    local priority_icon = pkg_info.priority == 1 and "🚨" or "⚠️"
    table.insert(info, string.format("  %s %s %s - %s", status, priority_icon, name, pkg_info.description))
  end
  
  table.insert(info, "")
  table.insert(info, "🐍 Python Packages (install manually):")
  for name, pkg_info in pairs(M.python_packages) do
    local priority_icon = pkg_info.priority == 1 and "🚨" or "⚠️"
    table.insert(info, string.format("  📦 %s %s - %s", priority_icon, name, pkg_info.description))
  end
  
  -- Create a buffer to show the information
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, info)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  -- Open in a split
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_name(buf, 'Dependency Status')
end

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
  
  -- Create user commands
  vim.api.nvim_create_user_command("DependencyCheck", M.check_and_install_dependencies, { 
    desc = "Check and install missing dependencies" 
  })
  
  vim.api.nvim_create_user_command("DependencyStatus", M.show_dependency_status, { 
    desc = "Show detailed dependency status" 
  })
  
  vim.api.nvim_create_user_command("DependencyInfo", function()
    local os_name, pm_name = M.get_os_info()
    vim.notify(string.format("OS: %s, Package Manager: %s\\nUse :DependencyStatus for detailed info", 
      os_name or "Unknown", pm_name or "None"), vim.log.levels.INFO)
  end, { desc = "Show basic dependency information" })
  
  -- Auto-check on startup (delayed to not slow down startup)
  if M.config.auto_install then
    vim.defer_fn(function()
      M.check_and_install_dependencies()
    end, 3000) -- 3 second delay to not interfere with startup
  end
end

return M
