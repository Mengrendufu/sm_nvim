-- 自动在进入特定片段占位符时清空并进入插入，以便直接覆盖（例如输入 0）
-- 可恢复：此文件独立，可通过删除或注释掉在 nvim-cmp 中的 require 来撤销

local M = {}

-- 手动高亮选择（不会删除文本）。用户在 visual 模式下直接输入字符会替换被选中的文本。
local function visual_select_addr()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    if not line then return end

    -- 匹配 &Name 或 &Name_More，仅匹配由字母数字和下划线组成的名称
    local s, e = string.find(line, "&[%w_]+")
    if not s then return end

    local col_start = s - 1 -- 0-based (byte index)
    -- 为正确处理多字节字符（例如中文标点），用字符长度计算移动次数
    local substr = string.sub(line, s, e)
    local char_len = vim.fn.strchars(substr)
    local dist = char_len - 1 -- number of 'l' moves needed
    if dist < 0 then return end

    -- 退出插入模式（如果在插入），并在下一次调度中设置可视选区
    pcall(vim.cmd, 'stopinsert')
    -- 使用 schedule 确保在退出插入模式后执行设置与恢复可视选择
    vim.schedule(function()
        -- 使用 setpos 直接设置 visual 选择的 '< 和 '> 标记，然后用 normal! gv 恢复可视选择
        -- setpos 的列为 byte-index（1-based），string.find 返回的 s,e 也是 1-based byte 索引
        pcall(vim.fn.setpos, "'<", {0, row, s, 0})
        -- 将 '> 放到 e（最后字符），确保不包含右侧的逗号/括号
        pcall(vim.fn.setpos, "'>", {0, row, e, 0})
    -- 进入普通模式并恢复可视选择
    pcall(vim.cmd, 'normal! gv')
    -- 现在进入 change 模式（c）以便立即进入插入并替换被选中文本
    pcall(vim.cmd, 'normal! c')
    end)
end

function M.manual_select()
    pcall(visual_select_addr)
end

return M
