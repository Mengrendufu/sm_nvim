-- Leader mapping ============================================================
vim.g.mapleader = " "        -- "Space" as leader
vim.g.maplocalleader = "\\"  -- "\"     as local leader
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
if vim.fn.has("win32") == 1 then
    vim.g.python3_host_prog = 'python3.exe'
else
    vim.g.python3_host_prog = 'python3'
end

if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "WslClipboard",
        copy = {
            ["+"] = "/mnt/c/Windows/System32/clip.exe",
            ["*"] = "/mnt/c/Windows/System32/clip.exe",
        },
        paste = {
            ["+"] = { "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", "-NoLogo", "-NoProfile", "-Command", "Get-Clipboard" },
            ["*"] = { "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", "-NoLogo", "-NoProfile", "-Command", "Get-Clipboard" },
        },
        cache_enabled = 0,
    }
end

-- Config modules ============================================================
require("config.neovide")
require("config.lazy")
require("config.keymaps")
require("config.autosaveformat")
require("config.tabline")
require("config.sm_snippets")

-- Filetype configuration ====================================================
vim.filetype.add({
    extension = {
        json = "jsonc",  -- 让 .json 文件也使用 jsonc 的 snippets 和 LSP 配置
        h    = "c",
    },
})

-- Neovim basic config =======================================================
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.colorcolumn = "79"         -- Ruler display.
vim.opt.number = true              -- 显示行号
vim.opt.relativenumber = true      -- 显示相对行号
vim.opt.signcolumn = "yes"         -- 始终显示符号列（避免抖动）
vim.opt.cursorline = true          -- 高亮当前行

vim.opt.tabstop = 4                -- Tab 显示为 4 个空格
vim.opt.shiftwidth = 4             -- 缩进宽度为 4
vim.opt.expandtab = true           -- 使用空格代替 Tab
vim.opt.softtabstop = 4            -- 编辑时 tab 键插入 4 个空格
vim.opt.smartindent = true         -- 智能缩进
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "▸ ",
  trail = "·",
  extends = ">",
  precedes = "<",
  leadmultispace = "┆   "
}
vim.opt.showbreak = "│   "
vim.opt.breakindentopt = "shift:2"

vim.opt.ignorecase = true          -- 搜索时忽略大小写
vim.opt.smartcase = true           -- 如果包含大写字母则区分大小写
vim.opt.hlsearch = true            -- 高亮搜索结果
vim.opt.incsearch = true           -- 增量搜索
vim.opt.inccommand = 'nosplit'     -- 实时预览替换结果（:s 时高亮匹配）

vim.opt.termguicolors = true       -- 启用真彩色
vim.opt.mouse = "a"                -- 启用鼠标支持
vim.opt.splitright = true          -- 垂直分割窗口在右边
vim.opt.splitbelow = true          -- 水平分割窗口在下边

vim.opt.updatetime = 333           -- 更新时间（毫秒）
vim.opt.timeoutlen = 333           -- 按键序列超时时间
vim.opt.ttimeoutlen = 100          -- 终端按键 escape 超时时间

vim.opt.undofile = true            -- 启用持久化撤销
vim.opt.clipboard = "unnamedplus"  -- 使用系统剪贴板
vim.opt.wrap = false               -- 不自动换行

if vim.fn.has("win32") == 1 then
    vim.opt.shell = vim.loop.os_getenv("NEOVIM_TERM_NAME") or "pwsh"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
end

-- ===========================================================================
-- 参考 aider.nvim 优化的主动文件监听同步器
-- ===========================================================================
vim.opt.autoread = true
local uv = vim.uv or vim.loop
local watchers = {} -- 用于存储每个 buffer 的监听器

local gitdir_poll_timer = nil
local git_mtimes = {}
local gitdir_poll_path = nil
local function start_gitdir_poll()
    local gitdir = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
    if gitdir == "" then
        return
    end

    gitdir = vim.fn.fnamemodify(gitdir, ":p")

    -- 同一个 .git 不重建 timer，防止丢失 mtime 快照
    if gitdir == gitdir_poll_path then
        return
    end

    if gitdir_poll_timer then
        gitdir_poll_timer:stop()
    end

    gitdir_poll_path = gitdir
    git_mtimes = {}

    local watch_files = {
        gitdir .. "index",
        gitdir .. "HEAD",
        gitdir .. "refs",
    }

    gitdir_poll_timer = uv.new_timer()
    gitdir_poll_timer:start(0, 2000, vim.schedule_wrap(function()
        local changed = false
        for _, f in ipairs(watch_files) do
            local stat = uv.fs_stat(f)
            if stat then
                local mt = stat.mtime
                if git_mtimes[f] and (mt.sec ~= git_mtimes[f].sec or mt.nsec ~= git_mtimes[f].nsec) then
                    changed = true
                end
                git_mtimes[f] = { sec = mt.sec, nsec = mt.nsec }
            end
        end
        if changed then
            -- 遍历所有 buffer 触发 gitsigns on_reload
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" and not vim.bo[bufnr].modified then
                    vim.api.nvim_buf_call(bufnr, function()
                        pcall(vim.cmd, "silent! edit")
                    end)
                end
            end
            -- 刷新 Neo-tree filesystem 视图
            pcall(function() require("neo-tree.sources.manager").refresh("filesystem") end)
        end
    end))
end

local function notify_lsp_external_change(bufnr, path)
    if path == "" then
        return
    end

    local uri = vim.uri_from_fname(path)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client:supports_method("workspace/didChangeWatchedFiles") then
            client:notify("workspace/didChangeWatchedFiles", {
                changes = {
                    {
                        uri = uri,
                        type = 2, -- Changed
                    },
                },
            })
        end

        if client:supports_method("textDocument/didSave") then
            client:notify("textDocument/didSave", {
                textDocument = { uri = uri },
            })
        end
    end
end

local function stop_watcher(bufnr)
    if watchers[bufnr] then
        watchers[bufnr]:stop()
        watchers[bufnr] = nil
    end
end

local function start_watcher(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    -- 仅监听存在的本地普通文件
    if path == "" or vim.bo[bufnr].buftype ~= "" or not vim.uv.fs_stat(path) then
        return
    end

    stop_watcher(bufnr) -- 确保不重复监听

    local w = uv["new_fs_event"]()
    if w then
        watchers[bufnr] = w
        -- 参考 aider.nvim: 监听文件重命名(rename)和修改(change)
        w:start(path, {}, vim.schedule_wrap(function(err, filename, events)
            if err then
                stop_watcher(bufnr)
                return
            end

            -- 当检测到变动时，执行静默同步
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("silent! checktime")
                end)
            end
        end))
    end
end

-- 自动管理监听器的生命周期
local watch_grp = vim.api.nvim_create_augroup("AiderStyleWatcher", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = watch_grp,
    callback = function(args) start_watcher(args.buf) end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = watch_grp,
    callback = function(args)
        local path = vim.api.nvim_buf_get_name(args.buf)
        notify_lsp_external_change(args.buf, path)
        start_watcher(args.buf)
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    group = watch_grp,
    callback = function(args) stop_watcher(args.buf) end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = watch_grp,
    callback = start_gitdir_poll,
})
