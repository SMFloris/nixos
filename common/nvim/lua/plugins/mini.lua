return {
    -- Mini Nvim
    { "echasnovski/mini.nvim", version = false },
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

            MiniFiles.setup({
                mappings = {
                    go_in = "l",
                    go_in_plus = "<CR>",
                    go_out = "",
                    go_out_plus = "h",
                },
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf = args.data.buf_id

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
