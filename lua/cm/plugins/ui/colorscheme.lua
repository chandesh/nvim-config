return {
	{
		"folke/tokyonight.nvim",
		-- priority = 1000,
		config = function()
			local transparent = false -- terminal's transparent mode should also be enabled to get this work.
			local bg = "#011628"
			local bg_dark = "#011423"
			local bg_highlight = "#143652"
			local bg_search = "#0A64AC"
			local bg_visual = "#275378"
			local fg = "#CBE0F0"
			local fg_dark = "#B4D0E9"
			local fg_gutter = "#627E97"
			local border = "#547998"

			require("tokyonight").setup({
				style = "night",
				transparent = transparent,
				styles = {
					sidebars = transparent and "transparent" or "dark",
					floats = transparent and "transparent" or "dark",
				},
				on_colors = function(colors)
					colors.bg = bg
					colors.bg_dark = transparent and colors.none or bg_dark
					colors.bg_float = transparent and colors.none or bg_dark
					colors.bg_highlight = bg_highlight
					colors.bg_popup = bg_dark
					colors.bg_search = bg_search
					colors.bg_sidebar = transparent and colors.none or bg_dark
					colors.bg_statusline = transparent and colors.none or bg_dark
					colors.bg_visual = bg_visual
					colors.border = border
					colors.fg = fg
					colors.fg_dark = fg_dark
					colors.fg_float = fg
					colors.fg_gutter = fg_gutter
					colors.fg_sidebar = fg_dark
				end,
			})

			-- load the colorscheme here
			-- options: tokyonight, tokyonight-night, tokyonight-storm,
			-- tokyonight-day and tokyonight-moon
			-- vim.cmd([[colorscheme tokyonight]])
		end,
	},
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("solarized-osaka").setup({
				transparent = true, -- Set to true if you want transparent background
				terminal_colors = true, -- Set to true to configure terminal colors
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
					functions = {},
					variables = {},
					sidebars = "dark", -- Can be "dark", "transparent", or "normal"
					floats = "dark", -- Can be "dark", "transparent", or "normal"
				},
				sidebars = { "qf", "help" }, -- Adjust as needed
				day_brightness = 0.3, -- Adjust brightness for "Day" style
				hide_inactive_statusline = false, -- Hide inactive statuslines if true
				dim_inactive = false, -- Dim inactive windows if true
				lualine_bold = false, -- Bold section headers in lualine if true

				-- Override specific color groups
				on_colors = function(colors)
					-- Example of custom color adjustments
					colors.hint = colors.orange
					colors.error = "#ff0000"
				end,

				-- Override specific highlights
				on_highlights = function(highlights, colors)
					-- Example of custom highlight adjustments
					local prompt = "#2d3149"
					highlights.TelescopeNormal = {
						bg = colors.bg_dark,
						fg = colors.fg_dark,
					}
					highlights.TelescopeBorder = {
						bg = colors.bg_dark,
						fg = colors.bg_dark,
					}
					highlights.TelescopePromptNormal = {
						bg = prompt,
					}
					highlights.TelescopePromptBorder = {
						bg = prompt,
						fg = prompt,
					}
					highlights.TelescopePromptTitle = {
						bg = prompt,
						fg = prompt,
					}
					highlights.TelescopePreviewTitle = {
						bg = colors.bg_dark,
						fg = colors.bg_dark,
					}
					highlights.TelescopeResultsTitle = {
						bg = colors.bg_dark,
						fg = colors.bg_dark,
					}
				end,
			})

			-- Load the colorscheme
			vim.cmd([[colorscheme solarized-osaka]])
			vim.cmd([[highlight Normal guibg=#0e120f]])
		end,
	},
}
