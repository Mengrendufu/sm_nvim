---@diagnostic disable: undefined-global
-- ============================================
-- 快捷键配置
-- ============================================
vim.keymap.set('n', 'o', 'o<esc>', { desc = '下方添加空行' })

-- 插入模式下使用 Ctrl+H/L 左右移动光标
vim.keymap.set('i', '<C-h>', '<Left>', { desc = '左移' })
vim.keymap.set('i', '<C-l>', '<Right>', { desc = '右移' })

-- 屏幕左右滚动
vim.keymap.set('n', '<C-h>', '3zh', { desc = '视角左移' })
vim.keymap.set('n', '<C-l>', '3zl', { desc = '视角右移' })

local function Substitute()
    local target = vim.fn.expand('<cword>')
    if target == '' then
        vim.notify('光标下未发现有效单词', vim.log.levels.WARN)
        return
    end
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(':%s/' .. target .. '/', true, false, true),
        'n', false
    )
end

local function SubstituteVisual()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
    local start = vim.fn.getpos("'<")
    local finish = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_text(0, start[2] - 1, start[3] - 1, finish[2] - 1, finish[3], {})
    local target = table.concat(lines, '\n')
    if target == '' then
        vim.notify('未选中任何内容', vim.log.levels.WARN)
        return
    end
    local escaped = vim.fn.escape(target, '/\\')
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(":'<,'>s/" .. escaped .. '/', true, false, true),
        'n', false
    )
end

vim.keymap.set('n', '<leader>es', Substitute, { desc = '交互式全局替换当前单词' })
vim.keymap.set('v', '<leader>es', SubstituteVisual, { desc = '交互式全局替换选中内容' })

-- 快速保存
vim.keymap.set('n', '<leader>fs', ':w<CR>', { desc = '保存文件', silent = true })

-- Fast quit.
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = ' 退出 [原生]' , silent = true})
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { desc = ' 强制退出所有 [原生]' , silent = true})
