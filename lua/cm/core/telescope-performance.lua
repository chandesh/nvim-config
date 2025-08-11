-- Advanced Telescope Performance Optimizations
-- Optimized for large multi-repository projects

local M = {}

-- Set up performance optimizations on VimEnter
function M.setup()
  -- Disable some telescope defaults that slow down large searches
  vim.g.telescope_cache_results = 1
  
  -- Set environment variables for better ripgrep performance
  vim.env.RIPGREP_CONFIG_PATH = vim.fn.expand('~/.ripgreprc')
  
  -- Create .ripgreprc if it doesn't exist
  local ripgreprc_path = vim.fn.expand('~/.ripgreprc')
  if vim.fn.filereadable(ripgreprc_path) == 0 then
    local ripgrep_config = {
      '--max-columns=150',
      '--max-columns-preview',
      '--smart-case',
      '--hidden',
      '--follow',
      '--glob=!.git/*',
      '--glob=!node_modules/*',
      '--glob=!__pycache__/*',
      '--glob=!*.pyc',
      '--glob=!*.pyo',
      '--glob=!*.pyd',
      '--glob=!coverage/*',
      '--glob=!build/*',
      '--glob=!dist/*',
      '--glob=!target/*',
      '--glob=!*.log',
      '--colors=line:none',
      '--colors=line:style:bold',
    }
    vim.fn.writefile(ripgrep_config, ripgreprc_path)
  end
  
  -- Set environment variables for fd (find alternative)
  vim.env.FD_OPTIONS = '--hidden --follow --exclude .git'
  
  -- Create autocmds for better telescope performance
  local group = vim.api.nvim_create_augroup("TelescopePerformance", { clear = true })
  
  -- Clear telescope cache periodically to prevent memory buildup
  vim.api.nvim_create_autocmd({ "VimLeave" }, {
    group = group,
    callback = function()
      -- Clear telescope state on exit
      pcall(function()
        require('telescope.state').clear()
      end)
    end,
  })
  
  -- Auto-close preview when moving fast through results
  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "TelescopePreviewerLoaded",
    callback = function()
      -- Set a shorter timeout for previews
      vim.defer_fn(function()
        vim.cmd("setlocal conceallevel=2")
      end, 50)
    end,
  })
end

-- Smart project-aware search that adapts to project size
function M.smart_find_files()
  -- Check if we're in a git repository
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  local is_git_repo = vim.v.shell_error == 0 and git_root and git_root ~= ""
  
  -- Check project size (rough estimate)
  local file_count = 0
  if is_git_repo then
    -- Count git files for better performance estimation
    local git_files = vim.fn.systemlist("git ls-files | wc -l")
    file_count = tonumber(git_files[1]) or 0
  else
    -- Count all files in current directory (limited to prevent hanging)
    local all_files = vim.fn.systemlist("find . -type f | head -5000 | wc -l")
    file_count = tonumber(all_files[1]) or 0
  end
  
  local builtin = require('telescope.builtin')
  
  if file_count > 10000 then
    -- Large project: Use git files with aggressive filtering
    if is_git_repo then
      builtin.git_files({
        show_untracked = false,  -- Skip untracked for speed
        recurse_submodules = false,
      })
    else
      -- Use fd with more aggressive filtering for non-git large projects
      builtin.find_files({
        find_command = {
          "fd", "--type", "f", 
          "--max-depth", "6",  -- Limit depth
          "--exclude", "node_modules",
          "--exclude", "__pycache__",
          "--exclude", ".git",
          "--exclude", "build",
          "--exclude", "dist",
          "--exclude", "coverage",
        },
      })
    end
  else
    -- Smaller project: Use the optimized standard approach
    if is_git_repo then
      builtin.git_files({
        show_untracked = true,
        hidden = true,
        follow = true,
      })
    else
      builtin.find_files({
        hidden = true,
        follow = true,
        no_ignore = false,
      })
    end
  end
end

-- Smart live grep that adapts to project characteristics
function M.smart_live_grep()
  -- Check if we're in a large project
  local file_count = vim.fn.systemlist("find . -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.c' -o -name '*.cpp' | wc -l")
  local source_files = tonumber(file_count[1]) or 0
  
  local builtin = require('telescope.builtin')
  
  if source_files > 5000 then
    -- Large project: Use more restrictive search
    builtin.live_grep({
      additional_args = function()
        return {
          "--max-count=100",  -- Limit matches per file
          "--max-depth=8",    -- Limit directory depth
          "--smart-case",
          "--hidden",
          "--follow",
        }
      end,
    })
  else
    -- Standard project: Use optimized search
    builtin.live_grep({
      additional_args = function()
        return {"--hidden", "--follow", "--smart-case"}
      end,
    })
  end
end

-- Cache frequently accessed directories for faster subsequent searches
M.cached_dirs = {}
function M.cache_project_dirs()
  local cwd = vim.fn.getcwd()
  if not M.cached_dirs[cwd] then
    local dirs = vim.fn.systemlist("find . -type d -name '.*' -prune -o -type d -print | head -100")
    M.cached_dirs[cwd] = dirs
  end
  return M.cached_dirs[cwd]
end

-- Quick search in specific common directories
function M.search_src()
  local builtin = require('telescope.builtin')
  builtin.find_files({
    search_dirs = {"src", "lib", "app"},
    hidden = true,
    follow = true,
  })
end

function M.search_tests()
  local builtin = require('telescope.builtin')
  builtin.find_files({
    search_dirs = {"test", "tests", "__tests__", "spec"},
    hidden = true,
    follow = true,
  })
end

function M.search_config()
  local builtin = require('telescope.builtin')
  builtin.find_files({
    search_dirs = {"config", ".config", "conf", "settings"},
    hidden = true,
    follow = true,
  })
end

return M
