local wk = require("which-key")

-- groups
wk.add({ "<leader>a", icon = { icon = "", color = "green" }, group = "AI" })
wk.add({ "<leader>c", icon = { color = "green", icon = "" }, group = "Quickfix" })
wk.add({ "<leader>y", icon = { color = "yellow", icon = "" }, group = "Yank" })
wk.add({ "<leader>d", icon = { color = "red", icon = "" }, group = "Debugger" })
wk.add({ "<leader>b", icon = { color = "blue", icon = "" }, group = "Buffer" })
wk.add({ "<leader>m", icon = { color = "yellow", icon = "" }, group = "Marks" })
wk.add({ "<leader>x", icon = { color = "orange", icon = "" }, group = "Trouble" })
wk.add({ "<leader>f", icon = { color = "cyan", icon = "󰍉" }, group = "Picker/Finder" })
wk.add({ "<leader>g", icon = { color = "purple", icon = "" }, group = "Git" })
wk.add({ "<leader>l", icon = { color = "azure", icon = "" }, group = "Lsp" })
wk.add({ "<leader>s", icon = { color = "green", icon = "" }, group = "Session" })

-- auto format
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        if vim.b.format_on_save == nil then
            vim.b.format_on_save = true
        end
    end,
})

vim.keymap.set("n", "<leader>F", function()
    vim.b.format_on_save = not vim.b.format_on_save
    print("Format on save: " .. tostring(vim.b.format_on_save))
end, { desc = "Toggle format on save" })

-- comment
wk.add({ "<leader>/", hidden = true })
vim.keymap.set("n", "<leader>/", "gcc", { desc = "󰆉 Toggle Line Comment" })
vim.keymap.set("v", "<leader>/", "gc", { desc = "󰆉 Toggle Block Comment" })

-- indent/deintent
vim.keymap.set("v", ">", ">gv", { desc = "Indent and stay in visual" })
vim.keymap.set("v", "<", "<gv", { desc = "Deindent and stay in visual" })

-- comment
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "󰆉 Toggle Line Comment" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "󰆉 Toggle Block Comment" })

-- move line up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- center on next/prev
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "*", "*zzzv")
vim.keymap.set("n", "#", "#zzzv")

-- greatest remap ever - paste without overwriting buffer
vim.keymap.set("x", "p", [["_dP]])
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = " Format with LSP" })
vim.keymap.set("i", "<C-Space>", function() require('cmp').complete() end, { desc = "Manual Completion" })

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
vim.keymap.set("n", "<leader>yp", function()
    local path = vim.fn.expand('%')
    vim.fn.setreg('+', path)
    print("Copied relative path: " .. path)
end, { desc = "Copy Relative Path" })
vim.keymap.set("n", "<leader>yP", function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    print("Copied full path: " .. path)
end, { desc = "Copy Full Path" })

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

vim.api.nvim_create_user_command("Phpstan", function(opts)
    local phpstan_cmd = "vendor/bin/phpstan"
    local target = (opts.args ~= "" and opts.args) or vim.fn.expand("%")
    local cmd = { phpstan_cmd, "analyse", "--memory-limit=4G", "--no-progress", "--error-format=raw", target }

    -- spinner
    local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    local idx = 1
    local timer = vim.loop.new_timer()
    local function echo(msg, hl) vim.api.nvim_echo({ { msg, hl or "None" } }, false, {}) end
    timer:start(0, 80, vim.schedule_wrap(function()
        echo(("PhpStan %s running…"):format(frames[idx]), "WarningMsg")
        idx = (idx % #frames) + 1
    end))

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data or (#data == 1 and data[1] == "") then return end
            vim.fn.setqflist({}, ' ', { lines = data })
        end,
        on_exit = function(_, code)
            timer:stop(); timer:close()
            echo(code == 0 and "PhpStan ✓ done" or ("PhpStan ✗ exited (" .. code .. ")"),
                code == 0 and "MoreMsg" or "ErrorMsg")
            vim.cmd("copen")
        end,
    })
end, { nargs = "?" })

-- Recall marks management
vim.api.nvim_create_augroup("recall_marks", { clear = true })
vim.api.nvim_create_autocmd("DirChanged", {
    group = "recall_marks",
    callback = function()
        require("recall").load()
    end,
})
vim.api.nvim_create_autocmd("VimLeave", {
    group = "recall_marks",
    callback = function()
        require("recall").save()
    end,
})

vim.filetype.add({
    extension = {
        c3  = "c3",
        c3i = "c3",
    },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c3' },
    callback = function()
        -- syntax highlighting, provided by Neovim
        vim.treesitter.start()
        -- folds, provided by Neovim
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- indentation, provided by nvim-treesitter
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

-- bufsurf mappings
vim.keymap.set("n", "<leader>bo", "<cmd>BufSurfBack<CR>", { desc = "BufSurf Backward" })
vim.keymap.set("n", "<leader>bi", "<cmd>BufSurfForward<CR>", { desc = "BufSurf Forward" })
vim.keymap.set("n", "<leader>bb", ":b#<CR>", { desc = "Previous Buffer" })
