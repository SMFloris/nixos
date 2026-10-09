local M = {}

function M.open()
    local source = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(source)
    local relative = path ~= "" and (vim.fs.relpath(vim.fn.getcwd(), path) or path) or ""
    local content = vim.api.nvim_buf_get_lines(source, 0, -1, false)
    local max_width = vim.api.nvim_buf_call(source, function()
        local width = 0
        for _, line in ipairs(content) do
            width = math.max(width, vim.fn.strdisplaywidth(line))
        end
        return width
    end)

    local lines = {
        "Full path: " .. (path ~= "" and path or "[No file]"),
        "Relative path: " .. (relative ~= "" and relative or "[No file]"),
        "Relative to: " .. vim.fn.getcwd(),
        "",
        "Lines: " .. #content,
        "Max column width: " .. max_width,
        "",
        "LSP clients:",
    }
    local clients = vim.lsp.get_clients({ bufnr = source })
    table.sort(clients, function(a, b) return a.name < b.name end)
    for _, client in ipairs(clients) do
        lines[#lines + 1] = ("  %s (id %d)"):format(client.name, client.id)
        if client.config.root_dir then
            lines[#lines + 1] = "    Root: " .. client.config.root_dir
        end
    end
    if #clients == 0 then
        lines[#lines + 1] = "  None attached"
    end
    vim.list_extend(lines, { "", "q close    y copy relative path    Y copy full path" })

    local width = math.max(1, math.min(78, vim.o.columns - 4))
    local height = 0
    for _, line in ipairs(lines) do
        height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / width))
    end
    height = math.max(1, math.min(height, vim.o.lines - vim.o.cmdheight - 4))

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modifiable = false
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        title = " File info ",
        title_pos = "center",
        width = width,
        height = height,
        row = math.max(0, math.floor((vim.o.lines - height - 2) / 2)),
        col = math.max(0, math.floor((vim.o.columns - width - 2) / 2)),
    })
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = false
    vim.wo[win].breakindent = false
    vim.wo[win].foldenable = false
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    local function copy(value)
        if value == "" then
            vim.notify("This buffer has no file path", vim.log.levels.INFO)
            return
        end
        vim.fn.setreg('"', value)
        vim.fn.setreg("+", value)
        vim.notify("Copied: " .. value)
    end
    local opts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set("n", "q", close, opts)
    vim.keymap.set("n", "<Esc>", close, opts)
    vim.keymap.set("n", "y", function() copy(relative) end, opts)
    vim.keymap.set("n", "Y", function() copy(path) end, opts)
end

return M
