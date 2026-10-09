return {
    -- Mini Nvim
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function()
            require("mini.ai").setup({})
            require("mini.bracketed").setup({})
            require("mini.surround").setup({
                mappings = {
                    add = "ys",
                    delete = "ds",
                    replace = "cs",
                    find = "",
                    find_left = "",
                    highlight = "",
                    suffix_last = "",
                    suffix_next = "",
                },
                search_method = "cover_or_next",
            })
            vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "Surround line" })

            local jump2d = require("mini.jump2d")

            jump2d.setup({
                mappings = {
                    start_jumping = "",
                },
            })

            local function start_jump(backward)
                local ok, char = pcall(vim.fn.getcharstr)
                if not ok or char == "\027" or char == "\003" then
                    return
                end

                local cursor = vim.api.nvim_win_get_cursor(0)
                local spotter = jump2d.gen_spotter.pattern(vim.pesc(char))

                jump2d.start({
                    spotter = function(line_num, args)
                        local spots = spotter(line_num, args)
                        if line_num ~= cursor[1] then
                            return spots
                        end
                        return vim.tbl_filter(function(col)
                            if backward then
                                return col < cursor[2] + 1
                            end
                            return col > cursor[2] + 1
                        end, spots)
                    end,
                    allowed_lines = {
                        blank = false,
                        fold = false,
                        cursor_before = backward,
                        cursor_after = not backward,
                    },
                    allowed_windows = {
                        not_current = false,
                    },
                })
            end

            vim.keymap.set({ "n", "x", "o" }, "s", function() start_jump(false) end,
                { desc = "Jump forward to character" })
            vim.keymap.set({ "n", "x", "o" }, "S", function() start_jump(true) end,
                { desc = "Jump backward to character" })

            local function goto_edge_mark(first)
                local marks = require("recall.utils").sorted_global_marks()
                if #marks == 0 then
                    vim.notify("No global marks set", vim.log.levels.INFO)
                    return
                end

                local mark = first and marks[1] or marks[#marks]
                vim.cmd.normal({ "`" .. mark.char, bang = true })
            end

            vim.keymap.set("n", "]m", function() require("recall").goto_next() end, { desc = "Next mark" })
            vim.keymap.set("n", "[m", function() require("recall").goto_prev() end, { desc = "Previous mark" })
            vim.keymap.set("n", "]M", function() goto_edge_mark(false) end, { desc = "Last mark" })
            vim.keymap.set("n", "[M", function() goto_edge_mark(true) end, { desc = "First mark" })
        end,
    },
    -- Comments
    {
        'echasnovski/mini.comment',
        version = false,
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            -- disable the autocommand from ts-context-commentstring
            require('ts_context_commentstring').setup {
                enable_autocmd = false,
            }

            require("mini.comment").setup {
                -- tsx, jsx, html , svelte comment support
                options = {
                    custom_commentstring = function()
                        return require('ts_context_commentstring.internal').calculate_commentstring({
                                key =
                                'commentstring'
                            })
                            or vim.bo.commentstring
                    end,
                },
            }
        end
    },
    -- File explorer (this works properly with oil unlike nvim-tree)
    {
        "echasnovski/mini.files",
        config = function()
            local MiniFiles = require("mini.files")

            local function is_recall_marked(path)
                return require("flow.marks").is_marked(path)
            end

            MiniFiles.setup({
                content = {
                    prefix = function(entry)
                        local icon, highlight = MiniFiles.default_prefix(entry)
                        if entry.fs_type == "file" and is_recall_marked(entry.path) then
                            return " " .. icon, "@comment.note"
                        end
                        return "  " .. icon, highlight
                    end,
                },
                mappings = {
                    go_in = "l",
                    go_in_plus = "<CR>",
                    go_out = "",
                    go_out_plus = "h",
                },
            })

            local hint_buf, hint_win

            local function close_hint()
                if hint_win and vim.api.nvim_win_is_valid(hint_win) then
                    vim.api.nvim_win_close(hint_win, true)
                end
                hint_win = nil
            end

            local function show_hint()
                if not MiniFiles.get_explorer_state() then
                    return
                end
                close_hint()

                local hints
                if vim.o.columns >= 120 then
                    hints = " ↵/l open  h back  C-v vertical  <leader>ma mark  m set bookmark  ' jump  dd delete  = apply  g? help "
                elseif vim.o.columns >= 80 then
                    hints = " ↵ open  h back  C-v vertical  <leader>ma mark  m/' bookmarks  = apply  g? help "
                else
                    hints = " ↵ open  h back  <leader>ma mark  = apply  g? help "
                end

                if not hint_buf or not vim.api.nvim_buf_is_valid(hint_buf) then
                    hint_buf = vim.api.nvim_create_buf(false, true)
                    vim.bo[hint_buf].bufhidden = "wipe"
                end

                vim.api.nvim_buf_set_lines(hint_buf, 0, -1, false, { hints })

                local width = math.min(vim.o.columns, vim.fn.strdisplaywidth(hints))
                hint_win = vim.api.nvim_open_win(hint_buf, false, {
                    relative = "editor",
                    row = math.max(0, vim.o.lines - vim.o.cmdheight - 2),
                    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
                    width = width,
                    height = 1,
                    style = "minimal",
                    focusable = false,
                    zindex = 250,
                })
                vim.wo[hint_win].winhighlight = "Normal:MiniFilesBorder"
            end

            local function import_global_marks()
                local ok, recall_utils = pcall(require, "recall.utils")
                if not ok then
                    return
                end

                for _, mark in ipairs(recall_utils.sorted_global_marks()) do
                    local file = mark.info.file
                    if file and file ~= "" then
                        local directory = vim.fn.fnamemodify(file, ":p:h")
                        if vim.fn.isdirectory(directory) == 1 then
                            MiniFiles.set_bookmark(mark.char, directory, {
                                desc = ("Global mark %s: %s"):format(mark.char, vim.fn.fnamemodify(file, ":~:.")),
                            })
                        end
                    end
                end
            end

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesExplorerOpen",
                callback = function()
                    import_global_marks()
                    vim.schedule(show_hint)
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesExplorerClose",
                callback = close_hint,
            })

            vim.api.nvim_create_autocmd("VimResized", {
                callback = function()
                    if MiniFiles.get_explorer_state() then
                        show_hint()
                    end
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf = args.data.buf_id

                    local function map_open_in_split(lhs, direction, description)
                        vim.keymap.set("n", lhs, function()
                            local entry = MiniFiles.get_fs_entry()
                            if not entry then
                                return
                            end

                            if entry.fs_type ~= "file" then
                                MiniFiles.go_in()
                                return
                            end

                            local state = MiniFiles.get_explorer_state()
                            local new_target = vim.api.nvim_win_call(state.target_window, function()
                                vim.cmd(direction .. " split")
                                return vim.api.nvim_get_current_win()
                            end)

                            MiniFiles.set_target_window(new_target)
                            MiniFiles.go_in({ close_on_file = true })
                        end, {
                            buffer = buf,
                            desc = description,
                        })
                    end

                    map_open_in_split("<C-v>", "belowright vertical", "Open in vertical split")
                    map_open_in_split("<C-s>", "belowright horizontal", "Open in horizontal split")
                    map_open_in_split("<C-t>", "tab", "Open in new tab")

                    vim.keymap.set("n", "<leader>ma", function()
                        local entry = MiniFiles.get_fs_entry()
                        if not entry or entry.fs_type ~= "file" then
                            vim.notify("Recall marks can only be set on files", vim.log.levels.INFO)
                            return
                        end

                        if require("flow.marks").toggle(entry.path) then
                            MiniFiles.refresh({
                                content = {
                                    prefix = MiniFiles.config.content.prefix,
                                },
                            })
                        end
                    end, {
                        buffer = buf,
                        desc = "Toggle Recall mark",
                    })

                    vim.keymap.set("n", "<Right>", MiniFiles.go_in, {
                        buffer = buf,
                        desc = "Go in",
                    })

                    vim.keymap.set("n", "<Left>", function()
                        MiniFiles.go_out()
                        MiniFiles.trim_right()
                    end, {
                        buffer = buf,
                        desc = "Go out plus",
                    })
                end,
            })

            local function open_minifiles_at_current_file()
                local path = vim.api.nvim_buf_get_name(0)
                if path == "" then
                    MiniFiles.open(vim.fn.getcwd(), false)
                    return
                end

                local cwd = vim.fn.getcwd()
                local file_dir = vim.fn.fnamemodify(path, ":h")
                local file_name = vim.fn.fnamemodify(path, ":t")

                local anchor = file_dir
                for _ = 1, 4 do
                    local parent = vim.fn.fnamemodify(anchor, ":h")
                    if parent ~= anchor and parent:sub(1, #cwd) == cwd then
                        anchor = parent
                    else
                        break
                    end
                end

                MiniFiles.open(anchor, false)

                local branch = { anchor }
                local current = anchor
                while current ~= file_dir do
                    local rel = file_dir:sub(#current + 2)
                    local next_comp = rel:match("^([^/]+)")
                    if not next_comp then
                        break
                    end
                    current = current .. "/" .. next_comp
                    table.insert(branch, current)
                end

                vim.schedule(function()
                    MiniFiles.set_branch(branch, { depth_focus = #branch })

                    local buf = vim.api.nvim_get_current_buf()
                    local line_count = vim.api.nvim_buf_line_count(buf)

                    for line = 1, line_count do
                        local entry = MiniFiles.get_fs_entry(buf, line)
                        if entry and entry.name == file_name then
                            vim.api.nvim_win_set_cursor(0, { line, 0 })
                            break
                        end
                    end
                end)
            end

            vim.keymap.set("n", "-", function()
                if not MiniFiles.close() then
                    open_minifiles_at_current_file()
                end
            end, { desc = "Toggle mini.files at current file" })
        end,
    },
    -- Get rid of whitespace
    {
        "echasnovski/mini.trailspace",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local miniTrailspace = require("mini.trailspace")

            miniTrailspace.setup({
                only_in_normal_buffers = true,
            })
            vim.keymap.set("n", "<leader>cw", function() miniTrailspace.trim() end, { desc = "Erase Whitespace" })

            -- Ensure highlight never reappears by removing it on CursorMoved
            vim.api.nvim_create_autocmd("CursorMoved", {
                pattern = "*",
                callback = function()
                    require("mini.trailspace").unhighlight()
                end,
            })
        end,
    },
}
