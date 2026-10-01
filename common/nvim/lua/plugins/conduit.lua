return {
    {
        "SMFloris/conduit.nvim",
        dependencies = {
            "folke/snacks.nvim",
            {
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {},
            },
        },
        opts = {
            agent = {
                name = "codex",
                type = "local",
                cmd = { "wcodex" },
                acp_cmd = { "codex-acp" },
            },
        },
    },
}
