-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    -- { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    { '<leader>n', '<Cmd>Neotree filesystem reveal right toggle<CR>', desc = 'Toggle [N]eoTree', silent = true },
    { '<leader>b', '<Cmd>Neotree buffers reveal right toggle<CR>', desc = 'Toggle NeoTree [Buffer]', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    enable_git_status = true,
    enable_diagnostics = true,
    event_handlers = {
      {
        event = 'file_open_requested',
        handler = function()
          -- auto close
          -- vim.cmd("Neotree close")
          -- OR
          require('neo-tree.command').execute { action = 'close' }
        end,
      },
    },
    window = {
      position = 'right',
      width = 40,
      mappings = {
        ['l'] = 'open',
        ['h'] = 'close_node',
      },
    },
    filesystem = {
      window = {
        mappings = {
          -- ['\\'] = 'close_window',
        },
      },
      filtered_items = {
        visible = true,
      },
    },
  },
}
