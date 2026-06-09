local M = {}

local function apply_colors()
    vim.cmd('highlight clear')
    if vim.fn.exists('syntax_on') then
        vim.cmd('syntax reset')
    end
    require('base16-colorscheme').setup {
        base00 = '#111318',
        base01 = '#191c20',
        base02 = '#33353a',
        base03 = '#8e9099',
        base04 = '#c4c6cf',
        base05 = '#e1e2e9',
        base06 = '#e1e2e9',
        base07 = '#2e3035',
        base08 = '#ffb4ab',
        base09 = '#dbbce1',
        base0A = '#bdc7dc',
        base0B = '#a8c8ff',
        base0C = '#dbbce1',
        base0D = '#a8c8ff',
        base0E = '#bdc7dc',
        base0F = '#93000a',
    }
    -- Fire ColorScheme event so transparent.nvim re-applies itself naturally
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "base16" })
    -- Full re-setup so lualine regenerates its highlight groups from scratch
    require("lualine").setup({ theme = "base16" })
    vim.cmd("redraw!")
end

function M.setup()
    apply_colors()
end

if not _G._matugen_signal then
    local signal = vim.uv.new_signal()
    signal:start(
        'sigusr1',
        vim.schedule_wrap(function()
            package.loaded['colors.matugen'] = nil
            require('colors.matugen').setup()
            vim.notify("Colorscheme updated!", vim.log.levels.INFO)
        end)
    )
    _G._matugen_signal = signal
end

return M
