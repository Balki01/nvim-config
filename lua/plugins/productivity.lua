-- Productivity plugins for daily kernel-dev workflow.
-- See ~/.config/nvim/CHEATSHEET.md for keybindings.

return {
  -- ── Hover documentation (function signatures, kernel-doc) ──────────────
  -- Press K on any function/macro/type to see its signature, doc comment,
  -- and return type from clangd. Same window also auto-pops after 500ms
  -- of cursor idle on a symbol.
  --
  -- Extra hover providers: dictionary for prose, GitHub for URLs,
  -- man-pages for syscalls.
  {
    "lewis6991/hover.nvim",
    event = "VeryLazy",
    config = function()
      require("hover").setup {
        init = function()
          -- Kernel-focused: only LSP signatures and diagnostics. Skip
          -- man-pages (noise for kernel internals) and dictionary
          -- (irrelevant for C identifiers).
          require("hover.providers.lsp")
          require("hover.providers.diagnostic")
        end,
        preview_opts = { border = "rounded" },
        preview_window = false,
        title = true,
        mouse_providers = { "LSP" },
        mouse_delay = 1000,
      }
      -- Replace default K with hover.nvim's multi-provider hover
      vim.keymap.set("n", "K",       require("hover").hover,        { desc = "hover" })
      vim.keymap.set("n", "gK",      require("hover").hover_select, { desc = "hover (pick provider)" })
      -- Cycle providers when hover popup is open
      vim.keymap.set("n", "<C-p>",   function() require("hover").hover_switch("previous") end, { desc = "hover prev" })
      vim.keymap.set("n", "<C-n>",   function() require("hover").hover_switch("next") end,     { desc = "hover next" })
    end,
  },

  -- ── Signature help while typing function args ─────────────────────────
  -- When you type `regmap_write(` a popup shows each parameter
  -- (name + type) with the active one highlighted. Auto-disappears.
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      bind = true,
      hint_enable = false,        -- no inline hint, just floating popup
      handler_opts = { border = "rounded" },
      floating_window = true,
      floating_window_above_cur_line = true,
      hi_parameter = "Search",    -- highlight active arg
      max_height = 12,
    },
  },

  -- ── Auto-hover on cursor idle (no key press needed) ────────────────────
  -- Triggers vim.lsp.buf.hover() after `updatetime` ms of idle on a
  -- symbol. The popup auto-closes when you move.
  {
    "lewis6991/hover.nvim", -- already declared above; same plugin reused
    optional = true,
    init = function()
      vim.opt.updatetime = 500
      local grp = vim.api.nvim_create_augroup("auto_hover", { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = grp,
        callback = function()
          local ft = vim.bo.filetype
          if ft == "" or ft == "TelescopePrompt" then return end
          local ok, hover = pcall(require, "hover")
          if ok then pcall(hover.hover) end
        end,
      })
    end,
  },

  -- ── Inline git blame (subtle, end of line) ─────────────────────────────
  -- Shows author + age at end of line: "// John, 3 days ago — fix WB offset"
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "Toggle inline git blame" },
      { "<leader>gO", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open blame commit URL" },
      { "<leader>gC", "<cmd>GitBlameCopySHA<cr>", desc = "Copy blame SHA" },
    },
    opts = {
      enabled = false, -- start off; toggle with <leader>gB
      -- <sha> = short commit hash so you can `git show <sha>` directly.
      -- <author> | <date relative> | <summary>
      message_template = " <sha> | <author> | <date> | <summary> ",
      date_format = "%r", -- relative
    },
    -- f-person/git-blame.nvim is configured via vim.g.* options
    config = function(_, opts)
      vim.g.gitblame_enabled = opts.enabled and 1 or 0
      vim.g.gitblame_message_template = opts.message_template
      vim.g.gitblame_date_format = opts.date_format
    end,
  },

  -- ── Diffview: full diff/log UI for code review ─────────────────────────
  -- :DiffviewOpen [rev]            review working tree vs HEAD or rev
  -- :DiffviewFileHistory %         git log of current file
  -- :DiffviewFileHistory           git log of repo
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
      { "<leader>gL", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: log all" },
    },
    opts = {},
  },

  -- ── Fugitive: vim's git command swiss-army knife ───────────────────────
  -- :G                       git status (unstaged, stage with -)
  -- :Gblame                  blame in a side buffer
  -- :Glog -- %               git log of current file
  -- :Gread / :Gwrite         checkout / add
  -- :Gpush  / :Gpull         push / pull
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gstatus", "Gblame", "Gdiff", "Glog",
            "Gread", "Gwrite", "Gpush", "Gpull", "Gfetch" },
    keys = {
      { "<leader>gs", "<cmd>G<cr>",     desc = "Fugitive: status" },
      { "<leader>gl", "<cmd>Glog -- %<cr>", desc = "Fugitive: log file" },
      { "<leader>gp", "<cmd>Git push<cr>",  desc = "Fugitive: push" },
      { "<leader>gP", "<cmd>Git pull<cr>",  desc = "Fugitive: pull" },
    },
  },

  -- ── Structural search & replace (refactor with patterns) ───────────────
  -- Open with <leader>sR. Pattern with $captures, replace with $captures.
  -- Treesitter-aware — won't match inside strings/comments unless asked.
  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        "<leader>sR",
        function() require("ssr").open() end,
        mode = { "n", "x" },
        desc = "Structural search & replace",
      },
    },
    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      keymaps = {
        close              = "q",
        next_match         = "n",
        prev_match         = "N",
        replace_confirm    = "<cr>",
        replace_all        = "<leader><cr>",
      },
    },
  },

  -- ── Spider: smarter w/b/e motions for camelCase + snake_case ───────────
  -- In `microchip_isc_register` pressing `w` jumps word-by-word inside
  -- the identifier (microchip → isc → register), not over the whole thing.
  {
    "chrisgrieser/nvim-spider",
    keys = {
      { "w",  function() require("spider").motion("w")  end, mode = { "n", "o", "x" }, desc = "Spider w" },
      { "e",  function() require("spider").motion("e")  end, mode = { "n", "o", "x" }, desc = "Spider e" },
      { "b",  function() require("spider").motion("b")  end, mode = { "n", "o", "x" }, desc = "Spider b" },
      { "ge", function() require("spider").motion("ge") end, mode = { "n", "o", "x" }, desc = "Spider ge" },
    },
    opts = { skipInsignificantPunctuation = true },
  },

  -- ── Auto-session: per-directory session restore ────────────────────────
  -- When you :cd into a project, the session is restored automatically:
  -- buffers, splits, tabs. When you leave, the session is saved.
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      { "<leader>qs", "<cmd>SessionSave<cr>",    desc = "Save session" },
      { "<leader>ql", "<cmd>SessionRestore<cr>", desc = "Load session" },
      { "<leader>qd", "<cmd>SessionDelete<cr>",  desc = "Delete session" },
    },
    opts = {
      log_level = "error",
      auto_restore_enabled = true,
      auto_save_enabled = true,
      session_lens = { load_on_setup = false },
    },
  },

  -- ── Obsidian / Logseq vault integration ────────────────────────────────
  -- Edits the same notes you keep in ~/logseq-vault from inside nvim.
  -- :ObsidianNew, :ObsidianSearch, :ObsidianToday, :ObsidianFollowLink, etc.
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cmd = {
      "ObsidianNew", "ObsidianSearch", "ObsidianToday", "ObsidianYesterday",
      "ObsidianFollowLink", "ObsidianBacklinks", "ObsidianQuickSwitch",
      "ObsidianTemplate", "ObsidianPasteImg",
    },
    keys = {
      { "<leader>nn", "<cmd>ObsidianNew<cr>",         desc = "Note: new" },
      { "<leader>nt", "<cmd>ObsidianToday<cr>",       desc = "Note: today's daily" },
      { "<leader>nT", "<cmd>ObsidianTemplate<cr>",    desc = "Note: insert template" },
      { "<leader>nf", "<cmd>ObsidianQuickSwitch<cr>", desc = "Note: switch" },
      { "<leader>ns", "<cmd>ObsidianSearch<cr>",      desc = "Note: search vault" },
      { "<leader>nb", "<cmd>ObsidianBacklinks<cr>",   desc = "Note: backlinks" },
      { "<leader>nl", "<cmd>ObsidianFollowLink<cr>",  desc = "Note: follow link" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        { name = "logseq", path = vim.fn.expand("~/logseq-vault") },
      },
      daily_notes = {
        folder  = "journals",   -- Logseq's default daily-notes location
        date_format = "%Y_%m_%d",
      },
      completion = { nvim_cmp = false, blink = true },
      ui = { enable = false }, -- avoid conflict with render-markdown.nvim
    },
  },
}
