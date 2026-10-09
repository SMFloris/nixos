local M = {}

local function before(a, b)
    return a.line < b.line or (a.line == b.line and a.character < b.character)
end

function M.find(symbols, buf, cursor, encoding)
    local text = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1] or ""
    local position = { line = cursor[1] - 1, character = vim.str_utfindex(text, encoding, cursor[2], false) }
    local best, best_depth, best_span = nil, -1, math.huge
    local uri = vim.uri_from_bufnr(buf)
    local function visit(nodes, depth)
        for _, symbol in ipairs(nodes or {}) do
            local location = symbol.location
            local range = symbol.range or (location and location.uri == uri and location.range)
            if range and not before(position, range.start) and before(position, range["end"]) then
                local target = (symbol.selectionRange or range).start
                local span = range["end"].line - range.start.line
                if before(target, position) and (depth > best_depth or (depth == best_depth and span < best_span)) then
                    best, best_depth, best_span = target, depth, span
                end
                visit(symbol.children, depth + 1)
            end
        end
    end
    visit(symbols, 0)
    if best then
        local target_line = vim.api.nvim_buf_get_lines(buf, best.line, best.line + 1, false)[1] or ""
        return { best.line + 1, vim.str_byteindex(target_line, encoding, best.character, false) }
    end
end

function M.jump()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    if #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/documentSymbol" }) == 0 then
        vim.notify("No LSP server provides document symbols for this buffer", vim.log.levels.INFO)
        return
    end

    vim.lsp.buf_request_all(buf, "textDocument/documentSymbol", {
        textDocument = vim.lsp.util.make_text_document_params(buf),
    }, function(results)
        if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_get_current_win() ~= win
            or vim.api.nvim_win_get_buf(win) ~= buf or vim.api.nvim_buf_get_changedtick(buf) ~= tick
            or not vim.deep_equal(vim.api.nvim_win_get_cursor(win), cursor) then
            return
        end

        -- Use the same server as the breadcrumbs when available.
        local ids = vim.tbl_keys(results)
        local preferred = vim.b[buf].navic_client_id
        table.sort(ids, function(a, b)
            if (a == preferred) ~= (b == preferred) then return a == preferred end
            return a < b
        end)
        for _, id in ipairs(ids) do
            local response, client = results[id], vim.lsp.get_client_by_id(id)
            if client and not response.err and response.result then
                local target = M.find(response.result, buf, cursor, client.offset_encoding or "utf-16")
                if target then
                    vim.cmd("normal! m'")
                    vim.api.nvim_win_set_cursor(win, target)
                    vim.cmd("normal! zvzz")
                    return
                end
            end
        end
        vim.notify("No enclosing parent LSP symbol", vim.log.levels.INFO)
    end)
end

return M
