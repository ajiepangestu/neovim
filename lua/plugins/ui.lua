return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local orange_theme = {
        normal = {
          a = { bg = "#ff9e64", fg = "#1a1a1a", gui = "bold" },
          b = { bg = "#ff6b35", fg = "#ffffff" },
          c = { bg = "#2d2d2d", fg = "#ff9e64" },
        },
        insert = {
          a = { bg = "#a9dc76", fg = "#1a1a1a", gui = "bold" },
          b = { bg = "#78dce8", fg = "#1a1a1a" },
          c = { bg = "#2d2d2d", fg = "#a9dc76" },
        },
        visual = {
          a = { bg = "#ab9df2", fg = "#1a1a1a", gui = "bold" },
          b = { bg = "#fc9867", fg = "#1a1a1a" },
          c = { bg = "#2d2d2d", fg = "#ab9df2" },
        },
        replace = {
          a = { bg = "#ff6188", fg = "#1a1a1a", gui = "bold" },
          b = { bg = "#ff9e64", fg = "#1a1a1a" },
          c = { bg = "#2d2d2d", fg = "#ff6188" },
        },
        command = {
          a = { bg = "#ffd866", fg = "#1a1a1a", gui = "bold" },
          b = { bg = "#ff6b35", fg = "#1a1a1a" },
          c = { bg = "#2d2d2d", fg = "#ffd866" },
        },
        inactive = {
          a = { bg = "#2d2d2d", fg = "#666666" },
          b = { bg = "#2d2d2d", fg = "#666666" },
          c = { bg = "#2d2d2d", fg = "#666666" },
        },
      }

      opts.options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = orange_theme,
      }

      for i, section in ipairs(opts.sections.lualine_b) do
        if type(section) == "table" and section[1] == "filename" then
          table.remove(opts.sections.lualine_b, i)
          break
        end
      end
    end,
  },
}
