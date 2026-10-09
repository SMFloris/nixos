local M = {}

function M.format(item, picker)
    local formatted = require("snacks").picker.format.lsp_symbol(item, picker)
    formatted[#formatted + 1] = { "  [" .. (item.kind or "Unknown") .. "]", "SnacksPickerComment" }
    formatted[#formatted + 1] = { "  :" .. item.pos[1], "SnacksPickerRow" }
    return formatted
end

function M.select_current(picker, cursor, line)
    if picker.closed then return end
    local selected, span, depth = nil, math.huge, -1
    local nearest, distance = nil, math.huge
    local columns = {}
    for item, index in picker:iter() do
        local delta = math.abs(item.pos[1] - cursor[1])
        if delta < distance then
            nearest, distance = index, delta
        end
        local range = item.range or (item.loc and item.loc.range)
        if range then
            local encoding = item.loc and item.loc.encoding or "utf-16"
            if columns[encoding] == nil then
                columns[encoding] = vim.str_utfindex(line, encoding, cursor[2], false)
            end
            local column = columns[encoding]
            local row = cursor[1] - 1
            local start, finish = range.start, range["end"]
            local inside = (row > start.line or (row == start.line and column >= start.character))
                and (row < finish.line or (row == finish.line and column < finish.character))
            if inside then
                local size = finish.line - start.line
                local nesting, parent = 0, item.parent
                while parent and not parent.root do
                    nesting, parent = nesting + 1, parent.parent
                end
                if size < span or (size == span and nesting > depth) then
                    selected, span, depth = index, size, nesting
                end
            end
        end
    end
    if selected or nearest then
        picker.list:view(selected or nearest)
    end
end

function M.open()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    require("snacks").picker.lsp_symbols({
        on_show = function(picker)
            local function select()
                M.select_current(picker, cursor, line)
            end
            if picker.matcher.task:running() then
                picker.matcher.task:on("done", vim.schedule_wrap(select))
            else
                select()
            end
        end,
    })
end

return M
