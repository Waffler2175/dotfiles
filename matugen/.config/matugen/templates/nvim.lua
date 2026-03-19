local M = {}

function M.setup()
  -- Clear existing highlights to prevent bleeding during reload
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  require('base16-colorscheme').setup {
    -- Background tones (Dark to Light)
    base00 = '{{colors.surface.default.hex}}',                -- Default Background
    base01 = '{{colors.surface_container_low.default.hex}}',   -- Lighter Background
    base02 = '{{colors.surface_container_highest.default.hex}}', -- Selection Background
    base03 = '{{colors.outline.default.hex}}',                -- Comments, Invisibles

    -- Foreground tones (Dark to Light)
    base04 = '{{colors.on_surface_variant.default.hex}}',     -- Status bars
    base05 = '{{colors.on_surface.default.hex}}',             -- Default Foreground
    base06 = '{{colors.on_surface.default.hex}}',             -- Light Foreground
    base07 = '{{colors.inverse_on_surface.default.hex}}',     -- High Contrast Foreground

    -- Accent colors
    base08 = '{{colors.error.default.hex}}',                  -- Variables, Errors
    base09 = '{{colors.tertiary.default.hex}}',               -- Integers, Constants
    base0A = '{{colors.secondary.default.hex}}',              -- Classes, Search
    base0B = '{{colors.primary.default.hex}}',                -- Strings, Diff Insert
    base0C = '{{colors.tertiary_fixed_dim.default.hex}}',     -- Regex, Escape
    base0D = '{{colors.primary_fixed_dim.default.hex}}',      -- Functions, Methods
    base0E = '{{colors.secondary_fixed_dim.default.hex}}',    -- Keywords
    base0F = '{{colors.error_container.default.hex}}',        -- Deprecated/Warning Tags
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
