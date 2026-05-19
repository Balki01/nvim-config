-- Personal customizations on top of LazyVim — Linux kernel dev focus.
-- See ~/.config/nvim/CHEATSHEET.md for keybindings.

return {
  -- ── CodeCompanion: chat + inline edits via Claude (Copilot or API) ───────
  -- Tries adapters in this order (first one that authenticates wins):
  --   1. copilot (GitHub Copilot subscription, includes Claude Sonnet 4.5)
  --   2. anthropic (raw ANTHROPIC_API_KEY, console.anthropic.com)
  --
  -- Switch on the fly with: :CodeCompanionAdapter
  --
  -- Bindings:
  --   <leader>aa   chat (sidebar) - works in normal & visual mode
  --   <leader>ae   inline edit - visual select then type instructions
  --   <leader>ap   action palette - quick presets (explain, refactor, ...)
  --   <leader>at   toggle the chat window
  --   <leader>ar   reset the chat
  {
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions",
      "CodeCompanionToggle", "CodeCompanionAdd", "CodeCompanionAdapter",
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>",   desc = "CodeCompanion: chat",          mode = { "n", "v" } },
      { "<leader>ae", "<cmd>CodeCompanion<cr>",              desc = "CodeCompanion: inline edit",   mode = "v" },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>",       desc = "CodeCompanion: action palette" },
      { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>",   desc = "CodeCompanion: toggle chat" },
      { "<leader>ar", "<cmd>CodeCompanionChat<cr>",          desc = "CodeCompanion: new chat" },
      { "<leader>aA", "<cmd>CodeCompanionAdd<cr>",           desc = "CodeCompanion: add to chat",   mode = { "n", "v" } },
      { "<leader>am", "<cmd>CodeCompanionAdapter<cr>",       desc = "CodeCompanion: switch adapter" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = { default = "claude-sonnet-4-5-20250929" },
              max_tokens = { default = 8192 },
            },
          })
        end,
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = { default = "claude-sonnet-4.5" },
            },
          })
        end,
      },
      strategies = {
        -- "copilot" first; falls back to anthropic if copilot auth missing
        chat   = { adapter = "copilot" },
        inline = { adapter = "copilot" },
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            width  = 0.40,
            height = 0.85,
            border = "rounded",
          },
          show_settings = true,
          show_token_count = true,
        },
        diff = { provider = "default" },
      },
    },
  },

  -- ── Claude Code (terminal CLI in a pane) ──────────────────────────────────
  -- Now under <leader>p* (Pane) since avante owns <leader>a*.
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeAdd", "ClaudeCodeSend",
      "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny", "ClaudeCodeSelectModel",
    },
    keys = {
      { "<leader>pc", "<cmd>ClaudeCode<cr>",                desc = "Claude pane: toggle" },
      { "<leader>pf", "<cmd>ClaudeCodeFocus<cr>",           desc = "Claude pane: focus" },
      { "<leader>pr", "<cmd>ClaudeCode --resume<cr>",       desc = "Claude pane: resume" },
      { "<leader>pC", "<cmd>ClaudeCode --continue<cr>",     desc = "Claude pane: continue last" },
      { "<leader>pm", "<cmd>ClaudeCodeSelectModel<cr>",     desc = "Claude pane: pick model" },
      -- ":" not "<cmd>" so % expands
      { "<leader>pb", ":ClaudeCodeAdd %<cr>",               desc = "Claude pane: add buffer" },
      { "<leader>ps", "<cmd>ClaudeCodeSend<cr>",   mode = "v", desc = "Claude pane: send selection" },
      { "<leader>pa", "<cmd>ClaudeCodeDiffAccept<cr>",      desc = "Claude pane: accept diff" },
      { "<leader>pd", "<cmd>ClaudeCodeDiffDeny<cr>",        desc = "Claude pane: reject diff" },
      -- Hover-with-Claude: explain symbol under cursor in the pane
      {
        "<leader>ph",
        function()
          local word = vim.fn.expand("<cword>")
          local file = vim.fn.expand("%:t")
          if word == "" then
            vim.notify("No word under cursor", vim.log.levels.WARN)
            return
          end
          vim.cmd("ClaudeCode")
          -- Send a focused explanation prompt
          local prompt = string.format("Explain `%s` in %s: what it is, how it's used, and any gotchas.", word, file)
          vim.defer_fn(function()
            vim.cmd("ClaudeCodeSend " .. vim.fn.shellescape(prompt))
          end, 200)
        end,
        desc = "Claude pane: explain word under cursor",
      },
    },
  },

  -- ── Symbol outline ─────────────────────────────────────────────────────────
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

  -- ── Treesitter: kernel parsers + textobjects via LazyVim's spec ──────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c", "cpp", "rust", "make", "rst", "diff", "gitcommit",
        "git_rebase", "devicetree", "kconfig",
      })
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

  -- ── Linux kernel coding-style helper ──────────────────────────────────────
  { "vivien/vim-linux-coding-style", ft = "c" },

  -- ── DAP gdb adapter for ARM kernel ────────────────────────────────────────
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
