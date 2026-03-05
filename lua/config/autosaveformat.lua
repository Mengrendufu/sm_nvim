---@diagnostic disable: undefined-global
-- ==================== 自动格式化与换行符修复 ====================

-- 1. 核心换行符配置
-- 确保文件末尾有且只有一个换行符
vim.opt.fixeol = true

-- 自动识别顺序，优先 Unix 格式
vim.opt.fileformats = "unix,dos,mac"

-- 3. 保存前置处理：格式清洗
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        if vim.bo.buftype ~= "" then return end
        vim.cmd([[keeppatterns %s/\s\+$//e]])  -- 删除所有空白字符
        vim.cmd([[keeppatterns %s/\r$//e]])    -- 删除行尾的 ^M 字符
        vim.bo.fileformat = 'unix'
    end
})
