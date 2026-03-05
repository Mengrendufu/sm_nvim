-- ============================================
-- Comment.nvim - 智能注释（with Treesitter）
-- ============================================

return {
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            -- Treesitter 集成
            require("ts_context_commentstring").setup({
                enable_autocmd = false,
            })

            require("Comment").setup({
                -- 基本配置
                padding = true,
                sticky = true,
                ignore = "^$",

                -- 快捷键
                toggler = {
                    line = "gcc",
                    block = "gbc",
                },
                opleader = {
                    line = "gc",
                    block = "gb",
                },
                extra = {
                    above = "gcO",
                    below = "gco",
                    eol = "gcA",
                },

                -- 启用映射
                mappings = {
                    basic = true,
                    extra = true,
                },

                -- Treesitter 集成（智能识别注释格式）
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },

    -- Treesitter 上下文注释
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
    },
}

