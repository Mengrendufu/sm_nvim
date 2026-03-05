-- 原生标签页（tabpage）风格的 tabline

vim.opt.showtabline = 2

-- 获取文件类型图标（可选）
local function get_icon(filename)
    if not vim.g.have_nerd_font then
        return ""
    end

    local ext = vim.fn.fnamemodify(filename, ":e")
    local icons = {
        lua = "",
        vim = "",
        c = "",
        cpp = "",
        h = "",
        hpp = "",
        py = "",
        js = "",
        ts = "",
        rs = "",
        go = "",
        html = "",
        css = "",
        md = "",
        txt = "",
        json = "",
        yaml = "",
        toml = "",
    }
    return icons[ext] or ""
end

function _G.custom_tabline()
    local s = ""
    local current_tab = vim.fn.tabpagenr()
    local total_tabs = vim.fn.tabpagenr("$")

    for tabnr = 1, total_tabs do
        -- 高亮
        if tabnr == current_tab then
        s = s .. "%#TabLineSel#"
        else
        s = s .. "%#TabLine#"
        end

        -- 点击事件
        s = s .. "%" .. tabnr .. "T"

        -- 获取文件信息
        local winnr = vim.fn.tabpagewinnr(tabnr)
        local buflist = vim.fn.tabpagebuflist(tabnr)
        local bufnr = buflist[winnr]
        local bufname = vim.fn.bufname(bufnr)
        local filename = vim.fn.fnamemodify(bufname, ":t")

        if filename == "" then
        filename = "[无名]"
        end

        -- 截断长文件名
        local max_len = 15
        if #filename > max_len then
        filename = filename:sub(1, max_len - 3) .. "..."
        end

        -- 图标（可选，如果不需要可以删除这部分）
        local icon = get_icon(filename)
        if icon ~= "" then
        icon = icon .. " "
        end

        -- 修改标记
        local is_modified = vim.fn.getbufvar(bufnr, "&modified") == 1
        local modified_marker = is_modified and "+" or ""

        -- 组合显示：序号:文件名+
        s = s .. " " .. tabnr .. ":" .. icon .. filename .. modified_marker .. " "

        -- 分隔符
        if tabnr < total_tabs then
        s = s .. "%#TabLineFill#│"
        end
    end

    -- 填充和关闭按钮
    s = s .. "%#TabLineFill#%=%#TabLine# × "

    return s
end

vim.opt.tabline = "%!v:lua.custom_tabline()"

-- ==================== 快捷键配置 ====================
-- 标签页管理
vim.keymap.set("n", "<leader>wtn", ":tab split<CR>", { desc = "在新标签页打开当前文件", silent = true })
vim.keymap.set("n", "<leader>wtN", ":tabnew<CR>", { desc = "新建空标签页", silent = true })
vim.keymap.set("n", "<leader>wtm", "<C-W>T", { desc = "移动窗口到新标签页", silent = true })
vim.keymap.set("n", "<leader>wtc", ":tabclose<CR>", { desc = "关闭当前标签页", silent = true })
vim.keymap.set("n", "<leader>wto", ":tabonly<CR>", { desc = "只保留当前标签页", silent = true })
vim.keymap.set("n", "<leader>wte", ":tabedit ", { desc = "在新标签页打开文件" })

-- 左右切换标签页
vim.keymap.set("n", "<A-h>", ":tabprevious<CR>", { desc = "上一个标签页", silent = true })
vim.keymap.set("n", "<A-l>", ":tabnext<CR>", { desc = "下一个标签页", silent = true })
-- 移动标签页位置
vim.keymap.set("n", "<A-H>", ":-tabmove<CR>", { desc = "标签页左移", silent = true })
vim.keymap.set("n", "<A-L>", ":+tabmove<CR>", { desc = "标签页右移", silent = true })
