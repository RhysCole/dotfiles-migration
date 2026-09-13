return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",

    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Obsidian",
        },
      },

      daily_notes = {
        folder = "Daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
      },

      completion = {
        nvim_cmp = true,
      },

      wiki_link_func = "prepend_note_id",

      new_notes_location = "current_dir",

      templates = {
        folder = "Templates",
      },
    },
  },
}
