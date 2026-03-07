-- ============================================
-- nvim-cmp - 自动补全引擎
-- ============================================

return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
        -- 补全源
        "hrsh7th/cmp-nvim-lsp",     -- LSP 补全源
        "hrsh7th/cmp-buffer",       -- 缓冲区补全源
        "hrsh7th/cmp-path",         -- 路径补全源
        "hrsh7th/cmp-cmdline",      -- 命令行补全源

        -- 代码片段引擎
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip", -- LuaSnip 补全源

        -- 友好的代码片段集合
        "rafamadriz/friendly-snippets",

        -- 图标支持
        "onsails/lspkind.nvim",
        },
        config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        -- 加载 friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Private snippets ..................................................
        require("config.sm_snippets")
        require("luasnip.loaders.from_vscode").lazy_load({
            paths = { vim.fn.stdpath("config") .. "/snippets" }
        })

        -- 让 .json 文件也使用 jsonc 的 snippets
        require("luasnip").filetype_extend("json", { "jsonc" })

        cmp.setup({
            -- 代码片段引擎
            snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
            },

            -- 窗口样式
            window = {
            completion = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
            }),
            documentation = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
            }),
            },

            -- 补全项格式化
            formatting = {
            format = lspkind.cmp_format({
                mode = "symbol_text",  -- 显示图标和文本
                maxwidth = 50,
                ellipsis_char = "...",
                before = function(entry, vim_item)
                -- 显示来源
                vim_item.menu = ({
                    nvim_lsp = "[LSP]",
                    luasnip = "[Snip]",
                    buffer = "[Buf]",
                    path = "[Path]",
                })[entry.source.name]
                return vim_item
                end,
            }),
            },

            -- 补全源
            sources = cmp.config.sources({
            { name = "nvim_lsp", priority = 1000 },
            { name = "luasnip", priority = 750 },
            { name = "buffer", priority = 500 },
            { name = "path", priority = 250 },
            }),

            -- 映射
            mapping = cmp.mapping.preset.insert({
            -- 上下选择
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),

            -- 滚动文档
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),

            -- 触发补全
            ["<C-Space>"] = cmp.mapping.complete(),

            -- 取消补全
            ["<C-e>"] = cmp.mapping.abort(),

            -- 确认选择
            ["<CR>"] = cmp.mapping.confirm({ select = false }), -- 只确认显式选择的项

            -- Tab 键行为
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    -- cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
                -- 保留原先行为：不自动高亮。用户可用手动映射触发高亮选择。
                else
                fallback()
                end
            end, { "i", "s" }),

            -- Shift-Tab 键行为
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    -- cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
                else
                fallback()
                end
            end, { "i", "s" }),
            }),

            -- 实验性功能
            experimental = {
                ghost_text = true, -- 显示虚影文本预览
            },
        })

        -- 命令行模式补全
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
            { name = "path" },
            { name = "cmdline" },
            }),
        })

        -- 搜索模式补全
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
            { name = "buffer" },
            },
        })

        -- 为手动高亮选择提供一个默认映射：在插入/普通模式按 <C-l>
        pcall(function()
            vim.keymap.set({'i','n'}, '<C-l>', function()
                local ok, sel = pcall(require, 'config.sm_snippets')
                if ok and sel and sel.manual_select then
                    sel.manual_select()
                end
            end, {silent = true, desc = 'LuaSnip: manual visual select of ampersand name'})
        end)

        end,
    },
}
