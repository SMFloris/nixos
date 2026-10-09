-- Keep visual mode active while changing indentation.
vim.keymap.set("v", ">", ">gv", { desc = "Indent selection" })
vim.keymap.set("v", "<", "<gv", { desc = "Unindent selection" })

-- Rotate windows while keeping focus at the current position.
vim.keymap.set("n", "<C-w>r", function()
    local window_number = vim.fn.winnr()
    vim.cmd(("%dwincmd r"):format(vim.v.count1))
    vim.cmd(("%dwincmd w"):format(window_number))
end, { desc = "Rotate windows and keep focus position" })

-- Paste without replacing the unnamed register.
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste without replacing register" })

vim.keymap.set("n", "<leader>fi", function()
    require("flow.file-info").open()
end, { desc = "File info" })
