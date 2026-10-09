local M = {}

local function format_external(command, title)
    local bufnr = vim.api.nvim_get_current_buf()
    local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(lines, "\n")
    vim.system(command, { stdin = input, text = true }, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                local message = result.stderr ~= "" and result.stderr or (title .. " failed")
                vim.notify(vim.trim(message), vim.log.levels.ERROR, { title = title })
                return
            end

            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end

            if vim.api.nvim_buf_get_changedtick(bufnr) ~= changedtick then
                vim.notify("Buffer changed while " .. title .. " was running; formatted output was not applied", vim.log.levels.WARN,
                    { title = title })
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
    local filetype = vim.bo.filetype
    if filetype == "c3" or filetype == "python" then
        local filepath = vim.api.nvim_buf_get_name(0)
        if filepath == "" then
            filepath = vim.fs.joinpath(vim.fn.getcwd(), filetype == "python" and "untitled.py" or "untitled.c3")
        end

        if filetype == "python" then
            format_external({ "${pkgs.black}/bin/black", "--quiet", "--stdin-filename", filepath, "-" }, "Black")
        else
            format_external({
                "${pkgs.c3fmt}/bin/c3fmt",
                "--stdin",
                "--stdin-filepath=" .. filepath,
                "--stdout",
            }, "c3fmt")
        end
        return
    end

    vim.lsp.buf.format({ async = true })
end

return M
