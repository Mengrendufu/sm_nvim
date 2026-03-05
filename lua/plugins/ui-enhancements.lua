-- ============================================
-- UI 增强插件
-- ============================================

return {
    -- 显示 LSP 加载进度
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {
        notification = {
            window = {
            winblend = 0,
            border = "rounded",
            },
        },
        },
    },

    -- 显示函数签名
    {
        "ray-x/lsp_signature.nvim",
        event = "LspAttach",
        opts = {
        bind = true,
        handler_opts = {
            border = "rounded",
        },
        hint_enable = false,
        floating_window = true,
        toggle_key = "<C-k>",
        },
    },
}
