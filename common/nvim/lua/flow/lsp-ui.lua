local M = {}

local function popup_options()
    return {
        border = "rounded",
        max_width = math.max(1, math.min(80, vim.o.columns - 4)),
        max_height = math.max(1, math.min(20, math.floor(vim.o.lines * 0.5))),
        wrap = true,
    }
end

local function attach(client, buf)
    if client:supports_method("textDocument/hover", buf) then
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover(popup_options())
        end, { buffer = buf, desc = "LSP documentation", silent = true })
    end
    if client:supports_method("textDocument/signatureHelp", buf) then
        vim.keymap.set({ "n", "i" }, "<C-k>", function()
            vim.lsp.buf.signature_help(popup_options())
        end, { buffer = buf, desc = "LSP signature help", silent = true })
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("flow_lsp_ui", { clear = true }),
        callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client then attach(client, event.buf) end
        end,
    })
    for _, client in ipairs(vim.lsp.get_clients()) do
        for buf in pairs(client.attached_buffers) do
            attach(client, buf)
        end
    end
end

return M
