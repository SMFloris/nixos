local function format_status()
    if vim.b.format_on_save == false then
        return "󰛳 fmt:off"
    else
        return "󰛳 fmt:on"
    end
end

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
    config = function()
        -- Show the enclosing symbols for any LSP that supports document symbols.
        require("nvim-navic").setup({
            lsp = {
                auto_attach = true,
                -- YAML and Helm servers can both attach to the same buffer.
                preference = { "helm_ls", "yamlls" },
            },
        })

        require("lualine").setup({
            options = {
                theme = "tokyonight",
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = {
                    { "fileformat", "filetype" },
                    format_status
                },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            winbar = {
                lualine_c = { "navic" },
            },
            extensions = { "fugitive", "quickfix", "fzf", "lazy", "mason", "nvim-dap-ui", "oil", "trouble" },
        })
    end,
}
