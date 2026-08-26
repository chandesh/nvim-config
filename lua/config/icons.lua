-- ~/.config/nvim/lua/config/icons.lua
-- =============================================================================
-- Centralized Nerd Font v3 Icon Registry
-- Font: JetBrainsMono Nerd Font v3+ (all icons verified rendering)
-- Usage: local icons = require('config.icons')
-- =============================================================================

local M = {}

-- fa  = Font Awesome icons    (U+F000-U+F2E0 range)
-- md  = Material Design icons (U+F466-U+F470 range)
-- dev = Devicons              (U+E700-U+E7C5 range)
-- cod = VS Code codicons      (U+EA60-U+EBA0 range)
-- oct = Octicons              (U+F400-U+F4F0 range)

M.diagnostics = {
  error   = '\u{f057}',
  warn    = '\u{f071}',
  info    = '\u{f05a}',
  hint    = '\u{f0eb}',
}

M.git = {
  branch          = '\u{e725}',
  add             = '\u{f067}',
  change          = '\u{f466}',
  delete          = '\u{f467}',
  topdelete       = '\u{f467}',
  changedelete    = '\u{f466}',
  untracked       = '\u{f06e}',
  added           = '\u{f067}',
  removed         = '\u{f467}',
  ignored         = '\u{f466}',
  renamed         = '\u{f0c1}',
}

M.kinds = {
  Text          = '\u{ea9b}',
  Method        = '\u{ea8c}',
  Function      = '\u{ea8c}',
  Constructor   = '\u{ea8a}',
  Field         = '\u{ea86}',
  Variable      = '\u{ea86}',
  Class         = '\u{ea8b}',
  Interface     = '\u{ea86}',
  Module        = '\u{ea8b}',
  Property      = '\u{ea86}',
  Unit          = '\u{ea99}',
  Value         = '\u{ea95}',
  Enum          = '\u{ea95}',
  Keyword       = '\u{ea89}',
  Snippet       = '\u{ea60}',
  Color         = '\u{ea70}',
  File          = '\u{ea7b}',
  Reference     = '\u{ea7e}',
  Folder        = '\u{ea83}',
  EnumMember    = '\u{ea9b}',
  Constant      = '\u{ea90}',
  Struct        = '\u{ea8b}',
  Event         = '\u{ea93}',
  Operator      = '\u{ea91}',
  TypeParameter = '\u{ea94}',
}

M.explorer = {
  folder = {
    arrow_closed = '\u{f0da}',
    arrow_open   = '\u{f0d7}',
    default      = '\u{f07b}',
    open         = '\u{f07c}',
    empty        = '\u{f07b}',
    empty_open   = '\u{f07c}',
    symlink      = '\u{f07b}',
    symlink_open = '\u{f07c}',
  },
  git = {
    unstaged  = '\u{f067}',
    staged    = '\u{f00c}',
    unmerged  = '\u{e728}',
    renamed   = '\u{f0c1}',
    untracked = '\u{f06e}',
    deleted   = '\u{f467}',
    ignored   = '\u{f466}',
  },
}

M.ui = {
  ellipsis    = '\u{2026}',
  modified    = '\u{f067}',
  readonly    = '\u{f023}',
  unnamed     = '\u{ea7b}',
  newfile     = '\u{f067}',
  fold_closed = '\u{f0da}',
  fold_open   = '\u{f0d7}',
  fold_sep    = '\u{2026}',
}

M.lualine = {
  mode = {
    normal   = '\u{f30c}',
    insert   = '\u{f303}',
    visual   = '\u{f06e}',
    v_line   = '\u{f06e}',
    v_block  = '\u{f06e}',
    command  = '\u{f121}',
    replace  = '\u{f044}',
    terminal = '\u{f120}',
  },
}

M.todo = {
  FIX  = '\u{f467}',
  TODO = '\u{f00c}',
  HACK = '\u{f188}',
  WARN = '\u{f468}',
  PERF = '\u{e725}',
  NOTE = '\u{f46b}',
  TEST = '\u{f188}',
}

M.fidget = {
  spinner = { '\u{f111}','\u{f1e6}','\u{f013}','\u{f0c7}' },
  done    = '\u{f00c}',
}

M.copilot = {
  enabled = '\u{f09b}',
  disabled = '\u{f09b}',
}

M.plugin_updates = {
  available = '\u{f019}',
  checking = '\u{f021}',
}

M.dashboard = {
  find_file    = '\u{f002}',
  new_file     = '\u{f067}',
  recent_files = '\u{f1da}',
  live_grep    = '\u{f121}',
  session      = '\u{f0c7}',
  config       = '\u{f013}',
  quit         = '\u{f00d}',
  toggle_tree  = '\u{f07b}',
}

M.indent = {
  char     = '\u{2502}',
  tab_char = '\u{2192}',
  scope    = '\u{2502}',
  scope_end = '\u{2570}',
}

return M
