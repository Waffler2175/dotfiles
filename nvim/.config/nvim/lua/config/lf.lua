local fn = vim.fn

-- 1. Disable netrw at the very top
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lf").setup({
  default_action = "drop", 
  default_actions = {
    ["<C-t>"] = "tabedit",
    ["<C-x>"] = "split",
    ["<C-v>"] = "vsplit",
    ["<C-o>"] = "tab drop",
  },
  winblend = 10,
  dir = "", 
  direction = "float",
  border = "rounded",
  -- Note: ensure 'vim.o' is used if 'o' wasn't defined globally
  height = fn.float2nr(fn.round(0.75 * vim.o.lines)),
  width = fn.float2nr(fn.round(0.75 * vim.o.columns)),
  escape_quit = true,
  focus_on_open = true,
  mappings = true,
  tmux = false,
  default_file_manager = true, -- Set to true to replace netrw
  disable_netrw_warning = true,
  highlights = {
    Normal = {link = "Normal"},
    NormalFloat = {link = 'Normal'},
    FloatBorder = {guifg = "#ffffff", guibg = "NONE"}, -- Replace <VALUE> with hex colors
  },
  layout_mapping = "<M-u>",
  views = {
    {width = 0.800, height = 0.800},
    {width = 0.600, height = 0.600},
    {width = 0.950, height = 0.950},
    {width = 0.500, height = 0.500, col = 0, row = 0},
    {width = 0.500, height = 0.500, col = 0, row = 0.5},
    {width = 0.500, height = 0.500, col = 0.5, row = 0},
    {width = 0.500, height = 0.500, col = 0.5, row = 0.5},
  },
}) -- This is where the '}' and ')' must match

-- 2. New Leader Mapping
vim.keymap.set("n", "<leader>cd", "<Cmd>Lf<CR>", {noremap = true, desc = "Open LF"})
