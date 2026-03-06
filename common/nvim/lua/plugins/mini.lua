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
        'echasnovski/mini.files',
        config = function()
            local MiniFiles = require("mini.files")
            MiniFiles.setup({
                mappings = {
                    go_in = "l", -- Map both Enter and L to enter directories or open files
                    go_in_plus = "<CR>",
                    go_out = "",
                    go_out_plus = "h",
                },
            })
            vim.keymap.set("n", "-", function()
                local path = vim.api.nvim_buf_get_name(0)
                local cwd = vim.fn.getcwd()
                local file_dir = vim.fn.fnamemodify(path, ":h")
                
                -- Find anchor: go up to 4 dirs from file_dir, but stay within cwd
                local anchor = file_dir
                for i = 1, 4 do
                    local parent = vim.fn.fnamemodify(anchor, ":h")
                    if parent:sub(1, #cwd) == cwd and parent ~= anchor then
                        anchor = parent
                    else
                        break
                    end
                end
                
                -- Open at anchor, then set branch to show from anchor to file_dir
                MiniFiles.open(anchor, false)
                
                -- Build branch from anchor to file_dir
                local branch = { anchor }
                local current = anchor
                while current ~= file_dir do
                    -- Get the relative path from current to file_dir
                    local rel = file_dir:sub(#current + 2)  -- +2 to skip the "/"
                    -- Get first path component
                    local next_comp = rel:match("^([^/]+)")
                    if next_comp then
                        current = current .. "/" .. next_comp
                        table.insert(branch, current)
                    else
                        break
                    end
                end
                
                -- Set branch with focus on file_dir (last element)
                vim.schedule(function()
                    MiniFiles.set_branch(branch, { depth_focus = #branch })
                end)
            end, { desc = "Toggle into currently opened file (showing up to 4 parent dirs)" })
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
