local M = {}

function M.select_current(picker, file, cursor, line)
    if picker.closed then return end
    local selected, rows, columns = nil, math.huge, math.huge
    for item, index in picker:iter() do
        if item.file and vim.fs.normalize(item.file) == file then
            local row_distance = math.abs(item.pos[1] - cursor[1])
            local column = cursor[2]
            if item.loc and item.loc.encoding then
                column = vim.str_utfindex(line, item.loc.encoding, cursor[2], false)
            end
            local column_distance = math.abs(item.pos[2] - column)
            if row_distance < rows or (row_distance == rows and column_distance < columns) then
                selected, rows, columns = index, row_distance, column_distance
            end
        end
    end
    if selected then picker.list:view(selected) end
end

function M.open()
    local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    require("snacks").picker.lsp_references({
        on_show = function(picker)
            local function select()
                M.select_current(picker, file, cursor, line)
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
