return {
    -- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = true,
        -- NOTE: Options
        opts = {
            -- Styling for each Item of Snacks
            styles = {
                input = {
                    keys = {
                        n_esc = { "<C-c>", { "cmp_close", "cancel" }, mode = "n", expr = true },
                        i_esc = { "<C-c>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
                    },
                }
            },
            -- Snacks Modules
            input = {
                enabled = true,
            },
            quickfile = {
                enabled = true,
                exclude = { "latex" },
            },
            -- HACK: read picker docs @ https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
            picker = {
                enabled = true,
                matchers = {
                    frecency = true,
                    cwd_bonus = false,
                },
                formatters = {
                    file = {
                        filename_first = false,
                        filename_only = false,
                        icon_width = 2,
                    },
                },
                layout = {
                    -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
                    -- override picker layout in keymaps function as a param below
                    preset = "ivy", -- defaults to this layout unless overidden
                    cycle = false,
                },
                layouts = {
                    select = {
                        preview = false,
                        layout = {
                            backdrop = false,
                            width = 0.6,
                            min_width = 80,
                            height = 0.4,
                            min_height = 10,
                            box = "vertical",
                            border = "rounded",
                            title = "{title}",
                            title_pos = "center",
                            { win = "input",   height = 1,          border = "bottom" },
                            { win = "list",    border = "none" },
                            { win = "preview", title = "{preview}", width = 0.6,      height = 0.4, border = "top" },
                        }
                    },
                    telescope = {
                        reverse = true, -- set to false for search bar to be on top
                        layout = {
                            box = "horizontal",
                            backdrop = false,
                            width = 0.8,
                            height = 0.9,
                            border = "none",
                            {
                                box = "vertical",
                                { win = "list",  title = " Results ", title_pos = "center", border = "rounded" },
                                { win = "input", height = 1,          border = "rounded",   title = "{title} {live} {flags}", title_pos = "center" },
                            },
                            {
                                win = "preview",
                                title = "{preview:Preview}",
                                width = 0.50,
                                border = "rounded",
                                title_pos = "center",
                            },
                        },
                    },
                    ivy = {
                        layout = {
                            box = "vertical",
                            backdrop = false,
                            width = 0,
                            height = 0.4,
                            position = "bottom",
                            border = "top",
                            title = " {title} {live} {flags}",
                            title_pos = "left",
                            { win = "input", height = 1, border = "bottom" },
                            {
                                box = "horizontal",
                                { win = "list",    border = "none" },
                                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
                            },
                        },
                    },
                }
            },
            dashboard = {
                enabled = true,
                sections = {
                    { section = "header" },
                    { section = "keys",   gap = 1, padding = 1 },
                    { section = "startup" },
                },
            },
        },
        -- NOTE: Keymaps
        keys = {
            { "<leader><space>", function() require("snacks").picker.smart() end, desc = "󰍉 Smart Find Files" },
            { "<leader>rN", function() require("snacks").rename.rename_file() end, desc = " Fast Rename Current File" },
            { "<leader>bq", function() require("snacks").bufdelete() end, desc = "󰅖 Delete or Close Buffer (Confirm)" },

            -- Snacks Picker
            { "<leader>ff", function() require("snacks").picker.files() end, desc = "󰈞 Find Files (Snacks Picker)" },
            { "<leader>fw", function() require("snacks").picker.grep() end, desc = "󰱼 Grep Word" },
            { "<leader>fc", function() require("snacks").picker.grep_word() end, desc = "󰈬 Search Visual Selection or Word", mode = { "n", "x" } },
            { "<leader>fk", function() require("snacks").picker.keymaps({ layout = "ivy" }) end, desc = " Search Keymaps (Snacks Picker)" },

            -- Git Stuff
            { "<leader>gg", function() require("snacks").lazygit() end, desc = " Lazygit" },
            { "<leader>gb", function() require("snacks").git.blame_line() end, desc = " Git Blame" },
            { "<leader>gl", function() require("snacks").lazygit.log() end, desc = "󰦻 Lazygit Logs" },

            -- Other Utils
            { "<leader>fh", function() require("snacks").picker.help() end, desc = "󰋖 Help Pages" },
        }
    },
    -- NOTE: todo comments w/ snacks
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPre", "BufNewFile" },
        optional = true,
        keys = {
            { "<leader>ft", function() require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
        },
    },
    {
        "fnune/recall.nvim",
        branch = "main",
        config = function()
            local recall = require("recall")

            recall.setup({
                sign = "",
                sign_highlight = "@label",

                snacks = {
                    mappings = {
                        unmark_selected_entry = {
                            insert = "<C-d>",
                        },
                    },
                },
            })
            vim.keymap.set("n", "<leader>mm", recall.goto_next, { noremap = true, silent = true, desc = " Next Mark" })
            vim.keymap.set("n", "<leader>mn", recall.goto_prev, { noremap = true, silent = true, desc = " Prev Mark" })
            vim.keymap.set("n", "<leader>ma", recall.toggle, { noremap = true, silent = true, desc = " Toggle Mark" })
            vim.keymap.set("n", "<leader>ml", require("recall.snacks").pick,
                { noremap = true, silent = true, desc = " Mark List" })
        end,
    }
}
