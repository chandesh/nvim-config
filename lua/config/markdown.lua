-- ~/.config/nvim/lua/config/markdown.lua
-- =============================================================================
-- render-markdown.nvim Configuration
-- Loaded on demand via FileType autocmd (registered in autocmds.lua)
-- Plugin: MeanderingProgrammer/render-markdown.nvim
-- Location: pack/ui/opt/render-markdown.nvim
-- Requires: nvim-treesitter (markdown, markdown_inline), nvim-web-devicons
-- =============================================================================

local M = {}

function M.setup()
  -- Load from opt/ before calling setup
  vim.cmd('packadd render-markdown.nvim')

  local ok, rm = pcall(require, 'render-markdown')
  if not ok then return end

  rm.setup({
    -- ── General ─────────────────────────────────────────────────────
    enabled = true,
    file_types = { 'markdown', 'md', 'mdx', 'quarto', 'rmd' },
    render_modes = { 'n', 'c' },
    debounce = 100,
    max_file_size = 10.0,

    -- ── Headings ────────────────────────────────────────────────────
    heading = {
      enabled = true,
      sign = true,
      position = 'overlay',
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      width = 'full',
      border = false,
      above = '▄',
      below = '▀',
      backgrounds = {
        'RenderMarkdownH1Bg',
        'RenderMarkdownH2Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg',
        'RenderMarkdownH5Bg',
        'RenderMarkdownH6Bg',
      },
      foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
      },
    },

    -- ── Code Blocks ─────────────────────────────────────────────────
    code = {
      enabled = true,
      sign = true,
      style = 'full',
      position = 'left',
      language = true,
      language_icon = true,
      language_name = true,
      language_info = true,
      language_pad = 0,
      disable_background = { 'diff' },
      width = 'full',
      left_pad = 0,
      right_pad = 0,
      min_width = 0,
      border = 'hide',
      above = '▄',
      below = '▀',
      inline = true,
      highlight = 'RenderMarkdownCode',
      highlight_info = 'RenderMarkdownCodeInfo',
      highlight_language = nil,
      highlight_border = 'RenderMarkdownCodeBorder',
      highlight_inline = 'RenderMarkdownCodeInline',
    },

    -- ── Dash / Horizontal Rule ─────────────────────────────────────
    dash = {
      enabled = true,
      icon = '─',
      width = 'full',
      highlight = 'RenderMarkdownDash',
    },

    -- ── Bullet Lists ───────────────────────────────────────────────
    bullet = {
      enabled = true,
      icons = { '●', '○', '◆', '◇' },
      ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return ('%d.'):format(index > 1 and index or ctx.index)
      end,
      left_pad = 0,
      right_pad = 0,
      highlight = 'RenderMarkdownBullet',
    },

    -- ── Checkboxes ─────────────────────────────────────────────────
    checkbox = {
      enabled = true,
      bullet = false,
      left_pad = 0,
      right_pad = 1,
      unchecked = {
        icon = '󰄱 ',
        highlight = 'RenderMarkdownUnchecked',
        scope_highlight = nil,
      },
      checked = {
        icon = '󰱒 ',
        highlight = 'RenderMarkdownChecked',
        scope_highlight = nil,
      },
      custom = {
        todo = {
          raw = '[-]',
          rendered = '󰥔 ',
          highlight = 'RenderMarkdownTodo',
          scope_highlight = nil,
        },
      },
    },

    -- ── Block Quotes / Callouts ────────────────────────────────────
    quote = {
      enabled = true,
      icon = '▋',
      repeat_linebreak = false,
      highlight = {
        'RenderMarkdownQuote1',
        'RenderMarkdownQuote2',
        'RenderMarkdownQuote3',
        'RenderMarkdownQuote4',
        'RenderMarkdownQuote5',
        'RenderMarkdownQuote6',
      },
    },

    -- ── Tables ─────────────────────────────────────────────────────
    pipe_table = {
      enabled = true,
      preset = 'none',
      cell = 'padded',
      padding = 1,
      min_width = 0,
      border = {
        '┌', '┬', '┐',
        '├', '┼', '┤',
        '└', '┴', '┘',
        '│', '─',
      },
      border_enabled = true,
      alignment_indicator = '━',
      head = 'RenderMarkdownTableHead',
      row = 'RenderMarkdownTableRow',
      style = 'full',
    },

    -- ── Links ──────────────────────────────────────────────────────
    link = {
      enabled = true,
      footnote = {
        enabled = true,
        icon = '󰯔 ',
        superscript = true,
        prefix = '',
        suffix = '',
      },
      image = '󰥶 ',
      email = '󰀓 ',
      hyperlink = '󰌹 ',
      highlight = 'RenderMarkdownLink',
      highlight_title = 'RenderMarkdownLinkTitle',
      wiki = {
        enabled = true,
        icon = '󱗖 ',
        conceal_destination = true,
        highlight = 'RenderMarkdownWikiLink',
        scope_highlight = nil,
      },
      custom = {
        web = { icon = '󰖟 ', pattern = '^http' },
        github = { icon = '󰊤 ', pattern = 'github%.com', kind = 'url' },
        gitlab = { icon = '󰮠 ', pattern = 'gitlab%.com', kind = 'url' },
        google = { icon = '󰊭 ', pattern = 'google%.com', kind = 'url' },
        youtube = { icon = '󰗃 ', pattern = 'youtube[^.]*%.com', kind = 'url' },
      },
    },

    -- ── Sign Column ────────────────────────────────────────────────
    sign = {
      enabled = true,
      highlight = 'RenderMarkdownSign',
    },

    -- ── Inline Highlight ───────────────────────────────────────────
    inline_highlight = {
      enabled = true,
      highlight = 'RenderMarkdownInlineHighlight',
    },

    -- ── Indent ─────────────────────────────────────────────────────
    indent = {
      enabled = false,
    },

    -- ── HTML ───────────────────────────────────────────────────────
    html = {
      enabled = true,
      comment = {
        conceal = true,
        text = nil,
        highlight = 'RenderMarkdownHtmlComment',
      },
    },

    -- ── Window Options ─────────────────────────────────────────────
    win_options = {
      conceallevel = {
        default = vim.o.conceallevel,
        rendered = 3,
      },
      concealcursor = {
        default = vim.o.concealcursor,
        rendered = '',
      },
    },

    -- ── Anti-Conceal ───────────────────────────────────────────────
    anti_conceal = {
      enabled = true,
      disabled_modes = false,
      above = 0,
      below = 0,
      ignore = {
        code_background = true,
        indent = true,
        sign = true,
        virtual_lines = true,
      },
    },

    -- ── Padding ────────────────────────────────────────────────────
    padding = {
      highlight = 'Normal',
    },

    -- ── Completions ────────────────────────────────────────────────
    completions = {
      blink = { enabled = false },
      coq = { enabled = false },
      lsp = { enabled = true },
    },
  })

  -- ── Solarized Osaka Highlight Groups ──────────────────────────────
  local function set_markdown_highlights()
    local hl = vim.api.nvim_set_hl

    -- Headings
    hl(0, 'RenderMarkdownH1', { fg = '#00ED64', bold = true })
    hl(0, 'RenderMarkdownH2', { fg = '#73DACA', bold = true })
    hl(0, 'RenderMarkdownH3', { fg = '#BB9AF7', bold = true })
    hl(0, 'RenderMarkdownH4', { fg = '#E0AF68', bold = true })
    hl(0, 'RenderMarkdownH5', { fg = '#F7768E', bold = true })
    hl(0, 'RenderMarkdownH6', { fg = '#FF9E64', bold = true })

    -- Heading backgrounds
    hl(0, 'RenderMarkdownH1Bg', { bg = '#0D2B1A' })
    hl(0, 'RenderMarkdownH2Bg', { bg = '#0D2229' })
    hl(0, 'RenderMarkdownH3Bg', { bg = '#1A1429' })
    hl(0, 'RenderMarkdownH4Bg', { bg = '#292316' })
    hl(0, 'RenderMarkdownH5Bg', { bg = '#291419' })
    hl(0, 'RenderMarkdownH6Bg', { bg = '#291D14' })

    -- Code
    hl(0, 'RenderMarkdownCode', { bg = '#001A24' })
    hl(0, 'RenderMarkdownCodeInline', { bg = '#0E2A38', fg = '#73DACA' })
    hl(0, 'RenderMarkdownCodeInfo', { fg = '#565F89', italic = true })
    hl(0, 'RenderMarkdownCodeBorder', { fg = '#1F2335' })
    hl(0, 'RenderMarkdownCodeFallback', { fg = '#565F89' })

    -- Bullet
    hl(0, 'RenderMarkdownBullet', { fg = '#00ED64' })

    -- Checkboxes
    hl(0, 'RenderMarkdownUnchecked', { fg = '#565F89' })
    hl(0, 'RenderMarkdownChecked', { fg = '#00ED64' })
    hl(0, 'RenderMarkdownTodo', { fg = '#E0AF68' })

    -- Quotes
    hl(0, 'RenderMarkdownQuote1', { fg = '#565F89', italic = true })
    hl(0, 'RenderMarkdownQuote2', { fg = '#73DACA', italic = true })
    hl(0, 'RenderMarkdownQuote3', { fg = '#BB9AF7', italic = true })
    hl(0, 'RenderMarkdownQuote4', { fg = '#E0AF68', italic = true })
    hl(0, 'RenderMarkdownQuote5', { fg = '#F7768E', italic = true })
    hl(0, 'RenderMarkdownQuote6', { fg = '#FF9E64', italic = true })

    -- Tables
    hl(0, 'RenderMarkdownTableHead', { fg = '#73DACA', bold = true })
    hl(0, 'RenderMarkdownTableRow', { fg = '#A9B1D6' })

    -- Links
    hl(0, 'RenderMarkdownLink', { fg = '#73DACA', underline = true })
    hl(0, 'RenderMarkdownLinkTitle', { fg = '#BB9AF7', underline = true })
    hl(0, 'RenderMarkdownWikiLink', { fg = '#BB9AF7', underline = true })

    -- Dash
    hl(0, 'RenderMarkdownDash', { fg = '#1F2335' })

    -- Sign
    hl(0, 'RenderMarkdownSign', { fg = '#565F89' })

    -- Inline highlight
    hl(0, 'RenderMarkdownInlineHighlight', { bg = '#1F2335' })

    -- HTML comment
    hl(0, 'RenderMarkdownHtmlComment', { fg = '#565F89', italic = true })

    -- Indent
    hl(0, 'RenderMarkdownIndent', { fg = '#1F2335' })

    -- Math
    hl(0, 'RenderMarkdownMath', { fg = '#BB9AF7' })
  end

  set_markdown_highlights()

  -- Re-apply after colorscheme changes
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('RenderMarkdownHL', { clear = true }),
    pattern = '*',
    callback = set_markdown_highlights,
  })
end

return M
