local M = {}

local function format_c3()
    local bufnr = vim.api.nvim_get_current_buf()
    local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(lines, "\n")
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    if filepath == "" then
        filepath = vim.fs.joinpath(vim.uv.cwd(), "untitled.c3")
    end

    vim.system({
        "${pkgs.c3fmt}/bin/c3fmt",
        "--stdin",
        "--stdin-filepath=" .. filepath,
        "--stdout",
    }, { stdin = input, text = true }, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                local message = result.stderr ~= "" and result.stderr or "c3fmt failed"
                vim.notify(vim.trim(message), vim.log.levels.ERROR, { title = "c3fmt" })
                return
            end

            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end

            if vim.api.nvim_buf_get_changedtick(bufnr) ~= changedtick then
                vim.notify("Buffer changed while c3fmt was running; formatted output was not applied", vim.log.levels.WARN,
                    { title = "c3fmt" })
                return
            end

            local formatted = vim.split(result.stdout or "", "\n", { plain = true })
            if formatted[#formatted] == "" then
                table.remove(formatted)
            end

            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
        end)
    end)
end

function M.format()
    if vim.bo.filetype == "c3" then
        format_c3()
        return
    end

    vim.lsp.buf.format({ async = true })
end

return M
