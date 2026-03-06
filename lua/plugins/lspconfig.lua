-- ============================================
-- LSP 配置 (Neovim 0.11+ 原生方式)
-- ============================================

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- ========================================
        -- 诊断配置（包括符号）
        -- ========================================
        vim.diagnostic.config({
            -- 虚拟文本
            virtual_text = {
                prefix = "●",
                spacing = 4,
            },
            -- 符号配置（新方式）
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },
            },
            -- 其他配置
            update_in_insert = false,
            underline = true,
            severity_sort = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = true,
                header = "",
                prefix = "",
            },
        })

        -- 注意：vim.lsp.handlers API 已在 Neovim 0.11+ 中弃用
        -- 悬浮窗口边框现在通过 vim.lsp.config() 配置
        -- 旧的 handlers 配置已移除，使用新的配置方式

        -- ========================================
        -- LSP 附加时的回调（快捷键和高亮）
        -- ========================================
         vim.api.nvim_create_autocmd("LspAttach", {
             group = vim.api.nvim_create_augroup("UserLspConfig", {}),
             callback = function(args)
                 local client = vim.lsp.get_client_by_id(args.data.client_id)
                 local bufnr = args.buf
                 local opts = { noremap = true, silent = true, buffer = bufnr }

                 -- 跳转
                 vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "跳转到定义" }))
                 vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "跳转到声明" }))
                 vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "查看引用" }))
                 -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "跳转到实现" }))
                 -- vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "跳转到类型定义" }))

                 -- 悬浮信息
                 vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "显示悬浮文档" }))

                 -- 代码操作
                 vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "代码操作" }))
                 vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "重命名符号" }))
                 vim.keymap.set("n", "<leader>cf", function()
                     vim.lsp.buf.format({ async = true })
                 end, vim.tbl_extend("force", opts, { desc = "格式化代码" }))

                  -- 诊断
                 vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, vim.tbl_extend("force", opts, { desc = "上一个诊断" }))
                 vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, vim.tbl_extend("force", opts, { desc = "下一个诊断" }))
                 vim.keymap.set("n", "<leader>cdl", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "显示诊断详情" }))
                 vim.keymap.set("n", "<leader>cdq", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "诊断列表" }))

                  -- Inlay-Hints (仅映射一遍，不嵌套)
                  vim.keymap.set("n", "<leader>cih", function()
                      if vim.fn.has("nvim-0.11") == 1 then
                        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
                        vim.notify("inlay hints: " .. (not enabled and "ON" or "OFF"))
                      else
                        local enabled = vim.lsp.inlay_hint.is_enabled(bufnr)
                        vim.lsp.inlay_hint.enable(bufnr, not enabled)
                        vim.notify("inlay hints: " .. (not enabled and "ON" or "OFF"))
                      end
                  end, vim.tbl_extend("force", opts, { desc = "切换 inlay hints" }))

                 -- C/C++ 特定快捷键
                 if client and client.name == "clangd" then
                     -- 切换头文件/源文件的替代方案
                     vim.keymap.set("n", "<leader>ch", function()
                         local current_file = vim.api.nvim_buf_get_name(0)
                         local is_header = current_file:match("%.h$") or current_file:match("%.hpp$")
                         local pattern = is_header and "%.cpp$" or "%.h$"

                         -- 尝试在当前目录查找对应的文件
                         local dir = vim.fn.fnamemodify(current_file, ":h")
                         local files = vim.fn.glob(dir .. "/*" .. pattern, false, true)

                         if #files > 0 then
                             vim.cmd("edit " .. files[1])
                         else
                             vim.notify("未找到对应的源文件/头文件", vim.log.levels.WARN)
                         end
                     end, vim.tbl_extend("force", opts, { desc = "切换头文件/源文件" }))
                 end

                 -- 高亮当前符号（使用新的方法调用方式）
                 if client and client:supports_method("textDocument/documentHighlight") then
                     local highlight_augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
                     vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                         buffer = bufnr,
                         group = highlight_augroup,
                         callback = vim.lsp.buf.document_highlight,
                     })
                     vim.api.nvim_create_autocmd("CursorMoved", {
                         buffer = bufnr,
                         group = highlight_augroup,
                         callback = vim.lsp.buf.clear_references,
                     })
                 end
             end,
        })

        -- ========================================
        -- LSP 服务器能力配置（支持补全）
        -- ========================================
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- ========================================
        -- 使用新的 vim.lsp.config 配置各语言服务器
        -- ========================================

        -- 注意：在Neovim 0.11+中，全局配置可能不直接支持通配符 '*'
        -- 我们将为每个服务器单独配置 capabilities

         -- Lua
         vim.lsp.config('lua_ls', {
             cmd = { 'lua-language-server' },
             filetypes = { 'lua' },
             root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
             capabilities = capabilities,
             -- 悬浮窗口边框配置
             handlers = {
                 ["textDocument/hover"] = function(...)
                     return vim.lsp.handlers.hover(..., { border = "rounded" })
                 end,
                 ["textDocument/signatureHelp"] = function(...)
                     return vim.lsp.handlers.signature_help(..., { border = "rounded" })
                 end,
             },
              settings = {
                 Lua = {
                     diagnostics = {
                         globals = { 'vim' },
                     },
                     workspace = {
                         library = vim.api.nvim_get_runtime_file("", true),
                         checkThirdParty = false,
                     },
                     telemetry = {
                         enable = false,
                     },
                     format = {
                         enable = true,
                         defaultConfig = {
                             indent_style = "space",
                             indent_size = "4",
                         }
                     },
                 },
             },
        })

        -- C/C++
        vim.lsp.config('clangd', {
            cmd = {
                'clangd',
                '--background-index',
                '--clang-tidy',
                '--header-insertion=iwyu',
                '--completion-style=detailed',
                '--function-arg-placeholders',
                '--fallback-style=llvm',
                '--compile-commands-dir=build',
            },
            filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
            root_markers = {
                '.clangd',
                '.clang-tidy',
                '.clang-format',
                'compile_commands.json',
                'compile_flags.txt',
                'configure.ac',
                '.git',
            },
            capabilities = capabilities,
            handlers = {
                ["textDocument/hover"] = function(...)
                    return vim.lsp.handlers.hover(..., { border = "rounded" })
                end,
                ["textDocument/signatureHelp"] = function(...)
                    return vim.lsp.handlers.signature_help(..., { border = "rounded" })
                end,
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
        })

        -- Python
        vim.lsp.config('pyright', {
            cmd = { 'pyright-langserver', '--stdio' },
            filetypes = { 'python' },
            root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
            capabilities = capabilities,
             settings = {
                 python = {
                     analysis = {
                         typeCheckingMode = "basic",
                         autoSearchPaths = true,
                         useLibraryCodeForTypes = true,
                     },
                 },
             },
        })

        -- TypeScript/JavaScript
        vim.lsp.config('ts_ls', {
            cmd = { 'typescript-language-server', '--stdio' },
            filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
            root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
            capabilities = capabilities,
        })

        -- HTML
vim.lsp.config('html', {
                cmd = { 'vscode-html-language-server', '--stdio' },
                filetypes = { 'html' },
                root_markers = { 'package.json', '.git' },
                capabilities = capabilities,
        })

        -- CSS
vim.lsp.config('cssls', {
                cmd = { 'vscode-css-language-server', '--stdio' },
                filetypes = { 'css', 'scss', 'less' },
                root_markers = { 'package.json', '.git' },
                capabilities = capabilities,
        })

        -- JSON
vim.lsp.config('jsonls', {
                cmd = { 'vscode-json-language-server', '--stdio' },
                filetypes = { 'json', 'jsonc' },
                root_markers = { 'package.json', '.git' },
                capabilities = capabilities,
             settings = {
                 json = {
                     schemas = require("schemastore").json.schemas(),
                     validate = { enable = true },
                 },
             },
        })

         -- Rust (Rust-analyzer)
         vim.lsp.config('rust_analyzer', {
            cmd = { 'rust-analyzer' },
            filetypes = { 'rust', 'rs' },
            root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
            capabilities = capabilities,
             settings = {
                 ["rust-analyzer"] = {
                     -- 基础配置
                     checkOnSave = true,
                     cargo = {
                         checkOnSave = {
                             command = "clippy",
                             extraArgs = { "--", "-W", "clippy::pedantic" },
                         },
                     },
                     -- 内联提示
                     inlayHints = {
                         typeHints = { enable = true },
                         parameterHints = { enable = true },
                         chainingHints = { enable = true },
                         closingBraceHints = { enable = true },
                     },
                     -- 导入优化
                     imports = {
                         granularity = {
                             group = "module",
                         },
                         prefix = "self",
                     },
                     -- 诊断优化
                     diagnostics = {
                         disabled = { "unresolved-import" },
                     },
                     -- 缓存配置
                     cachePriming = {
                         enable = true,
                     },
                 },
             },
        })

        -- ========================================
        -- 启用所有配置的 LSP
        -- ========================================
        local servers = {
            'clangd', 'rust_analyzer', 'pyright',
            'lua_ls', 'ts_ls', 'html', 'cssls', 'jsonls'
        }
        for _, server in ipairs(servers) do
            vim.lsp.enable(server)
        end
        end,
    },
    {
        "b0o/schemastore.nvim",
        lazy = true,
    }
}

