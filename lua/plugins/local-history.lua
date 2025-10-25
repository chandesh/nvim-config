-- ========================================
-- Local File History and Snapshot Management
-- ========================================

-- Local history configuration
local M = {}
      
      -- Configuration
      local config = {
        history_dir = vim.fn.stdpath("data") .. "/local_history",
        max_snapshots_per_file = 50,
        snapshot_interval = 30000, -- 30 seconds in milliseconds
        excluded_filetypes = {
          "oil", "alpha", "dashboard", "neo-tree", "Trouble", "trouble",
          "lazy", "mason", "notify", "toggleterm", "lazyterm", "fugitive",
          "gitcommit", "gitrebase", "help", "qf", "directory", "NvimTree"
        },
        excluded_patterns = {
          "%.git/",
          "node_modules/",
          "%.tmp$",
          "%.log$",
          "/tmp/",
        }
      }
      
      -- Ensure history directory exists
      if vim.fn.isdirectory(config.history_dir) == 0 then
        vim.fn.mkdir(config.history_dir, "p")
      end
      
      -- Utility functions
      local function should_exclude_file(filepath, filetype)
        -- Check filetype exclusions
        for _, excluded in ipairs(config.excluded_filetypes) do
          if filetype == excluded then
            return true
          end
        end
        
        -- Check pattern exclusions
        for _, pattern in ipairs(config.excluded_patterns) do
          if string.match(filepath, pattern) then
            return true
          end
        end
        
        return false
      end
      
      local function get_safe_filename(filepath)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return filename:gsub("[^%w%.%-_]", "_")
      end
      
      local function create_snapshot(filepath)
        if not filepath or filepath == "" then
          return
        end
        
        local filetype = vim.bo.filetype or ""
        
        -- Skip excluded files
        if should_exclude_file(filepath, filetype) then
          return
        end
        
        -- Skip if file doesn't exist
        if vim.fn.filereadable(filepath) == 0 then
          return
        end
        
        local safe_filename = get_safe_filename(filepath)
        local timestamp = vim.fn.strftime("%Y%m%d_%H%M%S")
        local snapshot_path = config.history_dir .. "/" .. safe_filename .. "_" .. timestamp .. ".hist"
        
        -- Read current file content
        local content = vim.fn.readfile(filepath)
        if not content then
          return
        end
        
        -- Create snapshot with metadata
        local snapshot_data = {
          "# Local History Snapshot",
          "# Original: " .. filepath,
          "# Created: " .. vim.fn.strftime("%Y-%m-%d %H:%M:%S"),
          "# Filetype: " .. filetype,
          "# Lines: " .. #content,
          "# --- Content Below ---",
          ""
        }
        
        -- Append file content
        for _, line in ipairs(content) do
          table.insert(snapshot_data, line)
        end
        
        -- Write snapshot
        vim.fn.writefile(snapshot_data, snapshot_path)
        
        -- Cleanup old snapshots
        M.cleanup_old_snapshots(safe_filename)
      end
      
      function M.cleanup_old_snapshots(safe_filename)
        local pattern = config.history_dir .. "/" .. safe_filename .. "_*.hist"
        local snapshots = vim.fn.glob(pattern, false, true)
        
        if #snapshots > config.max_snapshots_per_file then
          -- Sort by modification time (oldest first)
          table.sort(snapshots, function(a, b)
            return vim.fn.getftime(a) < vim.fn.getftime(b)
          end)
          
          -- Remove excess snapshots
          for i = 1, #snapshots - config.max_snapshots_per_file do
            vim.fn.delete(snapshots[i])
          end
        end
      end
      
      function M.get_file_snapshots(filepath)
        if not filepath or filepath == "" then
          return {}
        end
        
        local safe_filename = get_safe_filename(filepath)
        local pattern = config.history_dir .. "/" .. safe_filename .. "_*.hist"
        local snapshots = vim.fn.glob(pattern, false, true)
        
        -- Sort by timestamp (newest first)
        table.sort(snapshots, function(a, b)
          return vim.fn.getftime(a) > vim.fn.getftime(b)
        end)
        
        local results = {}
        for _, snapshot_path in ipairs(snapshots) do
          local timestamp_match = string.match(snapshot_path, "_(%d+_%d+)%.hist$")
          if timestamp_match then
            local formatted_time = string.gsub(timestamp_match, "_", " ")
            formatted_time = string.gsub(formatted_time, "(%d%d%d%d)(%d%d)(%d%d) (%d%d)(%d%d)(%d%d)", 
              "%1-%2-%3 %4:%5:%6")
            
            table.insert(results, {
              path = snapshot_path,
              time = formatted_time,
              raw_time = timestamp_match
            })
          end
        end
        
        return results
      end
      
      function M.show_local_history()
        local current_file = vim.fn.expand("%:p")
        if current_file == "" then
          vim.notify("No file in current buffer", vim.log.levels.WARN)
          return
        end
        
        local snapshots = M.get_file_snapshots(current_file)
        if #snapshots == 0 then
          vim.notify("No local history found for " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
          return
        end
        
        -- Use Telescope to show history
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        
        pickers.new({}, {
          prompt_title = "Local History: " .. vim.fn.expand("%:t"),
          finder = finders.new_table({
            results = snapshots,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.time .. " (" .. vim.fn.fnamemodify(entry.path, ":t") .. ")",
                ordinal = entry.time,
                path = entry.path,  -- Add path for previewer
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          previewer = conf.file_previewer({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                -- Open snapshot in new split
                vim.cmd("split " .. selection.value.path)
              end
            end)
            
            -- Use <C-v> for diff view (similar to vertical split)
            map("i", "<C-v>", function()
              local selection = action_state.get_selected_entry()
              if selection then
                -- Show diff with current file
                actions.close(prompt_bufnr)
                vim.cmd("vert diffsplit " .. selection.value.path)
              end
            end)
            
            map("n", "<C-v>", function()
              local selection = action_state.get_selected_entry()
              if selection then
                -- Show diff with current file
                actions.close(prompt_bufnr)
                vim.cmd("vert diffsplit " .. selection.value.path)
              end
            end)
            
            return true
          end,
        }):find()
      end
      
      function M.create_manual_snapshot()
        local current_file = vim.fn.expand("%:p")
        if current_file == "" then
          vim.notify("No file in current buffer", vim.log.levels.WARN)
          return
        end
        
        create_snapshot(current_file)
        vim.notify("Manual snapshot created for " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
      end
      
      function M.list_all_tracked_files()
        -- Get all snapshot files
        local pattern = config.history_dir .. "/*.hist"
        local snapshots = vim.fn.glob(pattern, false, true)
        
        if #snapshots == 0 then
          vim.notify("No local history snapshots found", vim.log.levels.INFO)
          return
        end
        
        -- Extract unique files by reading original path from snapshot metadata
        local tracked_files = {}
        local seen = {}
        
        for _, snapshot_path in ipairs(snapshots) do
          -- Read first few lines to get original filepath
          local lines = vim.fn.readfile(snapshot_path, "", 10)
          for _, line in ipairs(lines) do
            local original_path = string.match(line, "^# Original: (.+)$")
            if original_path and not seen[original_path] then
              seen[original_path] = true
              
              -- Get the most recent snapshot time for this file
              local safe_filename = get_safe_filename(original_path)
              local file_snapshots = vim.fn.glob(config.history_dir .. "/" .. safe_filename .. "_*.hist", false, true)
              
              if #file_snapshots > 0 then
                -- Sort to get most recent
                table.sort(file_snapshots, function(a, b)
                  return vim.fn.getftime(a) > vim.fn.getftime(b)
                end)
                
                local latest_time = vim.fn.getftime(file_snapshots[1])
                local formatted_time = vim.fn.strftime("%Y-%m-%d %H:%M:%S", latest_time)
                
                table.insert(tracked_files, {
                  path = original_path,
                  count = #file_snapshots,
                  latest = formatted_time,
                  latest_timestamp = latest_time,
                })
              end
              break
            end
          end
        end
        
        -- Sort by most recent snapshot first
        table.sort(tracked_files, function(a, b)
          return a.latest_timestamp > b.latest_timestamp
        end)
        
        -- Use Telescope to show all tracked files
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        
        pickers.new({}, {
          prompt_title = "Files with Local History (" .. #tracked_files .. " files)",
          finder = finders.new_table({
            results = tracked_files,
            entry_maker = function(entry)
              return {
                value = entry,
                display = vim.fn.fnamemodify(entry.path, ":~") .. " (" .. entry.count .. " snapshots, latest: " .. entry.latest .. ")",
                ordinal = entry.path,
                path = entry.path,  -- Add path for telescope
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                -- Open the file and show its history
                vim.cmd("edit " .. vim.fn.fnameescape(selection.value.path))
                vim.defer_fn(function()
                  M.show_local_history()
                end, 100)
              end
            end)
            
            map("i", "<C-o>", function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                -- Just open the file without showing history
                vim.cmd("edit " .. vim.fn.fnameescape(selection.value.path))
              end
            end)
            
            return true
          end,
        }):find()
      end
      
      -- Auto-create snapshots
      local last_snapshot_time = {}
      
      local function auto_snapshot()
        local current_file = vim.fn.expand("%:p")
        if current_file == "" then
          return
        end
        
        local current_time = vim.fn.localtime()
        local last_time = last_snapshot_time[current_file] or 0
        
        -- Only create snapshot if enough time has passed
        if current_time - last_time >= (config.snapshot_interval / 1000) then
          create_snapshot(current_file)
          last_snapshot_time[current_file] = current_time
        end
      end
      
      -- Autocmds for automatic snapshots
      local augroup = vim.api.nvim_create_augroup("LocalHistory", { clear = true })
      
      -- Create snapshot on save
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup,
        callback = function()
          vim.defer_fn(function()
            auto_snapshot()
          end, 100)
        end,
        desc = "Create local history snapshot on save"
      })
      
      -- Create snapshot on buffer leave (if modified)
      vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        callback = function()
          if vim.bo.modified then
            vim.cmd("silent! write")
            vim.defer_fn(function()
              auto_snapshot()
            end, 200)
          end
        end,
        desc = "Create snapshot on buffer leave"
      })
      
      -- Periodic snapshots during editing
      local timer = vim.loop.new_timer()
      timer:start(config.snapshot_interval, config.snapshot_interval, vim.schedule_wrap(function()
        if vim.bo.modified then
          auto_snapshot()
        end
      end))
      
-- Expose functions globally
_G.LocalHistory = M

-- Return empty table for lazy.nvim compatibility
return {}
