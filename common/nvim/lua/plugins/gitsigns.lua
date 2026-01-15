return {
    {
        'lewis6991/gitsigns.nvim',
        lazy = true,
        tag = 'v1.0.2',
        event = { "BufReadPost" },
        config = function()
            require('gitsigns').setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    -- Navigation
                    vim.keymap.set('n', ']c', function()
                        if vim.wo.diff then return ']c' end
                        vim.schedule(function() gs.next_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, buffer = bufnr, desc = "Next Hunk" })

                    vim.keymap.set('n', '[c', function()
                        if vim.wo.diff then return '[c' end
                        vim.schedule(function() gs.prev_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, buffer = bufnr, desc = "Prev Hunk" })

                    -- Actions
                    vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr, desc = "Stage Hunk" })
                    vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { buffer = bufnr, desc = "Reset Hunk" })
                    vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = "Stage Buffer" })
                    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo Stage Hunk" })
                    vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = "Reset Buffer" })
                    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
                    vim.keymap.set('n', '<leader>hb', function() gs.blame_line { full = true } end, { buffer = bufnr, desc = "Blame Line" })
                    vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle Blame" })
                    vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = "Diff This" })
                    vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { buffer = bufnr, desc = "Diff This ~" })
                    vim.keymap.set('n', '<leader>td', gs.toggle_deleted, { buffer = bufnr, desc = "Toggle Deleted" })
                end
            })
        end
    }
}
