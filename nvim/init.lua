-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic Neovim settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- Plugin specifications
require("lazy").setup({
  -- Catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          notify = false,
          mini = false,
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- NeoTree file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        default_component_configs = {
          container = {
            enable_character_fade = true
          },
          indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            with_expanders = nil,
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "ﰊ",
            default = "*",
            highlight = "NeoTreeFileIcon"
          },
          modified = {
            symbol = "[+]",
            highlight = "NeoTreeModified",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
          },
          git_status = {
            symbols = {
              added     = "✚",
              modified  = "",
              deleted   = "✖",
              renamed   = "",
              untracked = "",
              ignored   = "",
              unstaged  = "",
              staged    = "",
              conflict  = "",
            }
          },
        },
        window = {
          position = "left",
          width = 40,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["<space>"] = {
                "toggle_node",
                nowait = false,
            },
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open",
            ["<esc>"] = "revert_preview",
            ["P"] = { "toggle_preview", config = { use_float = true } },
            ["l"] = "focus_preview",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["t"] = "open_tabnew",
            ["w"] = "open_with_window_picker",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["a"] = {
              "add",
              config = {
                show_path = "none"
              }
            },
            ["A"] = "add_directory",
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["<"] = "prev_source",
            [">"] = "next_source",
          }
        },
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_hidden = true,
            hide_by_name = {
              ".DS_Store",
              "thumbs.db"
            },
            hide_by_pattern = {
              "*.meta",
              "*/src/*/tsconfig.json",
            },
            always_show = {
              ".gitignored",
            },
            never_show = {
              ".DS_Store",
              "thumbs.db"
            },
          },
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          group_empty_dirs = false,
          hijack_netrw_behavior = "open_default",
          use_libuv_file_watcher = true,
        },
        buffers = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          group_empty_dirs = true,
          show_unloaded = true,
        },
        git_status = {
          window = {
            position = "float",
            mappings = {
              ["A"]  = "git_add_all",
              ["gu"] = "git_unstage_file",
              ["ga"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["gp"] = "git_push",
              ["gg"] = "git_commit_and_push",
            }
          }
        }
      })
    end,
  },

  -- Telescope fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
    end,
  },

  -- Which-key for keybinding hints (Spacemacs-like)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
    }
  },

  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc' },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  -- Auto completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      }
    end,
  },
})

-- Spacemacs-style keybindings
local wk = require("which-key")

-- File operations (SPC f)
wk.add({
  { "<leader>f", group = "File" },
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
  { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
  { "<leader>fs", "<cmd>w<cr>", desc = "Save File" },
  { "<leader>fS", "<cmd>wa<cr>", desc = "Save All Files" },
  { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep in Files (rg)" },
  {
    "<leader>fy",
    function()
      local path = vim.fn.expand("%:p")
      vim.fn.setreg("+", path)
      print("Copied: " .. path)
    end,
    desc = "Copy File Path",
  },
  { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "Toggle File Tree" },
  { "<leader>fT", "<cmd>Neotree focus<cr>", desc = "Focus File Tree" },
  { "<leader>fe", group = "Edit" },
  { "<leader>fed", "<cmd>e ~/.config/nvim/init.lua<cr>", desc = "Edit Config" },
  { "<leader>fer", "<cmd>source ~/.config/nvim/init.lua<cr>", desc = "Reload Config" },
})

-- Buffer operations (SPC b)
wk.add({
  { "<leader>b", group = "Buffer" },
  { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },
  { "<leader>bd", "<cmd>bd<cr>", desc = "Delete Buffer" },
  { "<leader>bD", "<cmd>%bd|e#|bd#<cr>", desc = "Delete Other Buffers" },
  { "<leader>bn", "<cmd>bnext<cr>", desc = "Next Buffer" },
  { "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous Buffer" },
  { "<leader>br", "<cmd>e<cr>", desc = "Reload Buffer" },
})

-- Search operations (SPC s)
wk.add({
  { "<leader>s", group = "Search" },
  { "<leader>ss", "<cmd>Telescope live_grep<cr>", desc = "Search Text" },
  { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Search Word Under Cursor" },
  { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Search Files" },
  { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Search Help" },
  { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Search Keymaps" },
  { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Search Commands" },
  { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "Resume Last Search" },
})

-- Window operations (SPC w) - Spacemacs style
wk.add({
  { "<leader>w", group = "Window" },
  { "<leader>wh", "<C-w>h", desc = "Move to Left Window" },
  { "<leader>wj", "<C-w>j", desc = "Move to Bottom Window" },
  { "<leader>wk", "<C-w>k", desc = "Move to Top Window" },
  { "<leader>wl", "<C-w>l", desc = "Move to Right Window" },
  { "<leader>w/", "<cmd>vsplit<cr><C-w>l", desc = "Split Vertical (Spacemacs style)" },
  { "<leader>w-", "<cmd>split<cr><C-w>j", desc = "Split Horizontal (Spacemacs style)" },
  { "<leader>ws", "<cmd>split<cr><C-w>j", desc = "Split Horizontal" },
  { "<leader>wv", "<cmd>vsplit<cr><C-w>l", desc = "Split Vertical" },
  { "<leader>wd", "<C-w>c", desc = "Close Window" },
  { "<leader>wo", "<C-w>o", desc = "Close Other Windows" },
  { "<leader>w=", "<C-w>=", desc = "Balance Windows" },
  { "<leader>w+", "<C-w>+", desc = "Increase Height" },
  { "<leader>w_", "<C-w>-", desc = "Decrease Height" },
  { "<leader>w>", "<C-w>>", desc = "Increase Width" },
  { "<leader>w<", "<C-w><", desc = "Decrease Width" },
  -- Additional Spacemacs-like window commands
  { "<leader>ww", "<C-w>w", desc = "Cycle Through Windows" },
  { "<leader>wW", "<C-w>W", desc = "Cycle Through Windows (Reverse)" },
  { "<leader>wr", "<C-w>r", desc = "Rotate Windows" },
  { "<leader>wR", "<C-w>R", desc = "Rotate Windows (Reverse)" },
  { "<leader>wx", "<C-w>x", desc = "Exchange Windows" },
  { "<leader>wH", "<C-w>H", desc = "Move Window Far Left" },
  { "<leader>wJ", "<C-w>J", desc = "Move Window Far Down" },
  { "<leader>wK", "<C-w>K", desc = "Move Window Far Up" },
  { "<leader>wL", "<C-w>L", desc = "Move Window Far Right" },
  { "<leader>wT", "<C-w>T", desc = "Move Window to New Tab" },
})

-- Git operations (SPC g)
wk.add({
  { "<leader>g", group = "Git" },
  { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
  { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
  { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
  { "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
})

-- Help and quit operations (SPC h, SPC q)
wk.add({
  { "<leader>h", group = "Help" },
  { "<leader>hh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
  { "<leader>hk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  { "<leader>hm", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
  { "<leader>hc", "<cmd>Telescope commands<cr>", desc = "Commands" },
  { "<leader>Q", "<cmd>qa<cr>", desc = "Quit Neovim" },
  { "<leader>q", group = "Quit" },
  { "<leader>qq", "<cmd>q<cr>", desc = "Quit" },
  { "<leader>qQ", "<cmd>q!<cr>", desc = "Force Quit" },
  { "<leader>qs", "<cmd>wq<cr>", desc = "Save and Quit" },
  { "<leader>qa", "<cmd>qa<cr>", desc = "Quit All" },
  { "<leader>qA", "<cmd>qa!<cr>", desc = "Force Quit All" },
})

-- Toggle operations (SPC t)
wk.add({
  { "<leader>t", group = "Toggle" },
  { "<leader>tn", "<cmd>set number!<cr>", desc = "Toggle Line Numbers" },
  { "<leader>tr", "<cmd>set relativenumber!<cr>", desc = "Toggle Relative Numbers" },
  { "<leader>tw", "<cmd>set wrap!<cr>", desc = "Toggle Word Wrap" },
  { "<leader>th", "<cmd>set hlsearch!<cr>", desc = "Toggle Search Highlight" },
})

-- Additional useful keybindings
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Terminal mode escape
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Better up/down with word wrap
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Quick save with Ctrl+S
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>', { desc = 'Save file' })
vim.keymap.set('i', '<C-s>', '<esc><cmd>w<cr>', { desc = 'Save file' })

-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-resize splits when the window is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Remember cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

print("Neovim configuration loaded successfully!")
