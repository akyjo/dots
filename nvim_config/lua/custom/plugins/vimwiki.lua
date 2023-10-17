return {
    "vimwiki/vimwiki",
    init = function()
        vim.api.nvim_set_keymap('n', '<leader>md', ':VimwikiToggleList<CR>', { noremap = true, silent = true })
        vim.g.vimwiki_listsyms = ' ○◐●✓'
    end
}
