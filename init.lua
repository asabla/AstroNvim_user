local config = {

  -- Set colorscheme
  colorscheme = "default_theme",

  -- Default theme configuration
  default_theme = {
    diagnostics_style = { italic = true },
    -- Modify the color table
    colors = {
      fg = "#abb2bf",
    },
    -- Modify the highlight groups
    highlights = function(highlights)
      local C = require "default_theme.colors"

      highlights.Normal = { fg = C.fg, bg = C.bg }
      return highlights
    end,
  },

  -- Disable default plugins
  enabled = {
    bufferline = true,
    neo_tree = true,
    lualine = true,
    gitsigns = true,
    colorizer = true,
    toggle_term = true,
    comment = true,
    symbols_outline = true,
    indent_blankline = true,
    dashboard = true,
    which_key = true,
    neoscroll = true,
    ts_rainbow = true,
    ts_autotag = true,
  },

  -- Disable AstroNvim ui features
  ui = {
    nui_input = true,
    telescope_select = true,
  },

  -- Configure plugins
  plugins = {
    -- Add plugins, the packer syntax without the "use"
    init = {
      -- { "andweeb/presence.nvim" },
      -- {
      --   "ray-x/lsp_signature.nvim",
      --   event = "BufRead",
      --   config = function()
      --     require("lsp_signature").setup()
      --   end,
      -- },
    },
    -- All other entries override the setup() call for default plugins
    treesitter = {
      ensure_installed = { "lua" },
    },
    packer = {
      compile_path = vim.fn.stdpath "config" .. "/lua/packer_compiled.lua",
    },
  },

  -- Add paths for including more VS Code style snippets in luasnip
  luasnip = {
    vscode_snippet_paths = {},
  },

  -- Modify which-key registration
  ["which-key"] = {
    -- Add bindings to the normal mode <leader> mappings
    register_n_leader = {
      -- ["N"] = { "<cmd>tabnew<cr>", "New Buffer" },
    },
  },

  -- CMP Source Priorities
  -- modify here the priorities of default cmp sources
  -- higher value == higher priority
  -- The value can also be set to a boolean for disabling default sources:
  -- false == disabled
  -- true == 1000
  cmp = {
    source_priority = {
      nvim_lsp = 1000,
      luasnip = 750,
      buffer = 500,
      path = 250,
    },
  },

  -- Extend LSP configuration
  lsp = {
    -- add to the server on_attach function
    -- on_attach = function(client, bufnr)
    -- end,

    -- override the lsp installer server-registration function
    -- server_registration = function(server, opts)
    --   server:setup(opts)
    -- end

    -- Add overrides for LSP server settings, the keys are the name of the server
    ["server-settings"] = {
      -- example for addings schemas to yamlls
      -- yamlls = {
      --   settings = {
      --     yaml = {
      --       schemas = {
      --         ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
      --         ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
      --         ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
      --       },
      --     },
      --   },
      -- },
    },
  },

  -- Diagnostics configuration (for vim.diagnostics.config({}))
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  -- null-ls configuration
  ["null-ls"] = function()
    -- Formatting and linting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim
    local status_ok, null_ls = pcall(require, "null-ls")
    if not status_ok then
      return
    end

    -- Check supported formatters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    local formatting = null_ls.builtins.formatting

    -- Check supported linters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    local diagnostics = null_ls.builtins.diagnostics

    null_ls.setup {
      debug = false,
      sources = {
        -- Set a formatter
        formatting.rufo,
        -- Set a linter
        diagnostics.rubocop,
      },
      -- NOTE: You can remove this on attach function to disable format on save
      on_attach = function(client)
        if client.resolved_capabilities.document_formatting then
          vim.api.nvim_create_autocmd("BufWritePre", {
            desc = "Auto format before save",
            pattern = "<buffer>",
            callback = vim.lsp.buf.formatting_sync,
          })
        end
      end,
    }
  end,

  -- This function is run last
  -- good place to configure mappings and vim options
  polish = function()
    local map = vim.keymap.set
    local set = vim.opt
    local utils = require "core.utils"
    
    -- Set options
    set.relativenumber = false
    set.cursorline = true

    -- Set key bindings
    map("n", "<C-s>", ":w!<CR>")

    -- Remap navigational keys
    map("n", "ö", "l", { noremap = true })
    map("n", "l", "k", { noremap = true })
    map("n", "k", "j", { noremap = true })
    map("n", "j", "h", { noremap = true })

    map("v", "ö", "l", { noremap = true })
    map("v", "l", "k", { noremap = true })
    map("v", "k", "j", { noremap = true })
    map("v", "j", "h", { noremap = true })

    -- Navigate buffers
    if utils.is_available "bufferline.nvim" then
      map("n", "<S-j>", "<cmd>BufferLineMoveNext<cr>", opts)
      map("n", "<S-ö>", "<cmd>BufferLineMovePrev<cr>", opts)
    else
      map("n", "<S-j>", "<cmd>bnext<CR>", opts)
      map("n", "<S-ö>", "<cmd>bprevious<CR>", opts)
    end
    
    -- Handle indentation
    map("v", "<S-Tab>", "<gv", opts)
    map("v", "<Tab>", ">gv", opts)

    -- Move text up and down
    map("n", "<A-k>", "<Esc><cmd>m .+1<CR>==gi", opts)
    map("n", "<A-l>", "<Esc><cmd>m .-2<CR>==gi", opts)
    map("v", "<A-k>", "<cmd>m .+1<CR>==gv", opts)
    map("v", "<A-l>", "<cmd>m .-2<CR>==gv", opts)
    map("x", "<A-k>", "<cmd>move '>+1<CR>gv-gv", opts)
    map("x", "<A-l>", "<cmd>move '<-2<CR>gv-gv", opts)

    -- Toggle line numbers and cursorline
    map("n", "<C-n><C-n>", ":set invnumber<CR>", opts)
    map("n", "<C-L><C-L>", ":set cursorline!<CR>", opts)

    -- Telescope bindings
    map("n", "<M-f>", "<cmd>Telescope current_buffer_fuzzy_find<CR>", opts)
    map("n", "<C-p>", "<cmd>Telescope find_files<CR>", opts)

    -- Comment/de-comment current line
    if utils.is_available "Comment.nvim" then
      map("n", "<C-K><C-K>", "<cmd>lua require('Comment.api').toggle_current_linewise()<cr>", opts)
      map("v", "<C-K><C-K>", "<esc><cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", opts)
    end

    -- Buffer nagivation
    map("n", "<S-ö>", "<cmd>BufferLineCycleNext<cr>", opts)
    map("n", "<S-j>", "<cmd>BufferLineCyclePrev<cr>", opts)

    -- Set autocommands
    vim.api.nvim_create_augroup("packer_conf", {})
    vim.api.nvim_create_autocmd("BufWritePost", {
      desc = "Sync packer after modifying plugins.lua",
      group = "packer_conf",
      pattern = "plugins.lua",
      command = "source <afile> | PackerSync",
    })

    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    --   pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }
  end,
}

return config
