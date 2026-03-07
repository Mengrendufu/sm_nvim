---@diagnostic disable: undefined-global
-- lua/plugins/gitsigns.lua
return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- 延迟加载，提高启动速度
    opts = {
        watch_gitdir = { interval = 1000, follow_files = true },

        -- 自定义图标，与你的 Neo-tree 风格保持一致
        signs = {
            add          = { text = "┃" }, -- 或者用 "󰐕"
            change       = { text = "┃" }, -- 或者用 "󰏫"
            delete       = { text = "_" },
            topdelete    = { text = "‾" },
            changedelete = { text = "~" },
            untracked    = { text = "┆" },
        },
        signcolumn = true,  -- 开启行号左侧的标识列
        numhl      = true,  -- 开启此项可以让行号也跟着变色
        linehl     = false, -- 开启此项可以高亮整行（通常不建议，视觉太乱）
        word_diff  = false, -- 在行内显示更细致的差异

        -- 悬浮窗预览差异 (非常实用)
        preview_config = {
            border = 'rounded', -- 圆角边框，适配 Neovide
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
        },

        -- 确保在索引改变时立即更新
        update_debounce = 100, -- 防抖时间调低，提高响应速度

        -- 绑定一些常用的 Git 快捷键
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- 快捷键：查看当前行变更详情 (Preview Hunk)
            map('n', '<leader>gp', gs.preview_hunk, { desc = '预览当前行 Git 变更' })

            -- 快捷键：跳转到上一个/下一个变更点
            map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
            end, { expr = true, desc = '下一个变更点' })

            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
            end, { expr = true, desc = '上一个变更点' })
        end
    },
}
