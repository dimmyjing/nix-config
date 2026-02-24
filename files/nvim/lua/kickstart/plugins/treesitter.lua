return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    config = function()
      local filetypes = {
        'bash',
        'c',
        'cpp',
        'css',
        'cue',
        'diff',
        'elixir',
        'gleam',
        'go',
        'hcl',
        'heex',
        'html',
        'just',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'pkl',
        'python',
        'query',
        'ruby',
        'rust',
        'svelte',
        'swift',
        'templ',
        'tsx',
        'typescript',
        'typespec',
        'typst',
        'javascript',
        'vim',
        'vimdoc',
        'wit',
      }
      require('nvim-treesitter').install(filetypes)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function() vim.treesitter.start() end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
