local function picker_hint(opts)
    local hint = {
        { " ", "SnacksFooter" },
        { " <C-v> ", "SnacksFooterKey" },
        { "vertical", "SnacksFooterDesc" },
    }

    local function add(key, description)
        hint[#hint + 1] = { "  " .. key .. " ", "SnacksFooterKey" }
        hint[#hint + 1] = { description, "SnacksFooterDesc" }
    end

    local source = opts.source
    if source ~= "git_status" and source ~= "git_diff" then
        add("<Tab>", "select")
    end

    if source == "explorer" then
        add("<leader>ma", "mark")
    elseif source == "files" or source == "recent" or source == "smart" then
        add(".lua$", "type")
        add("^src/", "prefix")
        add("<A-r>", "regex")
    elseif source == "grep" or source == "grep_word" or source == "grep_buffers" then
        add("query -- -g '*.lua'", "type")
        add("<A-r>", "regex")
    elseif source == "buffers" then
        add("dd", "delete")
    elseif source == "diagnostics" or source == "diagnostics_buffer" then
        add("<C-q>", "quickfix")
    elseif source == "git_status" or source == "git_diff" then
        add("<Tab>", "stage")
        add("<C-r>", "restore")
    elseif source == "keymaps" then
        add("<A-g>", "global")
        add("<A-b>", "buffer")
    elseif source == "marks" then
        add("<C-x>", "delete")
    elseif opts.title == "Global Marks" then
        add("A-Z", "jump")
        add("dd", "delete")
    end

    add("?", "help")
    hint[#hint + 1] = { " ", "SnacksFooter" }
    return hint
end

local function show_picker_hints(opts)
    opts.win.list.footer = picker_hint(opts)
    opts.win.list.footer_pos = "center"

    local function add_footer_border(node)
        if type(node) ~= "table" then
            return
        end
        if node.win == "list" and (node.border == nil or node.border == "none") then
            node.border = "bottom"
        end
        for _, child in ipairs(node) do
            add_footer_border(child)
        end
    end

    for _, preset in pairs(opts.layouts or {}) do
        add_footer_border(preset.layout)
    end
    add_footer_border(opts.layout and opts.layout.layout)

    return opts
end

local function is_recall_marked(path)
    return require("flow.marks").is_marked(path)
end

local function toggle_explorer_mark(picker, item)
    if not item or item.dir then
        vim.notify("Recall marks can only be set on files", vim.log.levels.INFO)
        return
    end

    if require("flow.marks").toggle(item.file) then
        picker:find({ refresh = true })
    end
end

local function reveal_marked_files(picker)
    local actions = require("snacks.explorer.actions")
    local tree = require("snacks.explorer.tree")
    local cwd = vim.fs.normalize(picker:cwd())
    local include = vim.deepcopy(picker.opts.include or {})
    local included = {}

    for _, path in ipairs(include) do
        included[path] = true
    end

    local revealed = false
    for _, mark in ipairs(require("recall.utils").sorted_global_marks()) do
        local file = vim.fs.normalize(mark.info.file)
        if tree:in_cwd(cwd, file) and vim.uv.fs_stat(file) then
            tree:open(file)
            revealed = true

            local path = file
            while path and path ~= cwd do
                if not included[path] then
                    include[#include + 1] = path
                    included[path] = true
                end
                path = vim.fs.dirname(path)
            end
        end
    end

    if revealed then
        picker.opts.include = include
        actions.update(picker, { target = false, refresh = true })
    end
end

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
                config = show_picker_hints,
                sources = {
                    explorer = {
                        on_show = reveal_marked_files,
                        format = function(item, picker)
                            local marked = not item.dir and is_recall_marked(item.file)
                            local formatted = {
                                { marked and " " or "  ", marked and "@comment.note" or nil },
                            }
                            vim.list_extend(formatted, require("snacks").picker.format.file(item, picker))
                            return formatted
                        end,
                        actions = {
                            toggle_recall_mark = toggle_explorer_mark,
                        },
                        jump = {
                            close = true,
                        },
                        layout = {
                            preset = "telescope",
                            preview = true,
                        },
                        win = {
                            list = {
                                keys = {
                                    ["<leader>ma"] = {
                                        "toggle_recall_mark",
                                        desc = "Toggle Recall mark",
                                    },
                                },
                            },
                        },
                    },
                    files = {
                        matcher = {
                            frecency = true,
                            sort_empty = true,
                        },
                        format = function(item, picker)
                            local formatted = require("snacks").picker.format.file(item, picker)
                            local recent = (item.frecency or 0) >= 0.5
                            table.insert(formatted, 1, {
                                recent and "󰋚 " or "  ",
                                recent and "SnacksPickerSpecial" or nil,
                            })
                            return formatted
                        end,
                        layout = {
                            preset = function()
                                return vim.o.columns >= 120 and "telescope" or "telescope_no_preview"
                            end,
                        },
                    },
                },
                matchers = {
                    frecency = true,
                    cwd_bonus = false,
                },
                formatters = {
                    file = {
                        filename_first = false,
                        filename_only = false,
                        icon_width = 2,
                        truncate = "left",
                        min_width = 60,
                    },
                },
                on_change = function(picker, item)
                    if not (item and item.file and picker.layout and picker.layout.root:win_valid()) then
                        return
                    end

                    local path = item.file
                    if vim.startswith(path, "/") then
                        path = vim.fs.relpath(picker:cwd() or vim.fn.getcwd(), path) or path
                    end

                    pcall(vim.api.nvim_win_set_config, picker.layout.root.win, {
                        title = " " .. path .. " ",
                        title_pos = "left",
                    })
                end,
                win = {
                    preview = {
                        wo = {
                            wrap = true,
                            linebreak = true,
                            breakindent = true,
                        },
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
                            border = "rounded",
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
                    telescope_no_preview = {
                        preview = false,
                        layout = {
                            box = "vertical",
                            backdrop = false,
                            width = 0.95,
                            height = 0.95,
                            border = "none",
                            { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
                            { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
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
            { "<leader>lf", function() require("flow.format").format() end, desc = "Format buffer" },
            { "<leader>lca", function() vim.lsp.buf.code_action() end, desc = "󰈬 LSP Code Actions" },
            { "<leader>lcr", function() vim.lsp.buf.rename() end, desc = "󰈬 LSP Rename" },
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
            local marking = require("recall.marking")

            recall.setup({
                sign = "",
                sign_highlight = "@comment.note",

                snacks = {
                    mappings = {
                        unmark_selected_entry = {
                            normal = "dd",
                            insert = "<C-d>",
                        },
                    },
                },
            })

            local function marks_picker()
                local marks = utils.sorted_global_marks()
                local actions = {}
                local jump_keys = {}

                local function jump_to_mark(picker, mark)
                    picker:close()
                    vim.schedule(function()
                        local file = mark.info.file
                        if not file or file == "" then
                            return
                        end

                        vim.cmd.edit(vim.fn.fnameescape(file))
                        vim.api.nvim_win_set_cursor(0, {
                            mark.info.pos[2],
                            math.max(mark.info.pos[3] - 1, 0),
                        })
                    end)
                end

                for _, mark in ipairs(marks) do
                    local current_mark = mark
                    local action = "jump_mark_" .. current_mark.char
                    actions[action] = function(picker)
                        jump_to_mark(picker, current_mark)
                    end
                    jump_keys[current_mark.char] = {
                        action,
                        mode = { "n" },
                        nowait = true,
                        desc = "Jump to mark " .. current_mark.char,
                    }
                end

                actions.delete_mark = function(picker, item)
                    if not item then
                        return
                    end
                    vim.cmd("delmarks " .. item.char)
                    marking.on_mark_update()
                    picker:find({ refresh = true })
                end

                local delete_key = {
                    "delete_mark",
                    mode = { "n" },
                    desc = "Delete mark",
                }
                local list_keys = vim.tbl_extend("force", {}, jump_keys, { dd = delete_key })

                require("snacks").picker.pick({
                    title = "Global Marks",
                    focus = "list",
                    finder = function()
                        local items = {}
                        for _, mark in ipairs(utils.sorted_global_marks()) do
                            items[#items + 1] = {
                                char = mark.char,
                                text = mark.char .. " " .. mark.info.file,
                                pos = { mark.info.pos[2], mark.info.pos[3] },
                                file = mark.info.file,
                            }
                        end
                        return items
                    end,
                    format = function(item, picker)
                        local formatted = {
                            { ("[%s]"):format(item.char), "SnacksPickerLabel" },
                            { " ", virtual = true },
                        }
                        vim.list_extend(formatted, require("snacks").picker.format.file(item, picker))
                        return formatted
                    end,
                    actions = actions,
                    on_show = function(picker)
                        picker:focus("list")
                        vim.cmd.stopinsert()
                    end,
                    win = {
                        input = { keys = jump_keys },
                        list = { keys = list_keys },
                    },
                })
            end

            local function goto_nth(n)
                local marks = utils.sorted_global_marks()

                if #marks < n then
                    vim.notify(
                        ("No %dth Recall mark set"):format(n),
                        vim.log.levels.WARN
                    )
                    return
                end

                local mark = marks[n].info
                local file = mark.file

                if not file or file == "" then
                    return
                end

                vim.cmd.edit(vim.fn.fnameescape(file))

                vim.api.nvim_win_set_cursor(0, {
                    mark.pos[2],
                    math.max(mark.pos[3] - 1, 0),
                })
            end

            vim.keymap.set(
                "n",
                "<leader>mm",
                recall.goto_next,
                { silent = true, desc = " Next Mark" }
            )

            vim.keymap.set(
                "n",
                "<leader>mn",
                recall.goto_prev,
                { silent = true, desc = " Prev Mark" }
            )

            vim.keymap.set(
                "n",
                "<leader>ma",
                recall.toggle,
                { silent = true, desc = " Toggle Mark" }
            )

            vim.keymap.set(
                "n",
                "<leader>mc",
                recall.clear,
                { silent = true, desc = " Remove Marks" }
            )

            vim.keymap.set(
                "n",
                "<leader>ml",
                marks_picker,
                { silent = true, desc = " Mark List" }
            )

            vim.keymap.set(
                "n",
                "<leader>fm",
                marks_picker,
                { silent = true, desc = " Mark List" }
            )

            vim.keymap.set(
                "n",
                "<leader>mq",
                function() goto_nth(1) end,
                { silent = true, desc = "Jump to 1st Recall Mark" }
            )

            vim.keymap.set(
                "n",
                "<leader>mw",
                function() goto_nth(2) end,
                { silent = true, desc = "Jump to 2nd Recall Mark" }
            )

            vim.keymap.set(
                "n",
                "<leader>me",
                function() goto_nth(3) end,
                { silent = true, desc = "Jump to 3rd Recall Mark" }
            )

            vim.keymap.set(
                "n",
                "<leader>mr",
                function() goto_nth(4) end,
                { silent = true, desc = "Jump to 4th Recall Mark" }
            )
        end,
    }
}
