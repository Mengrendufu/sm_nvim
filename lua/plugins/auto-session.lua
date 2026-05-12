-- ============================================
-- auto-session - 自动会话管理
-- ============================================

return {
    {
        "rmagatti/auto-session",
        lazy = false,
        opts = {
            -- Session 保存目录: ~/.local/share/nvim/sessions/
            auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",

            -- 自动保存（退出时）
            auto_save_enabled = true,

            -- 自动恢复（启动 nvim 时）
            auto_restore_enabled = true,

            -- 不在这些目录创建 session
            auto_session_suppress_dirs = { "~/", "~/.config", "/tmp" },
        },
        config = function(_, opts)
            require("auto-session").setup(opts)

            -- 手动操作快捷键
            vim.keymap.set("n", "<leader>Ss", ":SessionSave<CR>",
                { desc = "保存 Session", silent = true })
            vim.keymap.set("n", "<leader>Sr", ":SessionRestore<CR>",
                { desc = "恢复 Session", silent = true })
            vim.keymap.set("n", "<leader>Sd", ":SessionDelete<CR>",
                { desc = "删除当前 Session", silent = true })
            vim.keymap.set("n", "<leader>Sq", function()
                vim.cmd("SessionSave")
                vim.cmd("qa")
            end, { desc = "保存 Session 并退出", silent = true })
        end,
    },
}
