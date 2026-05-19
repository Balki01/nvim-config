-- Productivity plugins for daily kernel-dev workflow.
-- See ~/.config/nvim/CHEATSHEET.md for keybindings.

return {
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
