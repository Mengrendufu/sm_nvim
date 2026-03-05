-- ============================================
-- Mason - LSP/DAP/Linter/Formatter 安装管理器
-- ============================================

return {
    -- Mason 核心插件
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = function()
        require("mason").setup({
            ui = {
            border = "rounded",
            width = 0.8,
            height = 0.8,
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            },
            },
            install_root_dir = vim.fn.stdpath("data") .. "/mason",
            max_concurrent_installers = 4,
        })
        end,
    },

    -- Mason 与 LSP 的桥接插件
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
        require("mason-lspconfig").setup({
            -- 自动安装的 LSP 服务器列表
            ensure_installed = {
            "lua_ls",        -- Lua
            "pyright",       -- Python
            "ts_ls",         -- TypeScript/JavaScript
            "html",          -- HTML
            "cssls",         -- CSS
            "jsonls",        -- JSON
            "clangd",        -- C/C++
            "rust_analyzer", -- Rust
            },
            -- 自动安装
            automatic_installation = true,
        })
        end,
    },
}
