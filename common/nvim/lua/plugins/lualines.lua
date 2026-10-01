local function agent_status()
    local ok, conduit = pcall(require, "conduit")
    if not ok then
        return ""
    end

    local status_ok, status = pcall(conduit.status)
    if not status_ok then
        return ""
    end

    local label
    if status.state == "starting" then
        label = "starting"
    elseif status.busy then
        label = status.state == "refreshing" and "refreshing" or "working"
    else
        return ""
    end

    if status.queue_length and status.queue_length > 0 then
        label = string.format("%s · %d queued", label, status.queue_length)
    end

    return "󰚩 " .. label
end

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
    config = function()
        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("lualine_conduit_status", { clear = true }),
            pattern = {
                "ConduitAgentStarting",
                "ConduitAgentReady",
                "ConduitTurnStarted",
                "ConduitTurnComplete",
                "ConduitAgentExited",
                "ConduitPromptQueued",
                "ConduitQueueCleared",
            },
            callback = function()
                vim.cmd("redrawstatus")
            end,
        })

        -- Show the enclosing symbols for any LSP that supports document symbols.
        require("nvim-navic").setup({
            lsp = {
                auto_attach = true,
                -- YAML and Helm servers can both attach to the same buffer.
                preference = { "helm_ls", "yamlls" },
            },
        })

        require("lualine").setup({
            options = {
                globalstatus = true,
                theme = "tokyonight",
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = {},
                lualine_x = {
                    "searchcount",
                    "selectioncount",
                    agent_status,
                    {
                        "lsp_status",
                        icon = "",
                        show_name = true,
                    },
                    { "filetype", icon_only = false },
                },
                lualine_y = {},
                lualine_z = { "location" },
            },
            winbar = {
                lualine_c = { "navic" },
            },
            extensions = { "fugitive", "quickfix", "fzf", "lazy", "mason", "nvim-dap-ui", "oil", "trouble" },
        })
    end,
}
