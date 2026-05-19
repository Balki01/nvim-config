-- Personal customizations on top of LazyVim — Linux kernel dev focus.
-- See ~/.config/nvim/CHEATSHEET.md for keybindings.

return {
  -- ── Claude Code IDE integration ────────────────────────────────────────────
  -- snacks.nvim is already provided by LazyVim; just declare the dependency.
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeAdd", "ClaudeCodeSend",
      "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny", "ClaudeCodeSelectModel",
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",                desc = "Claude: toggle" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",           desc = "Claude: focus" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",       desc = "Claude: resume" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>",     desc = "Claude: continue last" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>",     desc = "Claude: pick model" },
      -- ":" not "<cmd>" so % expands to current filename
      { "<leader>ab", ":ClaudeCodeAdd %<cr>",               desc = "Claude: add buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",   mode = "v", desc = "Claude: send selection" },
      { "<leader>aA", "<cmd>ClaudeCodeDiffAccept<cr>",      desc = "Claude: accept diff" },
      { "<leader>aD", "<cmd>ClaudeCodeDiffDeny<cr>",        desc = "Claude: reject diff" },
    },
  },

  -- ── Symbol outline (LazyVim already has trouble; we add aerial too) ───────
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
      { "<leader>cO", "<cmd>AerialToggle<cr>", desc = "Outline (aerial)" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown" },
      layout = { default_direction = "right", min_width = 35 },
      filter_kind = false,
    },
  },

  -- ── Treesitter: add kernel-relevant parsers + textobjects ────────────────
  -- LazyVim already configures nvim-treesitter and includes
  -- nvim-treesitter-textobjects under its hood. We extend the parser list
  -- and the textobjects keymaps via opts callbacks (no setup() override).
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c", "cpp", "rust", "make", "rst", "diff", "gitcommit",
        "git_rebase", "devicetree", "kconfig",
      })

      -- textobjects extensions: function/scope navigation
      opts.textobjects = opts.textobjects or {}
      opts.textobjects.select = vim.tbl_deep_extend("force", opts.textobjects.select or {}, {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
        },
      })
      opts.textobjects.move = vim.tbl_deep_extend("force", opts.textobjects.move or {}, {
        enable = true,
        set_jumps = true,
        goto_next_start     = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
        goto_next_end       = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
        goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
        goto_previous_end   = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
      })
    end,
  },

  -- ── cscope integration for macro-heavy kernel code ────────────────────────
  -- Bound under <leader>j (jump) to avoid colliding with LazyVim's
  -- <leader>f (file/find) submenu.
  {
    "dhananjaylatkar/cscope_maps.nvim",
    dependencies = { "folke/which-key.nvim", "nvim-telescope/telescope.nvim" },
    cmd = { "Cscope", "Cs" },
    keys = {
      { "<leader>js", "<cmd>Cs find s <cword><cr>", desc = "cscope: symbol references" },
      { "<leader>jg", "<cmd>Cs find g <cword><cr>", desc = "cscope: definition" },
      { "<leader>jc", "<cmd>Cs find c <cword><cr>", desc = "cscope: callers" },
      { "<leader>jt", "<cmd>Cs find t <cword><cr>", desc = "cscope: text" },
      { "<leader>jf", "<cmd>Cs find f <cword><cr>", desc = "cscope: file" },
      { "<leader>ji", "<cmd>Cs find i <cword><cr>", desc = "cscope: includes" },
    },
    opts = {
      prefix = "<leader>j",
      cscope = { picker = "telescope", skip_picker_for_single_result = true },
    },
  },

  -- ── Linux kernel coding-style helper (auto kernel formatting on .c) ──────
  { "vivien/vim-linux-coding-style", ft = "c" },

  -- ── DAP debugger (kernel debugging via remote gdb) ────────────────────────
  -- LazyVim has a dap extra; this only adds the gdb adapter for ARM kernels.
  -- Enable LazyVim's dap.core extra first via :LazyExtras.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.adapters.gdb = {
        type = "executable",
        command = "arm-linux-gnueabihf-gdb",
        args = { "-i", "dap" },
      }
      dap.configurations.c = {
        {
          name    = "Remote: kernel via gdb stub",
          type    = "gdb",
          request = "attach",
          target  = "10.40.25.59:1234",
          program = "${workspaceFolder}/vmlinux",
          cwd     = "${workspaceFolder}",
        },
      }
    end,
  },
}
