return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        branch = 'main',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').setup {}
            require('nvim-treesitter').install {
                'blade',
                'php',
                'go',
                'python',
                'html',
                'cpp',
                'yaml',
                'dockerfile',
                'typescript',
                'javascript',
            }
        end,
    }
}
