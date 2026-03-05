-- ============================================
-- which-key.nvim - 快捷键提示插件
-- ============================================

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",  -- 延迟加载以提高启动速度
        opts = {
        -- 预设风格: "classic", "modern", "helix"
        preset = "classic",

        -- 延迟显示时间（毫秒）
        delay = function(ctx)
            return ctx.plugin and 0 or 200
        end,

        -- 通知设置
        notify = true,

        -- 内置插件配置
        plugins = {
            marks = true,      -- 显示 marks 列表在 ' 和 `
            registers = true,  -- 显示 registers 在 " (normal) 或 <C-r> (insert)
            spelling = {
            enabled = true,  -- z= 时显示拼写建议
            suggestions = 20,
            },
            presets = {
            operators = true,     -- 操作符帮助 (d, y, c 等)
            motions = true,       -- 移动帮助
            text_objects = true,  -- 文本对象帮助
            windows = true,       -- <c-w> 窗口命令
            nav = true,           -- 杂项绑定
            z = true,             -- z 开头的命令
            g = true,             -- g 开头的命令
            },
        },

        -- 窗口配置
        win = {
            border = "rounded",     -- 边框样式
            padding = { 1, 2 },     -- 内边距 [上下, 左右]
            title = true,           -- 显示标题
            title_pos = "center",   -- 标题位置
            zindex = 1000,
            wo = {
            winblend = 0,         -- 窗口透明度 (0-100)
            },
        },

        -- 布局配置
        layout = {
            width = { min = 20 },   -- 最小宽度
            spacing = 3,            -- 列间距
        },

        -- 排序规则
        sort = { "local", "order", "group", "alphanum", "mod" },

         -- 图标配置
         icons = {
             breadcrumb = "»",       -- 命令行中显示的符号
             separator = "",        -- 键和标签之间的符号 (Nerd Font右箭头)
             group = "",            -- 组前缀符号 (右箭头)
             ellipsis = "…",
            mappings = true,        -- 启用映射图标
            colors = true,          -- 使用颜色
            keys = {
            Up = " ",
            Down = " ",
            Left = " ",
            Right = " ",
            C = "󰘴 ",
            M = "󰘵 ",
            D = "󰘳 ",
            S = "󰘶 ",
            CR = "󰌑 ",
            Esc = "󱊷 ",
            ScrollWheelDown = "󱕐 ",
            ScrollWheelUp = "󱕑 ",
            NL = "󰌑 ",
            BS = "󰁮",
            Space = "󱁐 ",
            Tab = "󰌒 ",
            },
        },

        -- 显示帮助和按键信息
        show_help = true,
        show_keys = true,

        -- 禁用的文件类型和缓冲区类型
        disable = {
            ft = {},
            bt = {},
        },
        },

        config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

         -- 注册快捷键组和描述（按功能严格分类，标注来源）
         wk.add({
              -- ==================== 文件操作 (File) ====================
              { "<leader>f", group = " 文件操作" },
              { "<leader>fe", desc = " 切换文件树 [Neo-tree插件]" },
              { "<leader>fo", desc = " 聚焦文件树 [Neo-tree插件]" },
              { "<leader>fE", desc = " 在文件树中显示当前文件 [Neo-tree插件]" },

              -- ==================== 窗口/标签页 (Window/Tab) ====================
              { "<leader>w", group = " 窗口/标签页", proxy = "<c-w>" },
              -- 窗口操作
              { "<leader>ww", desc = " 切换窗口 [原生]" },
              { "<leader>wd", desc = " 关闭当前窗口 [原生]" },
              { "<leader>w-", desc = " 水平分割 [原生]" },
              { "<leader>w|", desc = " 垂直分割 [原生]" },
              { "<leader>wh", desc = " 移动到左侧窗口 [原生]" },
              { "<leader>wj", desc = " 移动到下方窗口 [原生]" },
              { "<leader>wk", desc = " 移动到上方窗口 [原生]" },
              { "<leader>wl", desc = " 移动到右侧窗口 [原生]" },
              -- 标签页操作
              { "<leader>wtn", desc = " 在新标签页打开当前文件 [原生]" },
              { "<leader>wtN", desc = " 新建空标签页 [原生]" },
              { "<leader>wtm", desc = " 移动窗口到新标签页 [原生]" },
              { "<leader>wtc", desc = " 关闭当前标签页 [原生]" },
              { "<leader>wto", desc = " 只保留当前标签页 [原生]" },
              { "<leader>wte", desc = " 在新标签页打开文件 [原生]" },

              -- ==================== 编辑操作 (Edit) ====================
              { "<leader>e", group = " 编辑操作" },
              { "<leader>es", desc = " 交互式全局替换当前单词 [自定义函数]" },

              -- ==================== 代码操作 (Code) ====================
              { "<leader>c", group = " 代码操作" },
              -- LSP 核心功能
              { "<leader>ca", desc = " 代码操作 [LSP]" },
              { "<leader>rn", desc = " 重命名符号 [LSP]" },
              { "<leader>cf", desc = " 格式化代码 [LSP]" },
              -- 诊断相关
              { "<leader>cdl", desc = " 显示诊断详情 [LSP]" },
              { "<leader>cdq", desc = " 诊断列表 [LSP]" },
              -- C/C++ 特定
              { "<leader>ch", desc = " 切换头文件/源文件 [clangd]" },
              { "<leader>cih", desc = " 切换 inlay hints [clangd]" },

              -- ==================== 终端操作 (Terminal) ====================
              { "<leader>t", group = " 终端操作" },
              -- 终端发送
              { "<leader>tsp", desc = " 发送粘贴文本到终端1 [Toggleterm插件]" },
              { "<leader>ts2p", desc = " 发送粘贴文本到终端2 [Toggleterm插件]" },
              { "<leader>tsl", desc = " 发送当前行/可视行到终端1 [Toggleterm插件]" },
              { "<leader>tss", desc = " 发送精确选择到终端1 [Toggleterm插件]" },
              { "<leader>ts2l", desc = " 发送当前行到终端2 [Toggleterm插件]" },

              -- ==================== 搜索/高亮 (Search) ====================
              { "<leader>s", group = " 搜索/高亮" },
              -- 高亮操作
              { "<leader>sh", desc = " 高亮所有文件中的当前词 [Illuminate插件]" },
              { "<leader>sc", desc = " 清除所有文件的高亮 [Illuminate插件]" },

              -- ==================== Git 操作 (Git) ====================
              { "<leader>g", group = " Git 操作" },
              { "<leader>gs", desc = " 显示 Git 状态 [Neo-tree插件]" },
              { "<leader>gp", desc = " 预览当前行 Git 变更 [Gitsigns插件]" },

              -- ==================== UI 切换 (UI) ====================
              { "<leader>u", group = " UI 切换" },
              { "<leader>un", desc = " 切换行号 [原生]" },
              { "<leader>ur", desc = " 切换相对行号 [原生]" },
              { "<leader>uw", desc = " 切换自动换行 [原生]" },
              { "<leader>us", desc = " 切换拼写检查 [原生]" },

             -- ==================== 其他操作 ====================
              -- 缓冲区操作
              { "<leader>bd", desc = " 删除缓冲区 [原生]" },
              { "<leader>bn", desc = " 下一个缓冲区 [原生]" },
              { "<leader>bp", desc = " 上一个缓冲区 [原生]" },

              -- 快速保存和退出
               { "<leader>fs", desc = " 保存文件 [原生]" },
              { "<leader>q",   desc = " 退出 [原生]" },
              { "<leader>Q",   desc = " 强制退出所有 [原生]" },

              -- 插件管理器
              { "<leader>L", desc = " 打开 Lazy 插件管理器 [Lazy.nvim]" },

              -- 帮助
              { "<leader>h", desc = " 打开帮助 [原生]" },
              { "<leader>?", desc = " 显示缓冲区局部快捷键 [Which-key插件]" },
         })
        end,
        -- 额外的快捷键定义
        keys = {
        {
            "<leader>?",
            function()
            require("which-key").show({ global = false })
            end,
            desc = "显示缓冲区局部快捷键",
        },
        },
    },
}
