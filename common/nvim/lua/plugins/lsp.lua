return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
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
                -- Return first default path as fallback
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

            -- Configure PHP LSP (phpantom)
            vim.filetype.add({
                extension = {
                    ['blade.php'] = 'blade',
                },
            })
            local phphantom_cmd = find_lsp_executable('phpantom_lsp', {
                'phpantom_lsp',
                profile .. '/bin/phpantom_lsp',
                '/nix/profile/bin/phpantom_lsp',
            })
            vim.lsp.config('phpantom_lsp', {
                cmd = { phphantom_cmd },
                filetypes = { 'php', 'blade' },
                root_markers = {
                    { '.phpantom.toml', 'composer.json' },
                    '.git',
                },
                capabilities = capabilities,
            })

            -- Configure Go LSP (gopls)
            local gopls_cmd = find_lsp_executable('gopls', {
                'gopls',
                profile .. '/bin/gopls',
                '/nix/profile/bin/gopls',
            })
            vim.lsp.config('gopls', {
                cmd = { gopls_cmd },
                filetypes = { 'go' },
                root_markers = { 'go.mod', 'go.work', '.git' },
                capabilities = capabilities,
            })

            -- Configure C3 LSP
            local c3_lsp_cmd = find_lsp_executable('c3-lsp', {
                'c3-lsp',
                profile .. '/bin/c3-lsp',
                '/nix/profile/bin/c3-lsp',
            })
            vim.lsp.config('c3_lsp', {
                cmd = { c3_lsp_cmd },
                filetypes = { 'c3' },
                root_markers = { 'project.json', '.git' },
                capabilities = capabilities,
            })

            -- Configure YAML LSP (yamlls)
            local yamlls_cmd = find_lsp_executable('yaml-language-server', {
                'yaml-language-server',
                profile .. '/bin/yaml-language-server',
                '/nix/profile/bin/yaml-language-server',
            })
            vim.lsp.config('yamlls', {
                cmd = { yamlls_cmd, '--stdio' },
                filetypes = { 'yaml', 'yml' },
                root_markers = { '.yamllint', '.yaml-lint', '.git' },
                settings = {
                    yaml = {
                        schemas = {
                            kubernetes = '*.yaml',
                        },
                    },
                },
                capabilities = capabilities,
            })

            -- Configure Dockerfile LSP (dockerls)
            local dockerls_cmd = find_lsp_executable('docker-langserver', {
                'docker-langserver',
                profile .. '/bin/docker-langserver',
                '/nix/profile/bin/docker-langserver',
            })
            vim.lsp.config('dockerls', {
                cmd = { dockerls_cmd, '--stdio' },
                filetypes = { 'dockerfile' },
                root_markers = { 'Dockerfile', '.dockerignore', '.git' },
                capabilities = capabilities,
            })

            -- Configure Kubernetes LSP (helm_ls)
            local helm_ls_cmd = find_lsp_executable('helm_ls', {
                'helm_ls',
                profile .. '/bin/helm_ls',
                '/nix/profile/bin/helm_ls',
            })
            vim.lsp.config('helm_ls', {
                cmd = { helm_ls_cmd, 'serve' },
                filetypes = { 'helm', 'yaml', 'yml' },
                root_markers = { 'Chart.yaml', 'values.yaml', '.git' },
                capabilities = capabilities,
            })

            -- Enable all configured LSP servers
            vim.lsp.enable('pyright')
            vim.lsp.enable('vtsls')
            vim.lsp.enable('nil_ls')
            vim.lsp.enable('lua_ls')
            vim.lsp.enable('phpantom_lsp')
            vim.lsp.enable('gopls')
            vim.lsp.enable('c3_lsp')
            vim.lsp.enable('yamlls')
            vim.lsp.enable('dockerls')
            vim.lsp.enable('helm_ls')

            vim.lsp.config('clangd', {
                cmd = { 'clangd', '--query-driver=/nix/store/*/bin/g++', '--query-driver=/nix/store/*/bin/gcc'}
            })
            vim.lsp.enable('clangd')
            vim.lsp.enable('texlab')
        end,
    }
}
