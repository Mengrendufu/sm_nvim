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

-- 定义 Substitute 函数
local function Substitute()
    -- 获取光标下的单词 (Current Word)
    local target = vim.fn.expand("<cword>")

    if target == "" then
        vim.notify("光标下未发现有效单词", vim.log.levels.WARN)
        return
    end

    -- 调用交互式输入框
    vim.ui.input({
        prompt = '将 "' .. target .. '" 替换为: ',
        default = "", -- 默认为空，方便直接输入新词
    }, function(replacement)
        -- 如果用户取消输入 (ESC) 或输入为空，则跳过
        if not replacement or replacement == "" then
            return
        end

        -- 构建替换指令
        -- %s: 全局范围; /g: 行内全部替换; /e: 找不到时不报错
        -- 使用 \V (very magic) 模式确保特殊字符被视为普通字符处理
        local cmd = string.format("%%s/\\V%s/%s/ge", target, replacement)

        -- 执行命令并捕获状态
        local status, err = pcall(vim.api.nvim_command, cmd)

        if status then
            -- 获取受影响的行数（可选反馈）
            vim.notify(string.format("已完成替换: %s -> %s", target, replacement), vim.log.levels.INFO)
        else
            vim.notify("替换执行出错: " .. err, vim.log.levels.ERROR)
        end
    end)
end

-- 映射快捷键 (使用 <leader>s 以匹配 Substitute 的首字母)
vim.keymap.set('n', '<leader>es', Substitute, { desc = '交互式全局替换当前单词' })

-- 快速保存
vim.keymap.set('n', '<leader>fs', ':w<CR>', { desc = '保存文件', silent = true })

-- Fast quit.
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = ' 退出 [原生]' , silent = true})
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', { desc = ' 强制退出所有 [原生]' , silent = true})

-- Fast move.
vim.keymap.set('n', '<leader>k', '<C-w>l', { desc = ' 移动到上方窗口 [原生]' , silent = true})
vim.keymap.set('n', '<leader>j', '<C-w>l', { desc = ' 移动到下方窗口 [原生]' , silent = true})
vim.keymap.set('n', '<leader>h', '<C-w>l', { desc = ' 移动到左方窗口 [原生]' , silent = true})
vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = ' 移动到右方窗口 [原生]' , silent = true})
