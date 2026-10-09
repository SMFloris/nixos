local M = {}

function M.items(call, origin, client, incoming)
    local symbol = incoming and call.from or call.to
    local uri = incoming and symbol.uri or origin.uri
    local ranges = call.fromRanges or {}
    local definition = #ranges == 0
    if definition then
        uri = symbol.uri
        ranges = { symbol.selectionRange or symbol.range }
    end
    local items = {}
    for _, range in ipairs(ranges) do
        local location = vim.lsp.util.locations_to_items({ { uri = uri, range = range } }, client.offset_encoding)[1]
        if location then
            local kind = require("snacks.picker.source.lsp").symbol_kind(symbol.kind)
            local buf = vim.fn.bufnr(location.filename)
            items[#items + 1] = {
                name = symbol.name,
                kind = kind,
                file = location.filename,
                buf = buf >= 0 and buf or nil,
                pos = { location.lnum, location.col - 1 },
                end_pos = { location.end_lnum, location.end_col - 1 },
                line = location.text,
                definition = definition,
                text = table.concat({ symbol.name, kind, location.filename, location.text }, " "),
            }
        end
    end
    return items
end

local function finder(incoming)
    return function(_, ctx)
        local lsp = require("snacks.picker.source.lsp")
        local buf, win = ctx.filter.current_buf, ctx.filter.current_win
        return function(cb)
            local prepared = {}
            lsp.request(buf, "textDocument/prepareCallHierarchy", function(client)
                return vim.lsp.util.make_position_params(win, client.offset_encoding)
            end, function(client, result)
                for _, origin in ipairs(result or {}) do
                    prepared[#prepared + 1] = { client = client, origin = origin }
                end
            end)

            local names, seen = {}, {}
            for _, entry in ipairs(prepared) do
                if not seen[entry.origin.name] then
                    seen[entry.origin.name] = true
                    names[#names + 1] = entry.origin.name
                end
            end
            if #names > 0 and not ctx.picker.closed then
                ctx.picker.title = (incoming and "Calls to " or "Calls from ") .. table.concat(names, ", ")
                vim.schedule(function()
                    if not ctx.picker.closed then ctx.picker:update_titles() end
                end)
            end

            local emitted = {}
            for _, entry in ipairs(prepared) do
                lsp.request(entry.client, incoming and "callHierarchy/incomingCalls" or "callHierarchy/outgoingCalls",
                    function() return { item = entry.origin } end,
                    function(client, calls)
                        for _, call in ipairs(calls or {}) do
                            for _, item in ipairs(M.items(call, entry.origin, client, incoming)) do
                                local key = table.concat({ item.name, item.file, item.pos[1], item.pos[2] }, ":")
                                if not emitted[key] and ctx.filter:match(item) then
                                    emitted[key] = true
                                    cb(item)
                                end
                            end
                        end
                    end)
            end
        end
    end
end

function M.format(item, picker)
    local formatted = require("snacks").picker.format.lsp_symbol(item, picker)
    local kind = item.kind .. (item.definition and " · definition" or "")
    formatted[#formatted + 1] = { "  [" .. kind .. "]  ", "SnacksPickerComment" }
    vim.list_extend(formatted, require("snacks").picker.format.filename(item, picker))
    return formatted
end

function M.open(incoming)
    local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local pick = incoming and require("snacks").picker.lsp_incoming_calls or require("snacks").picker.lsp_outgoing_calls
    pick({
        title = incoming and "Incoming calls" or "Outgoing calls",
        finder = finder(incoming),
        format = M.format,
        workspace = false,
        tree = false,
        include_current = true,
        auto_confirm = false,
        icons = { files = { enabled = false } },
        formatters = { file = { min_width = 20 } },
        layout = {
            preset = function()
                return vim.o.columns >= 120 and "telescope" or "telescope_no_preview"
            end,
        },
        on_show = function(picker)
            local function select()
                require("flow.references").select_current(picker, file, cursor, line)
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
