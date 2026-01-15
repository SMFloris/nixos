return {
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            vim.lsp.config("nil_ls", {
                capabilities = capabilities,
                settings = {
                    ["nil"] = {
                        formatting = {
                            command = { "alejandra" },
                        },
                    },
                },
            })
            require("mason-lspconfig").setup {
                ensure_installed = { "lua_ls", "nil_ls", "tsserver", "pyright" },
                automatic_enable = true,
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup {
                            capabilities = capabilities,
                        }
                    end,
                },
            }
        end,
    }
}
