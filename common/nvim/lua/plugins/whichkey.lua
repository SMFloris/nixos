return {
    {
        'folke/which-key.nvim',
        event = "VeryLazy",
        opts = {
            preset = "modern",
            -- Keep prefix groups visible beside commands in the short popup.
            sort = { "local", "order", "alphanum", "mod" },
            triggers = {
                { "<auto>", mode = "nxso" },
                { "ga", mode = "n" },
            },
            win = {
                width = 0.95,
                height = { min = 4, max = 16 },
            },
            layout = {
                width = { min = 24, max = 40 },
                spacing = 3,
            },
            spec = {
                { "g", group = "Go and LSP" },
                { "ga", group = "Call hierarchy" },
                { "<leader>a",  group = "AI" },
                { "<leader>b",  group = "Buffers" },
                { "<leader>c",  group = "Code cleanup" },
                { "<leader>d",  group = "Dashboard and debug" },
                { "<leader>f",  group = "Find" },
                { "<leader>g",  group = "Git" },
                { "<leader>h",  group = "Git hunks" },
                { "<leader>l",  group = "LSP" },
                { "<leader>lc", group = "Code actions" },
                { "<leader>m",  group = "Marks" },
                { "<leader>r",  group = "Rename" },
                { "<leader>t",  group = "Terminals and toggles" },
                { "<leader>x",  group = "Trouble" },
            },
        },
    }
}
