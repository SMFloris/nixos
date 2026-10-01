return {
    -- Adding a filename to the Top Right
    {
        "b0o/incline.nvim",
        enabled = true,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local devicons = require("nvim-web-devicons")

            require("incline").setup({
                hide = {
                    cursorline = false,
                    focused_win = false,
                    only_win = false,
                },
                window = {
                    margin = { vertical = 0 },
                    overlap = { winbar = true },
                },
                render = function(props)
                    local bufname = vim.api.nvim_buf_get_name(props.buf)
                    local filename = vim.fn.fnamemodify(bufname, ":t")
                    if filename == '' then filename = '[No Name]' end

                    local ext = vim.fn.fnamemodify(bufname, ":e")
                    local icon, icon_color = devicons.get_icon(filename, ext, { default = true })

                    local modified = vim.bo[props.buf].modified
                    local active_color = "#CBE0F0"
                    local inactive_color = "#627E97"
                    local text_color = props.focused and active_color or inactive_color
                    local file_icon_color = props.focused and icon_color or inactive_color
                    local modified_color = props.focused and "#ff9e64" or inactive_color

                    return {
                        { " ", icon, " ", guifg = file_icon_color },
                        { filename, gui = modified and "bold" or "none", guifg = text_color },
                        modified and { " [+]", guifg = modified_color } or "",
                        " ",
                    }
                end,
            })
        end,
    }
}
