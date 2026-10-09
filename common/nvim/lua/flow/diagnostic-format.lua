local M = {}

-- Virtual lines keep messages outside the selectable, highlighted header row.
local function message_lines(message, width)
    local lines = {}
    for _, paragraph in ipairs(vim.split(message:gsub("\t", "    "), "\n", { plain = true })) do
        local current = ""
        for char in paragraph:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
            if current ~= "" and vim.fn.strdisplaywidth(current .. char) > width then
                local before, word = current:match("^(.*)%s+([^%s]*)$")
                if before and before ~= "" then
                    lines[#lines + 1] = { { "  " .. before, "SnacksPickerList" } }
                    current = word
                else
                    lines[#lines + 1] = { { "  " .. current, "SnacksPickerList" } }
                    current = ""
                end
            end
            current = current .. char
        end
        lines[#lines + 1] = { { "  " .. current, "SnacksPickerList" } }
    end
    return lines
end

function M.format(item, picker)
    local format = require("snacks").picker.format
    local header = format.severity(item, picker)
    vim.list_extend(header, format.filename(item, picker))
    -- Snacks adds one column for its selection prefix outside the formatter.
    for _, chunk in ipairs(header) do
        if chunk.resolve then
            local resolve = chunk.resolve
            chunk.resolve = function(width) return resolve(math.max(1, width - 1)) end
        end
    end
    local diagnostic = item.item
    if diagnostic.source then
        header[#header + 1] = { "[" .. diagnostic.source .. "]", "SnacksPickerDiagnosticSource" }
    end
    local width = vim.api.nvim_win_get_width(picker.list.win.win)
    header[#header + 1] = {
        col = 0,
        virt_lines = message_lines(diagnostic.message, math.max(1, width - 2)),
    }
    return header
end

function M.prepare(picker)
    local list = picker.list
    local win = list.win
    -- The normal picker pins topline to 1 because each item occupies one row.
    -- Allow native scrolling past message rows, and map clicks by buffer row.
    vim.api.nvim_clear_autocmds({ group = win.augroup, event = { "WinScrolled", "CursorMoved" } })
    win.events = vim.tbl_filter(function(event)
        return event.event ~= "WinScrolled" and event.event ~= "CursorMoved"
    end, win.events)
    win:on("CursorMoved", function()
        if win:valid() then
            local row = vim.api.nvim_win_get_cursor(win.win)[1]
            if row ~= list:idx2row(list.cursor) then
                list:view(list:row2idx(row))
            end
        end
    end, { buf = true })

    local render = list.render
    list.render = function(self)
        render(self)
        if self.win:win_valid() then
            -- Also bring the current header into view after a full redraw.
            vim.api.nvim_win_set_cursor(self.win.win, { self:idx2row(self.cursor), 0 })
        end
    end
    local width = vim.api.nvim_win_get_width(win.win)
    win:on("WinResized", function()
        if not win:win_valid() then return end
        local resized = vim.api.nvim_win_get_width(win.win)
        if resized ~= width then
            width = resized
            list.dirty = true
            list:update()
        end
    end)
end

return M
