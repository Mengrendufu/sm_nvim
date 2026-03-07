---@diagnostic disable: undefined-global
-- ============================================
-- 配色方案插件
-- ============================================

return {
    -- Catppuccin 主题 - 流行且稳定的配色方案
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,  -- 确保在其他插件之前加载
        config = function()
            require("catppuccin").setup({
                -- Font style
                styles = {
                    comments = {},
                    conditionals = {},        -- 置空即为默认正体
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
                -- 风格选项: latte, frappe, macchiato, mocha
                flavour = "mocha",  -- 深色主题

                -- 背景透明度
                transparent_background = true,

                -- 终端颜色
                term_colors = true,

                -- 集成设置
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    treesitter = true,
                    semantic_tokens = true,  -- LSP semantic token 着色
                    notify = false,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                },
            })

            -- 应用配色方案
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
