return {
    {
        "kwkarlwang/bufjump.nvim",
        config = function()
            local bufjump = require("bufjump")
            bufjump.setup({
                on_success = function()
                    vim.cmd([[execute "normal! g`\"zz"]])
                end,
            })
            -- Double zero for backward
            vim.keymap.set("n", "00", bufjump.backward,
                { silent = true, noremap = true, desc = "Go to previous file (00)" })
            -- Double nine for forward
            vim.keymap.set("n", "99", bufjump.forward,
                { silent = true, noremap = true, desc = "Go to next file (99)" })
        end,
    },
}
