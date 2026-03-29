return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  event = "VeryLazy",
  keys = {
    {
      "<leader>I",
      function()
        require("multicursor-nvim").matchAddCursor(1)
      end,
      mode = { "n", "x" },
      desc = "匹配下一个并添加多光标",
    },
    {
      "<leader>S",
      function()
        require("multicursor-nvim").matchSkipCursor(1)
      end,
      mode = { "n", "x" },
      desc = "跳过下一个匹配项",
    },
    {
      "<leader>i",
      function()
        require("multicursor-nvim").toggleCursor()
      end,
      mode = { "n", "x" },
      desc = "在当前位置切换多光标",
    },
  },
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    mc.addKeymapLayer(function(set)
      set("n", "<Esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
