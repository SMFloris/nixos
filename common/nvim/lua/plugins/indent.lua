return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = {
                char = "│",
                highlight = "FlowIndent",
            },
            scope = { enabled = false },
        },
        config = function(_, opts)
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "FlowIndent", { fg = "#3b4261" })
            end)
            require("ibl").setup(opts)
        end,
    },
}
