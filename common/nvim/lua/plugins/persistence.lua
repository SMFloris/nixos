return {
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
        keys = {
            { "<leader>sr", function() require("persistence").load() end, desc = "Load Session for Current Directory" },
            { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Load Last Session" },
            { "<leader>sd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
        },
    },
}