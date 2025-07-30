return {
	-- Enhanced import assistance for Python using LSP
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- Custom function to handle imports better
			local function import_under_cursor()
				local word = vim.fn.expand("<cword>")
				if word == "" then
					vim.notify("No symbol under cursor", vim.log.levels.WARN)
					return
				end

				-- Get current diagnostics for context
				local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
				
				-- First try LSP code actions for imports with enhanced filtering
				vim.lsp.buf.code_action({
					context = {
						diagnostics = diagnostics,
						only = { "quickfix", "source.fixAll", "source.addMissingImports" },
					},
					filter = function(action)
						local title_lower = action.title:lower()
						return title_lower:find("import") or
							title_lower:find("add import") or
							title_lower:find("auto-import") or
							title_lower:find("resolve import") or
							title_lower:find("fix import") or
							title_lower:find("missing import")
					end,
					apply = false, -- Show menu for user to choose
				})
			end

      -- Enhanced import function with fallback
      local function smart_import()
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        local has_pyright = false
        
        -- Debug: Show active clients
        local client_names = {}
        for _, client in ipairs(clients) do
          table.insert(client_names, client.name)
          if client.name == "pyright" then
            has_pyright = true
          end
        end
      end

      -- Key mapping for smart import (updated to avoid conflicts with insert mode)
      vim.keymap.set("n", "<leader>ai", smart_import, { desc = "Add import under cursor" })
      vim.keymap.set("n", "<leader>aa", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.addMissingImports" } },
        })
      end, { desc = "Add all missing imports" })
      
      -- Fallback manual import
      vim.keymap.set("n", "<leader>mi", function()
        local word = vim.fn.expand("<cword>")
        if word == "" then
          vim.notify("No symbol under cursor", vim.log.levels.WARN)
          return
        end
        
        local import_line = "import " .. word
        -- Add import at the top of the file
        vim.api.nvim_buf_set_lines(0, 0, 0, false, { import_line })
        vim.notify("Added import: " .. import_line, vim.log.levels.INFO)
      end, { desc = "Manually add import" })
      
      -- Also add organize imports
      vim.keymap.set("n", "<leader>ao", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" } },
        })
      end, { desc = "Add/Organize imports" })
      
		end,
	},
}
