-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- provide json schemas
  'b0o/schemastore.nvim',

  {
    -- Show context of current function
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 1, -- Maximum number of lines to show for a single context
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      }
    end,
  },

  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_assume_mapped = true
    end,
  },

  {
    'hashivim/vim-terraform',
  },

  {
    'lifepillar/pgsql.vim',
    config = function()
      vim.g.sql_type_default = 'pgsql'
    end,
  },

  {
    'laytan/tailwind-sorter.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-lua/plenary.nvim' },
    build = 'cd formatter && npm i && npm run build',
    config = function()
      require('tailwind-sorter').setup {
        on_save_enabled = false,
        on_save_pattern = { '*.html', '*.js', '*.jsx', '*.tsx', '*.twig', '*.hbs', '*.php', '*.heex', '*.astro', '*.ex' },
      }
    end,
  },

  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },

  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    version = '1.*',
    opts = {
      invert_colors = 'auto',
      dependencies_bin = {
        ['tinymist'] = 'tinymist',
        ['websocat'] = 'websocat',
      },
    }, -- lazy.nvim will implicitly calls `setup {}`
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      ---@diagnostic disable-next-line: missing-parameter
      harpoon:setup {
        settings = {
          sync_on_ui_close = true,
          save_on_toggle = true,
        },
      }

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():append()
      end)
      vim.keymap.set('n', '<c-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set('n', '<leader>h', function()
        harpoon:list():select(1)
      end)
      vim.keymap.set('n', '<leader>j', function()
        harpoon:list():select(2)
      end)
      vim.keymap.set('n', '<leader>k', function()
        harpoon:list():select(3)
      end)
      vim.keymap.set('n', '<leader>l', function()
        harpoon:list():select(4)
      end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-P>', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', '<C-S-N>', function()
        harpoon:list():next()
      end)
    end,
  },
}
