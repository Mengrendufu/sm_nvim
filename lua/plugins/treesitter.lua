-- ============================================
-- Treesitter - 语法解析器（完整版）
-- ============================================

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false,

        config = function()
            local languages = {
                -- 核心语言
                "c", "cpp", "lua", "vim", "vimdoc", "query",
                -- 脚本语言
                "javascript", "typescript", "tsx", "bash",
                -- Web开发
                "json", "toml",
                -- 系统编程
                "rust",
            }

            require("nvim-treesitter").setup()

            local missing = require("nvim-treesitter.config").norm_languages(languages, { installed = true })
            if #missing > 0 then
                require("nvim-treesitter").install(missing)
            end

            vim.api.nvim_create_autocmd("FileType", {
                pattern = languages,
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
}
