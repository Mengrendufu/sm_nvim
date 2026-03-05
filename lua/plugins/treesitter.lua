-- ============================================
-- Treesitter - 语法解析器（完整版）
-- ============================================

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",  -- ← 使用旧的稳定分支
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },

        config = function()
        require('nvim-treesitter.install').prefer_git = true
        require("nvim-treesitter.configs").setup({
            -- 安装的语言
            ensure_installed = {
                -- 核心语言
                "c", "cpp", "lua", "vim", "vimdoc", "query",
                -- 脚本语言
                "python", "javascript", "typescript", "bash",
                -- Web开发
                "html", "css", "scss", "json", "yaml", "toml",
                -- 系统编程
                "rust", "go", "java", "c_sharp",
                -- 标记语言
                "markdown", "markdown_inline",
                -- "latex",
                -- 配置文件
                "dockerfile", "make", "cmake",
                -- 其他常用
                "sql", "regex", "comment"
            },

            -- 安装选项
            sync_install = false,      -- 同步安装（默认false，异步安装）
            ignore_install = { "latex" },       -- 要忽略安装的语言列表
            modules = {},              -- 自定义模块配置

            -- 自动安装
            auto_install = true,

            -- 语法高亮
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            -- 增量选择
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    scope_incremental = "<S-CR>",
                    node_decremental = "<BS>",
                },
            },

            -- 智能缩进
            indent = {
                enable = true,
            },
        })
        end,
    },
}
