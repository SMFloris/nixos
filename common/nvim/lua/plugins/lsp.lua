return {
    {
        'mason-org/mason.nvim',
        config = function()
            require("mason").setup()
        end
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = "v4.x",
        lazy = true,
        config = false
    },
    {
        "hrsh7th/nvim-cmp",
        -- event = "InsertEnter",
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lua',
            "hrsh7th/cmp-buffer",           -- source for text in buffer
            "hrsh7th/cmp-path",             -- source for file system paths
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",     -- autocompletion
            "rafamadriz/friendly-snippets", -- snippets
            "nvim-treesitter/nvim-treesitter",
            "onsails/lspkind.nvim",         -- vs-code pictograms
            "roobert/tailwindcss-colorizer-cmp.nvim",
        },
        config = function()
            local cmp = require("cmp")
            -- local luasnip = require("luasnip")
            local has_luasnip, luasnip = pcall(require, 'luasnip')
            local lspkind = require("lspkind")
            local colorizer = require("tailwindcss-colorizer-cmp").formatter

            local rhs = function(keys)
                return vim.api.nvim_replace_termcodes(keys, true, true, true)
            end

            local lsp_kinds = {
                Class = ' ',
                Color = ' ',
                Constant = ' ',
                Constructor = ' ',
                Enum = ' ',
                EnumMember = ' ',
                Event = ' ',
                Field = ' ',
                File = ' ',
                Folder = ' ',
                Function = ' ',
                Interface = ' ',
                Keyword = ' ',
                Method = ' ',
                Module = ' ',
                Operator = ' ',
                Property = ' ',
                Reference = ' ',
                Snippet = ' ',
                Struct = ' ',
                Text = ' ',
                TypeParameter = ' ',
                Unit = ' ',
                Value = ' ',
                Variable = ' ',
            }
            -- Returns the current column number.
            local column = function()
                local _line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col
            end


            -- luasnip custom function
            local in_snippet = function()
                local session = require('luasnip.session')
                local node = session.current_nodes[vim.api.nvim_get_current_buf()]
                if not node then
                    return false
                end
                local snippet = node.parent.snippet
                local snip_begin_pos, snip_end_pos = snippet.mark:pos_begin_end()
                local pos = vim.api.nvim_win_get_cursor(0)
                if pos[1] - 1 >= snip_begin_pos[1] and pos[1] - 1 <= snip_end_pos[1] then
                    return true
                end
            end

            -- returns true if the cursor is in leftmost column or at a whitespace char
            local in_whitespace = function()
                local col = column()
                return col == 0 or vim.api.nvim_get_current_line():sub(col, col):match('%s')
            end

            local in_leading_indent = function()
                local col = column()
                local line = vim.api.nvim_get_current_line()
                local prefix = line:sub(1, col)
                return prefix:find('^%s*$')
            end

            -- custom shift width
            local shift_width = function()
                if vim.o.softtabstop <= 0 then
                    return vim.fn.shiftwidth()
                else
                    return vim.o.softtabstop
                end
            end

            -- custom smart backspace
            local smart_bs = function(dedent)
                local keys = nil
                if vim.o.expandtab then
                    if dedent then
                        keys = rhs('<C-D>')
                    else
                        keys = rhs('<BS>')
                    end
                else
                    local col = column()
                    local line = vim.api.nvim_get_current_line()
                    local prefix = line:sub(1, col)
                    if in_leading_indent() then
                        keys = rhs('<BS>')
                    else
                        local previous_char = prefix:sub(#prefix, #prefix)
                        if previous_char ~= ' ' then
                            keys = rhs('<BS>')
                        else
                            keys = rhs('<C-\\><C-o>:set expandtab<CR><BS><C-\\><C-o>:set noexpandtab<CR>')
                        end
                    end
                end
                vim.api.nvim_feedkeys(keys, 'nt', true)
            end

            -- custom smart tabs function
            local smart_tab = function(opts)
                local keys = nil
                if vim.o.expandtab then
                    keys = '<Tab>' -- Neovim will insert spaces.
                else
                    local col = column()
                    local line = vim.api.nvim_get_current_line()
                    local prefix = line:sub(1, col)
                    local in_leading_indent = prefix:find('^%s*$')
                    if in_leading_indent then
                        -- inserts a hard tab.
                        keys = '<Tab>'
                    else
                        local sw = shift_width()
                        local previous_char = prefix:sub(#prefix, #prefix)
                        local previous_column = #prefix - #previous_char + 1
                        local current_column = vim.fn.virtcol({ vim.fn.line('.'), previous_column }) + 1
                        local remainder = (current_column - 1) % sw
                        local move = remainder == 0 and sw or sw - remainder
                        keys = (' '):rep(move)
                    end
                end

                vim.api.nvim_feedkeys(rhs(keys), 'nt', true)
            end

            local select_next_item = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    fallback()
                end
            end

            local select_prev_item = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end

            -- NOTE: Until https://github.com/hrsh7th/nvim-cmp/issues/1716
            -- (cmp.ConfirmBehavior.MatchSuffix) gets implemented, use this local wrapper
            -- to choose between `cmp.ConfirmBehavior.Insert` and `cmp.ConfirmBehavior.Replace`:
            local confirm = function(entry)
                local behavior = cmp.ConfirmBehavior.Replace
                if entry then
                    local completion_item = entry.completion_item
                    local newText = ''
                    if completion_item.textEdit then
                        newText = completion_item.textEdit.newText
                    elseif type(completion_item.insertText) == 'string' and completion_item.insertText ~= '' then
                        newText = completion_item.insertText
                    else
                        newText = completion_item.word or completion_item.label or ''
                    end

                    -- checks how many characters will be different after the cursor position if we replace?
                    local diff_after = math.max(0, entry.replace_range['end'].character + 1) - entry.context.cursor.col

                    -- does the text that will be replaced after the cursor match the suffix
                    -- of the `newText` to be inserted ? if not, then `Insert` instead.
                    if entry.context.cursor_after_line:sub(1, diff_after) ~= newText:sub(-diff_after) then
                        behavior = cmp.ConfirmBehavior.Insert
                    end
                end
                cmp.confirm({ select = true, behavior = behavior })
            end


            -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                experimental = {
                    -- HACK: experimenting with ghost text
                    -- look at `toggle_ghost_text()` function below.
                    ghost_text = false,
                },
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                window = {
                    documentation = {
                        border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
                    },
                    completion = {
                        border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
                    }

                },
                -- config nvim cmp to work with snippet engine
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                -- autocompletion sources
                sources = cmp.config.sources({
                    { name = "luasnip" }, -- snippets
                    { name = "nvim_lsp" },
                    { name = "buffer" },  -- text within current buffer
                    { name = "path" },    -- file system paths
                    { name = "tailwindcss-colorizer-cmp" },
                }),
                -- mapping = cmp.mapping.preset.insert({
                --     ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
                --     ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
                --     ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                --     ["<C-f>"] = cmp.mapping.scroll_docs(4),
                --     ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
                --     ["<C-e>"] = cmp.mapping.abort(), -- close completion window
                --     ["<CR>"] = cmp.mapping.confirm({ select = false }),
                -- }),

                -- NOTE: ! Experimenting with Customized Mappings ! --
                mapping = cmp.mapping.preset.insert({
                    -- ['<BS>'] = cmp.mapping(function(_fallback)
                    --     smart_bs()
                    -- end, { 'i', 's' }),

                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),

                    ["<C-e>"] = cmp.mapping.abort(), -- close completion window

                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-j>'] = cmp.mapping(select_next_item),
                    ['<C-k>'] = cmp.mapping(select_prev_item),
                    ['<C-n>'] = cmp.mapping(select_next_item),
                    ['<C-p>'] = cmp.mapping(select_prev_item),
                    ['<Down>'] = cmp.mapping(select_next_item),
                    ['<Up>'] = cmp.mapping(select_prev_item),

                    ['<C-y>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            local entry = cmp.get_selected_entry()
                            confirm(entry)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),

                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif has_luasnip and in_snippet() and luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        elseif in_leading_indent() then
                            smart_bs(true) -- true means to dedent
                        elseif in_whitespace() then
                            smart_bs()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),

                    ['<Tab>'] = cmp.mapping(function(_fallback)
                        if cmp.visible() then
                            -- if there is only one completion candidate then use it.
                            local entries = cmp.get_entries()
                            if #entries == 1 then
                                confirm(entries[1])
                            else
                                cmp.select_next_item()
                            end
                        elseif has_luasnip and luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        elseif in_whitespace() then
                            smart_tab()
                        else
                            cmp.complete()
                        end
                    end, { 'i', 's' }),
                }),
                -- setup lspkind for vscode pictograms in autocompletion dropdown menu
                formatting = {
                    format = function(entry, vim_item)
                        -- Add custom lsp_kinds icons
                        vim_item.kind = string.format('%s %s', lsp_kinds[vim_item.kind] or '', vim_item.kind)


                        -- add menu tags (e.g., [Buffer], [LSP])
                        vim_item.menu = ({
                            buffer = "[Buffer]",
                            nvim_lsp = "[LSP]",
                            luasnip = "[LuaSnip]",
                            nvim_lua = "[Lua]",
                            latex_symbols = "[LaTeX]",
                        })[entry.source.name]

                        -- use lspkind and tailwindcss-colorizer-cmp for additional formatting
                        vim_item = lspkind.cmp_format({
                            maxwidth = 30,
                            ellipsis_char = "...",
                        })(entry, vim_item)

                        if entry.source.name == "nvim_lsp" then
                            vim_item = colorizer(entry, vim_item)
                        end

                        return vim_item
                    end,
                    -- format = lspkind.cmp_format({
                    --         maxwidth = 30,
                    --         ellipsis_char = "...",
                    --         before = require("tailwindcss-colorizer-cmp").formatter
                    -- }),
                    -- format = require("tailwindcss-colorizer-cmp").formatter
                },
            })

            -- NOTE: Added Ghost text stuff
            -- Only show ghost text at word boundaries, not inside keywords. Based on idea
            -- from: https://github.com/hrsh7th/nvim-cmp/issues/2035#issuecomment-2347186210

            local config = require('cmp.config')
            local toggle_ghost_text = function()
                if vim.api.nvim_get_mode().mode ~= 'i' then
                    return
                end

                local cursor_column = vim.fn.col('.')
                local current_line_contents = vim.fn.getline('.')
                local character_after_cursor = current_line_contents:sub(cursor_column, cursor_column)

                local should_enable_ghost_text = character_after_cursor == '' or
                    vim.fn.match(character_after_cursor, [[\k]]) == -1

                local current = config.get().experimental.ghost_text
                if current ~= should_enable_ghost_text then
                    config.set_global({
                        experimental = {
                            ghost_text = should_enable_ghost_text,
                        },
                    })
                end
            end

            vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI' }, {
                callback = toggle_ghost_text,
            })
            -- ! Ghost text stuff ! --
        end,
    },
    {
        'neovim/nvim-lspconfig',
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { 'mason-org/mason-lspconfig.nvim' },
            { 'nvim-treesitter/nvim-treesitter' },
        },
        config = function()
            local lsp = require('lsp-zero')
            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            parser_config.nu = {
                install_info = {
                    url = "https://github.com/nushell/tree-sitter-nu",
                    files = { "src/parser.c" },
                    branch = "main",
                },
                filetype = "nu",
            }

            local format_sync_grp = vim.api.nvim_create_augroup("Format", {})
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*",
                callback = function()
                    vim.lsp.buf.format({ timeout_ms = 200 })
                end,
                group = format_sync_grp,
            })

            local Snacks = require("snacks")
            local lsp_attach = function(client, bufnr)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition,
                    { buffer = bufnr, remap = false, desc = "Go to definition" })
                vim.keymap.set("n", "K", vim.lsp.buf.hover,
                    { buffer = bufnr, remap = false, desc = "Hover documentation" })
                vim.keymap.set("n", "<leader>lw", Snacks.picker.lsp_workspace_symbols,
                    { buffer = bufnr, remap = false, desc = "LSP workspace symbols" })
                vim.keymap.set("n", "<leader>ld", Snacks.picker.diagnostics,
                    { buffer = bufnr, remap = false, desc = "Workspace diagnostics" })
                vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
                    { buffer = bufnr, remap = false, desc = "Previous diagnostic" })
                vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
                    { buffer = bufnr, remap = false, desc = "Next diagnostic" })
                vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action,
                    { buffer = bufnr, remap = false, desc = "Code actions" })
                vim.keymap.set("n", "<leader>lcr", vim.lsp.buf.references,
                    { buffer = bufnr, remap = false, desc = "Find references" })
                vim.keymap.set("n", "<leader>lcR", vim.lsp.buf.rename,
                    { buffer = bufnr, remap = false, desc = "Rename symbol" })
                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help,
                    { buffer = bufnr, remap = false, desc = "Signature help" })
                client.server_capabilities.semanticTokensProvider = nil
            end


            lsp.extend_lspconfig({
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
                lsp_attach = lsp_attach,
                float_border = 'rounded',
                sign_text = true,
                set_lsp_keymaps = { preserve_mappings = false }
            })

            local lspconfig = require("lspconfig")

            lspconfig.nushell.setup({
                command = { "nu", "--lsp" },
                filetypes = { "nu" },
                root_dir = require("lspconfig.util").find_git_ancestor,
                single_file_support = true,
            })

            vim.lsp.config('c3_lsp', {
                cmd = { 'c3-lsp' },
                root_markers = { 'project.json', 'manifest.json', '.git' },
                filetypes = { 'c3', 'c3i' },
            })

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                update_in_insert = true,
                underline = true,
                severity_sort = false,
                float = true,
            })

            require('mason-lspconfig').setup({
                ensure_installed = { 'lua_ls', 'gopls', 'terraformls', 'phpactor', 'nil_ls', 'pylsp', 'c3_lsp' },
                handlers = {
                    function(server_name)
                        lspconfig[server_name].setup({})
                    end,

                    gopls = lsp.noop,
                    c3_lsp = lsp.noop,
                    rust_analyzer = lsp.noop,

                    yamlls = function()
                        require('lspconfig').yamlls.setup({
                            settings = {
                                yaml = {
                                    format = {
                                        enable = true,
                                    }
                                },
                            },
                        })
                    end,

                    lua_ls = function()
                        lspconfig.lua_ls.setup({
                            on_init = function(client)
                                lsp.nvim_lua_settings(client, {})
                            end
                        })
                    end,
                    nil_ls = function()
                        local nil_ls_opts = {
                            settings = {}
                        }
                        nil_ls_opts.settings['nil'] = {
                            formatting = {
                                command = { "nixpkgs-fmt" }
                            }
                        }
                        lspconfig.nil_ls.setup(nil_ls_opts)
                    end,
                }
            })
        end
    }
}
