---@diagnostic disable: undefined-global
-- 多光标编辑插件：mg979/vim-visual-multi
return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    vim.g.VM_default_mappings = 1
    -- 如需自定义 keymap，可补充 vim.g.VM_maps
  end,
}
