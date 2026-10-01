local M = {}

local function normalize(path)
    if not path or path == "" then
        return nil
    end
    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

function M.for_file(path)
    local target = normalize(path)
    local matches = {}
    if not target then
        return matches
    end

    for _, mark in ipairs(require("recall.utils").sorted_global_marks()) do
        local marked_file = normalize(mark.info.file)
        if marked_file == target then
            matches[#matches + 1] = mark
        end
    end
    return matches
end

function M.is_marked(path)
    return #M.for_file(path) > 0
end

function M.toggle(path)
    path = normalize(path)
    if not path or not vim.uv.fs_stat(path) or vim.fn.isdirectory(path) == 1 then
        vim.notify("Recall marks can only be set on files", vim.log.levels.INFO)
        return false
    end

    local marking = require("recall.marking")
    local existing = M.for_file(path)
    if #existing > 0 then
        local chars = {}
        for _, mark in ipairs(existing) do
            chars[#chars + 1] = mark.char
            vim.cmd("delmarks " .. mark.char)
        end
        marking.on_mark_update()
        vim.notify(("Removed Recall mark%s %s"):format(#chars == 1 and "" or "s", table.concat(chars, ", ")))
        return true
    end

    local char = marking.next_available_mark()
    if not char then
        vim.notify("All Recall marks A-Z are already in use", vim.log.levels.WARN)
        return false
    end

    local bufnr = vim.fn.bufadd(path)
    vim.fn.bufload(bufnr)

    local row, col = 1, 0
    local windows = vim.fn.win_findbuf(bufnr)
    if #windows > 0 then
        row, col = unpack(vim.api.nvim_win_get_cursor(windows[1]))
    else
        local last_position = vim.api.nvim_buf_get_mark(bufnr, '"')
        if last_position[1] > 0 then
            row, col = last_position[1], last_position[2]
        end
    end

    row = math.min(math.max(row, 1), vim.api.nvim_buf_line_count(bufnr))
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
    col = math.min(math.max(col, 0), #line)

    vim.fn.setpos("'" .. char, { bufnr, row, col + 1, 0 })
    marking.on_mark_update()
    vim.notify(("Added Recall mark %s"):format(char))
    return true
end

return M
