return {
    -- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
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
            notifier = {
                enabled = true,
            },
            input = {
                enabled = true,
            },
            quickfile = {
                enabled = true,
                exclude = { "latex" },
            },
            explorer = {
                enabled = true,
                replace_netrw = false,
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
                        min_width = 1000,
                    },
                },
                layout = {
                    -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
                    -- override picker layout in keymaps function as a param below
                    preset = "telescope", -- defaults to this layout unless overidden
                    cycle = false,
                },
                layouts = {
                    select = {
                        preview = false,
                        layout = {
                            backdrop = false,
                            width = 0.95,
                            min_width = 120,
                            height = 0.5,
                            min_height = 15,
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
                        reverse = false,
                        layout = {
                            box = "horizontal",
                            backdrop = false,
                            width = 0.95,
                            height = 0.95,
                            border = "none",
                            {
                                box = "vertical",
                                { win = "input", height = 1,          border = "rounded",   title = "{title} {live} {flags}", title_pos = "center" },
                                { win = "list",  title = " Results ", title_pos = "center", border = "rounded" },
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
                            width = 0.95,
                            height = 0.5,
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
        },
        -- config = function()
        --     vim.notify = require("snacks.notifier").notify
        -- end,
        -- NOTE: Keymaps
        keys = {
            {
                "<leader><space>",
                function()
                    local picker = require("snacks").picker
                    if picker and picker.has_resume() then
                        picker.resume()
                    else
                        picker.smart()
                    end
                end,
                desc = "󰍉 Smart Find",
            },
            { "<leader>rN", function() require("snacks").rename.rename_file() end, desc = " Fast Rename Current File" },
            { "<leader>bq", function() require("snacks").bufdelete() end, desc = "󰅖 Delete or Close Buffer (Confirm)" },

            -- Snacks Picker
            { "<leader><leader>", function() require("snacks").picker.resume() end, desc = "󰍉 Resume Last Picker" },
            { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "󰈞 Find buffers (Snacks Picker)" },
            { "<leader>ff", function() require("snacks").picker.files() end, desc = "󰈞 Find Files (Snacks Picker)" },
            { "<leader>fw", function() require("snacks").picker.grep() end, desc = "󰱼 Grep Word" },
            { "<leader>fc", function() require("snacks").picker.grep_word() end, desc = "󰈬 Search Visual Selection or Word", mode = { "n", "x" } },
            { "<leader>fk", function() require("snacks").picker.keymaps({ layout = "ivy" }) end, desc = " Search Keymaps (Snacks Picker)" },
            { "<leader>ls", function() require("snacks").picker.lsp_symbols() end, desc = "󰈬 LSP Symbols" },
            { "<leader>lw", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "󰈬 LSP Workspace Symbols" },
            { "<leader>lh", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch C/C++ source/header" },
            { "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "LSP format" },
            { "<leader>lca",function() vim.lsp.buf.code_action() end, desc = "󰈬 LSP Code Actions" },
            { "<leader>lcr",function() vim.lsp.buf.rename() end, desc = "󰈬 LSP Rename" },
            { "<leader>ld", function() require("snacks").picker.diagnostics_buffer() end, desc = "󰈬 LSP Diagnostics (buffer)" },
            { "<leader>lD", function() require("snacks").picker.diagnostics() end, desc = "󰈬 LSP Workspace Diagnostics" },

            -- lsp
            { "gd", function() require("snacks").picker.lsp_definitions() end, desc = "Goto Definition" },
            { "gD", function() require("snacks").picker.lsp_declarations() end, desc = "Goto Declaration" },
            { "gr", function() require("snacks").picker.lsp_references() end, nowait = true, desc = "References" },
            { "gI", function() require("snacks").picker.lsp_implementations() end, desc = "Goto Implementation" },
            { "gy", function() require("snacks").picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
            { "gai", function() require("snacks").picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
            { "gao", function() require("snacks").picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },

            -- Git Stuff
            { "<leader>gg", function() require("snacks").lazygit() end, desc = " Lazygit" },
            { "<leader>gb", function() require("snacks").git.blame_line() end, desc = " Git Blame" },
            { "<leader>gl", function() require("snacks").lazygit.log() end, desc = "󰦻 Lazygit Logs" },
            { "<leader>gh", function() require("snacks").lazygit.log_file() end, desc = "󰦻 Lazygit File History" },
            { "<leader>gd", function() require("diffview").open() end, desc = " Diffview Open" },

            -- Other Utils
            { "<leader>d", function() require("snacks").dashboard() end, desc = "󰕮 Dashboard" },
            { "<leader>e", function() require("snacks").explorer() end, desc = "File Explorer" },
            { "<leader>fh", function() require("snacks").picker.help() end, desc = "󰋖 Help Pages" },
        }
    },
    {
        "folke/todo-comments.nvim",
        keys = {
            { "<leader>ft", function() require("snacks").picker.todo_comments() end,                                          desc = "Todo" },
            { "<leader>fT", function() require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
        },
    },
    {
        "fnune/recall.nvim",
        branch = "main",
        config = function()
            local recall = require("recall")
            local utils = require("recall.utils")

            local function goto_nth(n)
                local marks = utils.sorted_global_marks()
                if #marks >= n then
                    local mark = marks[n].info
                    vim.cmd("silent buffer " .. mark.file)
                    vim.api.nvim_win_set_cursor(0, { mark.pos[2], mark.pos[3] })
                else
                    print("No " .. n .. "th global mark set")
                end
            end

            local function goto_first() goto_nth(1) end
            local function goto_second() goto_nth(2) end
            local function goto_third() goto_nth(3) end
            local function goto_fourth() goto_nth(4) end

            recall.setup({
                sign = "",
                sign_highlight = "@comment.note",
                cwd = true, -- Enable per-project marks

                snacks = {
                    mappings = {
                        unmark_selected_entry = {
                            normal = "dd",
                            insert = "<C-d>",
                        },
                    },
                },
            })
            vim.keymap.set("n", "<leader>mm", recall.goto_next, { noremap = true, silent = true, desc = " Next Mark" })
            vim.keymap.set("n", "<leader>ml", require("recall.snacks").pick,
                { noremap = true, silent = true, desc = " Show Marks Picker" })
            vim.keymap.set("n", "<leader>mn", recall.goto_prev, { noremap = true, silent = true, desc = " Prev Mark" })
            vim.keymap.set("n", "<leader>ma", recall.toggle, { noremap = true, silent = true, desc = " Toggle Mark" })
            vim.keymap.set("n", "<leader>mc", recall.clear, { noremap = true, silent = true, desc = " Remove Mark" })
            vim.keymap.set("n", "<leader>fm", require("recall.snacks").pick,
                { noremap = true, silent = true, desc = " Mark List" })
            vim.keymap.set("n", "<leader>mq", goto_first,
                { noremap = true, silent = true, desc = "Jump to 1st Recall Mark" })
            vim.keymap.set("n", "<leader>mw", goto_second,
                { noremap = true, silent = true, desc = "Jump to 2nd Recall Mark" })
            vim.keymap.set("n", "<leader>me", goto_third,
                { noremap = true, silent = true, desc = "Jump to 3rd Recall Mark" })
            vim.keymap.set("n", "<leader>mr", goto_fourth,
                { noremap = true, silent = true, desc = "Jump to 4th Recall Mark" })
        end,
    }
}
