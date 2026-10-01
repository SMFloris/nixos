return {
    {
        "vapourismo/terminals.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            position = "float",
        },
        keys = {
            {
                "<leader>tt",
                function() require("terminals").toggle() end,
                desc = "Toggle terminal",
            },
            {
                "<leader>tn",
                function() require("terminals").new() end,
                desc = "New terminal",
            },
            {
                "<leader>tc",
                function() require("terminals").close() end,
                desc = "Close terminal",
            },
            {
                "<leader>t[",
                function() require("terminals").prev() end,
                desc = "Previous terminal",
            },
            {
                "<leader>t]",
                function() require("terminals").next() end,
                desc = "Next terminal",
            },
        },
    },
}
