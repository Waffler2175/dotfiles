local M = {}

function M.setup()
  -- Clear existing highlights to prevent bleeding during reload
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  require('base16-colorscheme').setup {
    -- Background tones (Dark to Light)
    base00 = '#111318',                -- Default Background
    base01 = '#191c20',   -- Lighter Background
    base02 = '#33353a', -- Selection Background
    base03 = '#8e9099',                -- Comments, Invisibles

    -- Foreground tones (Dark to Light)
    base04 = '#c4c6cf',     -- Status bars
    base05 = '#e1e2e9',             -- Default Foreground
    base06 = '#e1e2e9',             -- Light Foreground
    base07 = '#2e3035',     -- High Contrast Foreground

    -- Accent colors
    base08 = '#ffb4ab',                  -- Variables, Errors
    base09 = '#dbbce1',               -- Integers, Constants
    base0A = '#bdc7dc',              -- Classes, Search
    base0B = '#a8c8ff',                -- Strings, Diff Insert
    base0C = '#dbbce1',     -- Regex, Escape
    base0D = '#a8c8ff',      -- Functions, Methods
    base0E = '#bdc7dc',    -- Keywords
    base0F = '#93000a',        -- Deprecated/Warning Tags
  }
end

-- Signal handler for live reloading via Matugen
local signal = vim.uv.new_signal()
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    -- Reload this module specifically
    package.loaded['colors.matugen'] = nil -- Adjust this path to your actual filename
    require('colors.matugen').setup()
    vim.notify("Colorscheme updated!", vim.log.levels.INFO)
  end)
)

return M
