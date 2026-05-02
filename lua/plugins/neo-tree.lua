---@diagnostic disable: undefined-global
-- ============================================
-- Neo-tree 文件树插件
-- ============================================

return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            -- 在 Neo-tree 加载前禁用 netrw
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            -- ========================================
            -- PWD 辅助函数
            -- ========================================
            -- 辅助函数：同时设置根目录并更改窗口 PWD
            local function set_root_with_cd(state)
                local node = state.tree:get_node()
                if not node then
                    print("无法获取节点")
                    return
                end

                local source = state.source or "filesystem"
                local target_path = node.path

                -- 如果节点是文件，使用父目录
                if node.type ~= "directory" then
                    target_path = vim.fn.fnamemodify(target_path, ":h")
                end

                -- 根据来源调用对应的 set_root 命令
                if source == "filesystem" then
                    require("neo-tree.sources.filesystem.commands").set_root(state)
                elseif source == "buffers" then
                    require("neo-tree.sources.buffers.commands").set_root(state)
                end

                -- 更改窗口 PWD
                vim.cmd("cd " .. vim.fn.fnameescape(target_path))
                print("已更改工作目录到: " .. target_path)
            end

            -- 辅助函数：仅更改窗口 PWD，不改变 Neotree 视图
            local function change_pwd_only(state)
                local node = state.tree:get_node()
                if not node then
                    print("无法获取节点")
                    return
                end

                local target_path = node.path

                -- 如果节点是文件，使用父目录
                if node.type ~= "directory" then
                    target_path = vim.fn.fnamemodify(target_path, ":h")
                end

                -- 仅更改窗口 PWD
                vim.cmd("cd " .. vim.fn.fnameescape(target_path))
                print("已更改工作目录到: " .. target_path .. " (不改变视图)")
            end

            -- 辅助函数：仅改变 Neotree 视图（根目录），不改变窗口 PWD
            local function change_root_only(state)
                local node = state.tree:get_node()
                if not node then
                    print("无法获取节点")
                    return
                end

                local source = state.source or "filesystem"
                local target_path = node.path

                -- 如果节点是文件，使用父目录
                if node.type ~= "directory" then
                    target_path = vim.fn.fnamemodify(target_path, ":h")
                end

                -- 根据来源调用对应的 set_root 命令
                if source == "filesystem" then
                    require("neo-tree.sources.filesystem.commands").set_root(state)
                elseif source == "buffers" then
                    require("neo-tree.sources.buffers.commands").set_root(state)
                end

                print("已更改视图根目录到: " .. target_path .. " (不改变工作目录)")
            end

            require("neo-tree").setup({
                close_if_last_window = false,
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,

                default_component_configs = {
                    indent = {
                        indent_size = 2,
                        padding = 1,
                        with_markers = true,
                        indent_marker = "│",
                        last_indent_marker = "└",
                        expander_collapsed = "",
                        expander_expanded = "",
                    },

                    default_component_configs = {
                        icon = {
                            folder_closed = "",
                            folder_open = "",
                            folder_empty = "󰜌",
                            folder_empty_open = "󱞞",

                            default = "*",
                            highlight = "NeoTreeFileIcon",
                            use_git_status_colors = true,
                        },
                    },

                    modified = {
                        symbol = "[+]",
                    },
                    name = {
                        trailing_slash = false,
                        use_git_status_colors = true,
                    },

                    git_status = {
                        symbols = {
                            -- 修改为更具现代感的图标
                            added     = "󰐕", -- 或者 "✚"
                            modified  = "󰏫", -- 或者 ""
                            deleted   = "󰍶", -- 或者 "✖"
                            renamed   = "󰁕", -- 保持原样或用 "󰑕"

                            -- 补全你原本为空的字段
                            untracked = "󰇘", -- 或者 ""
                            ignored   = "◌", -- 灰色小圆圈，表示被忽略
                            unstaged  = "󰄱", -- 未暂存的复选框
                            staged    = "󰱒", -- 已暂存的复选框
                            conflict  = "󰀦", -- 红色感叹号，提醒冲突
                        }
                    },
                },

                window = {
                    position = "left",
                    width = 30,
                    mapping_options = {
                        noremap = true,
                        nowait = true,
                    },
                    mappings = {
                        ["<space>"] = "toggle_node",
                        ["<2-LeftMouse>"] = "open",
                        ["<cr>"] = "open",
                        ["<esc>"] = "cancel",
                        ["o"] = "open",
                        ["O"] = function(state) -- Open a node recursively.
                            local node = state.tree:get_node()
                            if not node then return end
                            if node.type == "directory" then
                                local success, commands = pcall(require, "neo-tree.sources.filesystem.commands")
                                if success and commands.expand_all_nodes then
                                    commands.expand_all_nodes(state, node)
                                end
                            else
                                require("neo-tree.sources.common.commands").open(state, function() end)
                            end
                        end,
                        ["S"] = "open_split",
                        ["s"] = "open_vsplit",
                        ["t"] = "open_tabnew",
                        ["a"] = {
                            "add",
                            config = {
                                show_path = "relative"
                            }
                        },
                        ["A"] = "add_directory",
                        ["d"] = "delete",
                        ["r"] = "rename",
                        ["y"] = "copy_to_clipboard",
                        ["x"] = "cut_to_clipboard",
                        ["p"] = "paste_from_clipboard",
                        ["c"] = "copy",
                        ["m"] = "move",
                        ["<bs>"] = "navigate_up",
                        ["H"] = "toggle_hidden",
                        ["/"] = "fuzzy_finder",
                        ["f"] = "filter_on_submit",
                        ["<c-x>"] = "clear_filter",
                        ["R"] = "refresh",
                        ["?"] = {
                            "show_help",
                            desc = "显示快捷键帮助",
                            config = {
                                title = "Neo-tree 快捷键",
                                sorter = function(a, b) return a.key < b.key end
                            }
                        },
                        ["q"] = "close_window",
                        ["i"] = "show_file_details",
                        ["<"] = "prev_source",
                        [">"] = "next_source",
                    }
                },

                filesystem = {
                    filtered_items = {
                        visible = true,
                        hide_dotfiles = false,
                        hide_gitignored = false,
                        hide_by_name = {
                            "node_modules",
                            ".git",
                        },
                        hide_by_pattern = {},
                        never_show = {
                            ".DS_Store",
                            "thumbs.db",
                        },
                    },

                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = true,
                    },
                    use_libuv_file_watcher = true,
                    async_directory_scan = "always",

                    bind_to_cwd = false,
                    sync_root_with_cwd = true,

                        window = {
                        mappings = {
                            ["<bs>"]  = "navigate_up",
                            ["."]     = { set_root_with_cd, desc = "设为根目录并切换工作目录" },
                            [","]     = { change_root_only, desc = "仅改变视图根目录（不改变工作目录）" },
                            ["g."]    = { change_pwd_only, desc = "仅切换窗口工作目录（不改变视图）" },
                            ["H"]     = "toggle_hidden",
                            ["/"]     = "fuzzy_finder",
                            ["D"]     = "fuzzy_finder_directory",
                            ["f"]     = "filter_on_submit",
                            ["<c-x>"] = "clear_filter",
                            ["[g"]    = "prev_git_modified",
                            ["]g"]    = "next_git_modified",
                        },
                    },
                },

                buffers = {
                    follow_current_file = {
                        enabled = true,
                    },
                    window = {
                        mappings = {
                            ["bd"] = "buffer_delete",
                            ["<bs>"] = "navigate_up",
                            ["."] = { set_root_with_cd, desc = "设为根目录并切换工作目录" },
                            [","] = { change_root_only, desc = "仅改变视图根目录（不改变工作目录）" },
                            ["g."] = { change_pwd_only, desc = "仅切换窗口工作目录（不改变视图）" },
                        }
                    },
                },

                git_status = {
                    window = {
                        mappings = {
                            ["A"] = "git_add_all",
                            ["gu"] = "git_unstage_file",
                            ["ga"] = "git_add_file",
                            ["gr"] = "git_revert_file",
                            ["gc"] = "git_commit",
                            ["gp"] = "git_push",
                            ["gg"] = "git_commit_and_push",
                        }
                    }
                },

                -- ========================================
                -- 事件处理器
                -- ========================================
                event_handlers = {
                    {
                        event = "neo_tree_buffer_enter",
                        handler = function()
                            -- 当进入 Neo-tree 缓冲区时设置行号
                            vim.opt_local.number = true
                            vim.opt_local.relativenumber = true
                        end,
                    },
                    {
                        event = "neo_tree_window_after_open",
                        handler = function(args)
                            -- 当 Neo-tree 窗口打开后设置行号
                            if args.position == "left" or args.position == "right" then
                                vim.cmd("setlocal number relativenumber")
                            end
                        end,
                    },
                },
            })

            -- ========================================
            -- 自动命令：多重保险
            -- ========================================
            local neotree_group = vim.api.nvim_create_augroup("neotree_line_numbers", { clear = true })

            -- 方法1: FileType 触发
            vim.api.nvim_create_autocmd("FileType", {
                group = neotree_group,
                pattern = "neo-tree",
                callback = function()
                    vim.opt_local.number = true
                    vim.opt_local.relativenumber = true
                end,
            })

            -- 方法2: BufEnter 触发（进入缓冲区时）
            vim.api.nvim_create_autocmd("BufEnter", {
                group = neotree_group,
                pattern = "*",
                callback = function()
                    if vim.bo.filetype == "neo-tree" then
                        vim.opt_local.number = true
                        vim.opt_local.relativenumber = true
                    end
                end,
            })

            -- 方法3: WinEnter 触发（进入窗口时）
            vim.api.nvim_create_autocmd("WinEnter", {
                group = neotree_group,
                pattern = "*",
                callback = function()
                    if vim.bo.filetype == "neo-tree" then
                        vim.opt_local.number = true
                        vim.opt_local.relativenumber = true
                    end
                end,
            })

            -- 快捷键映射
            vim.keymap.set('n', '<leader>fe', ':Neotree toggle<CR>',
                { desc = '切换文件树', silent = true })

            vim.keymap.set('n', '<leader>fo', ':Neotree focus<CR>',
                { desc = '聚焦文件树', silent = true })

            -- vim.keymap.set('n', '<leader>fE', ':Neotree reveal<CR>',
            --     { desc = '在文件树中显示当前文件', silent = true })

            vim.keymap.set('n', '<leader>fE', function()
                -- 获取当前文件所在目录
                local dir = vim.fn.expand('%:p:h')
                -- 强制以该目录为根打开 Neotree 并定位文件
                vim.cmd('Neotree dir=' .. dir .. ' reveal')
            end, { desc = '强制聚焦当前文件夹（不改PWD）', silent = true })

            vim.keymap.set('n', '<leader>gs', ':Neotree float git_status<CR>',
                { desc = '显示 Git 状态', silent = true })
        end,
    },
}
