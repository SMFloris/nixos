return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim",           opts = {} },
            { "mason-org/mason-lspconfig.nvim", opts = {} },
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Profile paths from your neovim-profile-env.sh
            local profile = vim.fn.expand("$HOME/.nix-profile-neovim")
            local state = vim.fn.expand("$HOME/.local/state/neovim-profile")
            local npm_bin = state .. "/npm/bin"

            -- Helper function to find LSP server executable
            local function find_lsp_executable(server_name, default_paths)
                for _, path in ipairs(default_paths) do
                    if vim.fn.executable(path) == 1 then
                        return path
                    end
                end
                -- Return first default path as fallback (Mason will install it)
                return default_paths[1]
            end

            -- Configure Python LSP (pyright)
            local pyright_cmd = find_lsp_executable('pyright', {
                'pyright-langserver',
                npm_bin .. '/pyright-langserver',
                profile .. '/bin/pyright-langserver',
                vim.fn.expand('~/.npm-global/bin/pyright-langserver'),
                vim.fn.expand('~/.local/share/npm/bin/pyright-langserver'),
                '/nix/profile/bin/pyright-langserver',
            })
            vim.lsp.config('pyright', {
                cmd = { pyright_cmd, '--stdio' },
                filetypes = { 'python' },
                root_markers = {
                    { 'pyproject.toml' },
                    '.git',
                },
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = 'openFilesOnly',
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
                capabilities = capabilities,
            })

            -- Configure TypeScript LSP (vtsls)
            local vtsls_cmd = find_lsp_executable('vtsls', {
                'vtsls',
                profile .. '/bin/vtsls',
                vim.fn.expand('~/.npm-global/bin/vtsls'),
                vim.fn.expand('~/.local/share/npm/bin/vtsls'),
                '/nix/profile/bin/vtsls',
            })
            vim.lsp.config('vtsls', {
                cmd = { vtsls_cmd, '--stdio' },
                filetypes = {
                    'javascript',
                    'javascriptreact',
                    'javascript.jsx',
                    'typescript',
                    'typescriptreact',
                    'typescript.tsx',
                    'vue',
                    'svelte'
                },
                root_markers = {
                    { 'tsconfig.json', 'jsconfig.json', 'package.json', 'vite.config.ts', 'vite.config.js' },
                    '.git'
                },
                settings = {
                    typescript = {
                        preferences = {
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithInsertText = true,
                            includeCompletionsWithSnippetText = true,
                        },
                        updateImportsOnFileMove = {
                            enabled = "always",
                        },
                        suggest = {
                            autoImports = true,
                            completeFunctionCalls = true,
                        },
                    },
                    javascript = {
                        preferences = {
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithInsertText = true,
                            includeCompletionsWithSnippetText = true,
                        },
                        updateImportsOnFileMove = {
                            enabled = "always",
                        },
                        suggest = {
                            autoImports = true,
                            completeFunctionCalls = true,
                        },
                    },
                    vtsls = {
                        experimental = {
                            completion = {
                                enableServerSideFuzzyMatch = true,
                            },
                        },
                    },
                },
                capabilities = capabilities,
            })

            -- Configure Nix LSP (nil_ls)
            local nil_cmd = find_lsp_executable('nil', {
                'nil',
                profile .. '/bin/nil',
                '/nix/profile/bin/nil',
            })
            vim.lsp.config('nil_ls', {
                cmd = { nil_cmd },
                filetypes = { 'nix' },
                root_markers = {
                    { 'flake.nix', 'shell.nix', '.git' }
                },
                settings = {
                    ['nil'] = {
                        formatting = {
                            command = { 'alejandra' },
                        },
                    },
                },
                capabilities = capabilities,
            })

            -- Configure Lua LSP (lua_ls)
            local lua_cmd = find_lsp_executable('lua-language-server', {
                'lua-language-server',
                profile .. '/bin/lua-language-server',
                '/nix/profile/bin/lua-language-server',
            })
            vim.lsp.config('lua_ls', {
                cmd = { lua_cmd },
                filetypes = { 'lua' },
                root_markers = {
                    { '.luarc.json', '.luarc.jsonc', '.luarc.json', '.luarc.jsonc' },
                    '.git'
                },
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT',
                        },
                        workspace = {
                            checkThirdParty = false,
                        },
                        completion = {
                            callSnippet = 'Replace',
                        },
                    },
                },
                capabilities = capabilities,
            })

            -- Enable all configured LSP servers
            vim.lsp.enable('pyright')
            vim.lsp.enable('vtsls')
            vim.lsp.enable('nil_ls')
            vim.lsp.enable('lua_ls')

            vim.lsp.config('clangd', {
                cmd = { 'clangd', '--query-driver=/nix/store/*/bin/g++', '--query-driver=/nix/store/*/bin/gcc'}
            })
            vim.lsp.enable('clangd')
            vim.lsp.enable('texlab')


            -- Setup Mason to ensure LSP servers are installed
            require("mason-lspconfig").setup {
                ensure_installed = { "pyright", "vtsls", "nil_ls", "lua_ls" },
                automatic_install = true,
            }
        end,
    }
}
