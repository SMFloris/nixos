return {
    "ray-x/lsp_signature.nvim",
    main = "lsp_signature",
    event = "InsertEnter",
    opts = {
        bind = true,
        floating_window = true,
        floating_window_above_cur_line = true,
        hint_enable = false,
        doc_lines = 1,
        max_height = 6,
        max_width = 80,
        wrap = true,
        hi_parameter = "LspSignatureActiveParameter",
        handler_opts = { border = "rounded" },
    },
}
