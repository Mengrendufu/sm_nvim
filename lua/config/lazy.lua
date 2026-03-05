---@diagnostic disable: undefined-global
-- lazy.nvim =================================================================
-- Bootstrap lazy.nvim...
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field -- Ignore the warning.
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",  -- 部分克隆，节省空间和时间
        "--branch=stable",     -- 使用稳定分支
        lazyrepo,
        lazypath
    })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- Add lazy.nvim to runtime path...
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim............................................................
require("lazy").setup({
    -- 插件规范
    spec = {
        -- 从 lua/plugins/ 目录导入所有插件配置
        { import = "plugins" },
    },

    -- 安装设置
    install = {
        colorscheme = { "habamax" }  -- 安装插件时使用的临时配色
    },

    -- 更新检查
    checker = {
        enabled = true,              -- 启用自动检查更新
        notify = false,              -- 不显示更新通知（避免干扰）
    },

    -- 性能优化
    performance = {
        rtp = {
        -- 禁用一些不需要的内置插件
        disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
        },
        },
    },

    -- UI 设置
    ui = {
        border = "rounded",  -- 使用圆角边框
    },
    vim.keymap.set('n', '<leader>L', ':Lazy<CR>',
        { desc = ' 打开 Lazy 插件管理器 [Lazy.nvim]' }),

    print("Lazy is loaded.");
})
