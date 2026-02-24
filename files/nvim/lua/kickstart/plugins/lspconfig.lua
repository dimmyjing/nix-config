-- LSP Plugins
return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      {
        'mason-org/mason.nvim',
        ---@module 'mason.settings'
        ---@type MasonSettings
        ---@diagnostic disable-next-line: missing-fields
        opts = {},
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Toggle to show/hide diagnostic messages
          map('<leader>td', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, '[T]oggle [D]iagnostics')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      -- NOTE: The following line is now commented as blink.cmp extends capabilites by default from its internal code:
      -- https://github.com/Saghen/blink.cmp/blob/102db2f5996a46818661845cf283484870b60450/plugin/blink-cmp.lua
      -- It has been left here as a comment for educational purposes (as the predecessor completion plugin required this explicit step).
      --
      -- local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Language servers can broadly be installed in the following ways:
      --  1) via the mason package manager; or
      --  2) via your system's package manager; or
      --  3) via a release binary from a language server's repo that's accessible somewhere on your system.

      -- The servers table comprises of the following sub-tables:
      -- 1. mason
      -- 2. others
      -- Both these tables have an identical structure of language server names as keys and
      -- a table of language server configuration as values.
      ---@class LspServersConfig
      ---@diagnostic disable-next-line: duplicate-doc-field
      ---@field mason table<string, vim.lsp.Config>
      ---@diagnostic disable-next-line: duplicate-doc-field
      ---@field others table<string, vim.lsp.Config>
      local servers = {
        --  Add any additional override configuration in any of the following tables. Available keys are:
        --  - cmd (table): Override the default command used to start the server
        --  - filetypes (table): Override the default list of associated filetypes for the server
        --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        --  - settings (table): Override the default settings passed when initializing the server.
        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        --
        --  Feel free to add/remove any LSPs here that you want to install via Mason. They will automatically be installed and setup.
        --  See `:help lsp-config` for information about keys and how to configure
        -- TODO: remove mason
        mason = {
          biome = {},
          buf = {},
          clangd = {},
          -- cue = {},
          -- elixirls = {},
          -- eslint = {},
          html = { filetypes = { 'html', 'twig', 'hbs' } },
          lua_ls = {
            -- Special Lua Config, as recommended by neovim help docs
            on_init = function(client)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if
                  (path ~= vim.fn.stdpath 'config' and path:find('/nix/', 1, true) == nil)
                  ---@diagnostic disable-next-line: undefined-field
                  and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
                then
                  return
                end
              end

              ---@diagnostic disable-next-line: param-type-mismatch
              client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                  version = 'LuaJIT',
                  path = { 'lua/?.lua', 'lua/?/init.lua' },
                },
                workspace = {
                  checkThirdParty = false,
                  -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                  --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                  library = vim.api.nvim_get_runtime_file('', true),
                },
              })
            end,
            settings = {
              Lua = {},
            },
          },
          jdtls = {},
          jsonls = {
            settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
              },
            },
          },
          ['pkl-lsp'] = {},
          postgres_lsp = {},
          -- prettier = {},
          -- rubocop = {},
          -- ruby_lsp = {},
          ruff = {},
          rust_analyzer = {
            settings = {
              ['rust-analyzer'] = {
                diagnostics = {
                  disabled = {
                    'macro-error',
                  },
                },
              },
            },
          },
          -- solargraph = {},
          -- sorbet = {},
          stylua = {},
          svelte = {},
          tailwindcss = {
            filetypes = {
              'templ',
              'html',
              'javascriptreact',
              'typescriptreact',
              'heex',
              'elixir',
              'svelte',
            },
            init_options = {
              userLanguages = {
                templ = 'html',
                elixir = 'phoenix-heex',
                heex = 'phoenix-heex',
                svelte = 'html',
              },
            },
            settings = {
              includeLanguages = {
                templ = 'html',
                ['html-eex'] = 'html',
                ['phoenix-heex'] = 'html',
                heex = 'html',
                eelixir = 'html',
                elixir = 'html',
                svelte = 'html',
              },
            },
          },
          templ = {},
          tflint = {},
          tinymist = {
            settings = {
              formatterMode = 'typstyle',
            },
            on_attach = function(client, bufnr)
              vim.keymap.set(
                'n',
                '<leader>tp',
                function()
                  client:exec_cmd({
                    title = 'pin',
                    command = 'tinymist.pinMain',
                    arguments = { vim.api.nvim_buf_get_name(0) },
                  }, { bufnr = bufnr })
                end,
                { desc = '[T]inymist [P]in', noremap = true }
              )

              vim.keymap.set(
                'n',
                '<leader>tu',
                function()
                  client:exec_cmd({
                    title = 'unpin',
                    command = 'tinymist.pinMain',
                    arguments = { vim.v.null },
                  }, { bufnr = bufnr })
                end,
                { desc = '[T]inymist [U]npin', noremap = true }
              )
            end,
          },
          tofu_ls = {},
          tsgo = {},
          tsp_server = {},
          -- vtsls = {
          --   settings = {
          --     vtsls = {
          --       tsserver = {
          --         globalPlugins = {
          --           {
          --             name = '@vue/typescript-plugin',
          --             location = vim.fn.expand '$MASON/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server',
          --             languages = { 'vue' },
          --             configNamespace = 'typescript',
          --           },
          --         },
          --       },
          --     },
          --   },
          --   filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
          -- },
          vue_ls = {},
          yamlls = {
            settings = {
              yaml = {
                format = {
                  enable = true,
                },
                schemaStore = {
                  enable = false,
                  -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                  url = '',
                },
                schemas = require('schemastore').yaml.schemas(),
                validate = true,
                completion = true,
              },
            },
          },
          zls = {},
          -- Some languages (like typescript) have entire language plugins that can be useful:
          --    https://github.com/pmizio/typescript-tools.nvim
          --
          -- But for many setups, the LSP (`ts_ls`) will work just fine
          -- ts_ls = {},
        },
        -- This table contains config for all language servers that are *not* installed via Mason.
        -- Structure is identical to the mason table from above.
        others = {
          -- dartls = {},
          gleam = {},
          gopls = {
            analyses = {
              unusedparams = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
              unusedvariable = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
          golangci_lint_ls = {},
          hls = {},
          nixd = {
            formatting = {
              command = { 'nixfmt' },
            },
          },
          pyright = {},
          sourcekit = {},
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      local ensure_installed = vim.tbl_keys(servers.mason or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Either merge all additional server configs from the `servers.mason` and `servers.others` tables
      -- to the default language server configs as provided by nvim-lspconfig or
      -- define a custom server config that's unavailable on nvim-lspconfig.
      for name, server in pairs(vim.tbl_extend('keep', servers.mason, servers.others)) do
        if not vim.tbl_isempty(server) then vim.lsp.config(name, server) end
      end

      -- After configuring our language servers, we now enable them
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_enable = true, -- automatically run vim.lsp.enable() for all servers that are installed via Mason
      }

      -- Manually run vim.lsp.enable for all language servers that are *not* installed via Mason
      if not vim.tbl_isempty(servers.others) then vim.lsp.enable(vim.tbl_keys(servers.others)) end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
