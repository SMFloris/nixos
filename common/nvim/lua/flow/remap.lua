local wk = require("which-key")

-- groups
wk.add({ "<leader>a", icon = { icon = "", color = "green" }, group = "AI" })
wk.add({ "<leader>c", icon = { color = "green", icon = "" }, group = "Quickfix" })
wk.add({ "<leader>d", icon = { color = "red", icon = "" }, group = "Debugger" })
wk.add({ "<leader>b", icon = { color = "blue", icon = "" }, group = "Buffer" })
wk.add({ "<leader>m", icon = { color = "yellow", icon = "" }, group = "Marks" })
wk.add({ "<leader>x", icon = { color = "orange", icon = "" }, group = "Trouble" })
wk.add({ "<leader>f", icon = { color = "cyan", icon = "󰍉" }, group = "Picker/Finder" })
wk.add({ "<leader>g", icon = { color = "purple", icon = "" }, group = "Git" })
wk.add({ "<leader>l", icon = { color = "azure", icon = "" }, group = "Lsp" })

-- comment
wk.add({ "<leader>/", hidden = true })
vim.keymap.set("n", "<leader>/", "gcc", { desc = "󰆉 Toggle Line Comment" })
vim.keymap.set("v", "<leader>/", "gc", { desc = "󰆉 Toggle Block Comment" })

-- move line up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever - paste without overwriting buffer
vim.keymap.set("x", "p", [["_dP]])
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = " Format with LSP" })

vim.keymap.set("n", "<leader>cq", function()
    local is_open = vim.fn.getqflist({ winid = 0 }).winid ~= 0
    if is_open then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end, { desc = " Toggle Quickfix List" })
vim.keymap.set("n", "<leader>cc", "<cmd>cnext<CR>zz", { desc = " Quickfix Next" })
vim.keymap.set("n", "<leader>cp", "<cmd>cprev<CR>zz", { desc = " Quickfix Previous" })

vim.api.nvim_create_augroup("custom_buffer", { clear = true })

-- highlight yanks
vim.api.nvim_create_autocmd("TextYankPost", {
    group    = "custom_buffer",
    pattern  = "*",
    callback = function() vim.highlight.on_yank { timeout = 200 } end
})

-- Mini Files
local map_split = function(buf_id, lhs, direction)
    local rhs = function()
        -- Make new window and set it as target
        local cur_target = MiniFiles.get_explorer_state().target_window
        local new_target = vim.api.nvim_win_call(cur_target, function()
            vim.cmd(direction .. ' split')
            return vim.api.nvim_get_current_win()
        end)

        MiniFiles.set_target_window(new_target)

        -- This intentionally doesn't act on file under cursor in favor of
        -- explicit "go in" action (`l` / `L`). To immediately open file,
        -- add appropriate `MiniFiles.go_in()` call instead of this comment.
    end

    -- Adding `desc` will result into `show_help` entries
    local desc = 'Split ' .. direction
    vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end

vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
        local buf_id = args.data.buf_id
        -- Tweak keys to your liking
        map_split(buf_id, '<C-s>', 'belowright horizontal')
        map_split(buf_id, '<C-v>', 'belowright vertical')
        map_split(buf_id, '<C-t>', 'tab')
    end,
})
