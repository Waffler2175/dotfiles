local M = {}

function M.setup()
  -- Clear existing highlights to prevent bleeding during reload
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  require('base16-colorscheme').setup {
    -- Background tones (Dark to Light)
    base00 = '#11140e',                -- Default Background
    base01 = '#191d16',   -- Lighter Background
    base02 = '#33362f', -- Selection Background
    base03 = '#8e9286',                -- Comments, Invisibles

    -- Foreground tones (Dark to Light)
    base04 = '#c4c8bb',     -- Status bars
    base05 = '#e1e4d9',             -- Default Foreground
    base06 = '#e1e4d9',             -- Light Foreground
    base07 = '#2e312a',     -- High Contrast Foreground

    -- Accent colors
    base08 = '#ffb4ab',                  -- Variables, Errors
    base09 = '#a0cfce',               -- Integers, Constants
    base0A = '#bdcbaf',              -- Classes, Search
    base0B = '#acd28f',                -- Strings, Diff Insert
    base0C = '#a0cfce',     -- Regex, Escape
    base0D = '#acd28f',      -- Functions, Methods
    base0E = '#bdcbaf',    -- Keywords
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
