return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count
		local pyenv = require("cm.core.pyenv")

		local colors = {
			custom = "#979a29",
			blue = "#65D1FF",
			green = "#3EFFDC",
			violet = "#FF61EF",
			yellow = "#FFDA7B",
			red = "#FF4A4A",
			fg = "#c3ccdc",
			bg = "#101010",
			inactive_bg = "#28292e",
		}

		local my_lualine_theme = {
			normal = {
				a = { bg = colors.custom, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			insert = {
				a = { bg = colors.green, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			visual = {
				a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			command = {
				a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			replace = {
				a = { bg = colors.red, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			inactive = {
				a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = "bold" },
				b = { bg = colors.inactive_bg, fg = colors.semilightgray },
				c = { bg = colors.inactive_bg, fg = colors.semilightgray },
			},
		}
		local window_width_check_for_section = function()
			-- function to hide a section if the window size is less than 75 chars.
			return vim.fn.winwidth(0) > 75
		end

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				theme = my_lualine_theme,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{
						pyenv.get_env_name,
						color = { fg = "#1c1c1c", bg = "#03a678" },
					},

					{
						"filename",
						path = 1, -- just filename: 0, relative path: 1, absolute path: 2
						file_status = true,
						color = { fg = "#e4b622", bg = "#024554" },
					},
					-- {
					-- 	"filetype",
					-- 	color = { fg = "#1c1c1c", bg = "#00a284" },
					-- },
					-- {
					-- 	"encoding",
					-- 	color = { fg = "#1c1c1c", bg = "#00a284" },
					-- },
				},
				lualine_c = {
					{
						"branch",
						color = { fg = "#1c1c1c", bg = "#b5663d" },
					},
					{
						"diff",
						color = { fg = "#c1c1c", bg = "#02383e" },
					},
				},
				lualine_x = {},
				lualine_y = {
					{
						"diagnostics",
						color = { bg = "#313C37" },
						always_visible = false,
						cond = window_width_check_for_section,
					},
					{
						"progress",
						color = { fg = "#1c1c1c", bg = "#e4b622" },
					},
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64", bg = "#004851" },
					},
				},
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						"filename",
						path = 1,
						color = { fg = "#1c1c1c", bg = "#4d594d" },
					},
				},
				lualine_x = {
					{
						"location",
						color = { fg = "#1c1c1c", bg = "#4d594d" },
					},
				},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		})
	end,
}
