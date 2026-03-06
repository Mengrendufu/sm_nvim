---@diagnostic disable: undefined-global
return {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
        providers = {
        'lsp',
        'treesitter',
        'regex',
        },
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = {
        providers = { 'lsp' },
        },
        filetypes_denylist = {
        'dirvish',
        'fugitive',
        'alpha',
        'NvimTree',
        'neo-tree',
        'lazy',
        'TelescopePrompt',
        },
        under_cursor = true,
        min_count_to_highlight = 1,
    },
    config = function(_, opts)
        require('illuminate').configure(opts)

        -- ========== 多组跨 buffer 高亮 ==========
        -- 最多同时 pin 6 个词，每组独立颜色，支持 toggle（再次 pin 同一词则取消）

        -- 6 种高亮组，依次轮换
        local HL_GROUPS = {
            'MultiHL1', 'MultiHL2', 'MultiHL3',
            'MultiHL4', 'MultiHL5', 'MultiHL6',
        }
        -- 对应颜色（bg 仅在 guibg 生效；termguicolors 需开启）
        local HL_COLORS = {
            { bg = '#804040', fg = '#ffcccc' }, -- 红
            { bg = '#405880', fg = '#cce0ff' }, -- 蓝
            { bg = '#407840', fg = '#ccffcc' }, -- 绿
            { bg = '#806840', fg = '#ffe8cc' }, -- 橙
            { bg = '#604080', fg = '#e8ccff' }, -- 紫
            { bg = '#407878', fg = '#ccffff' }, -- 青
        }

        -- 初始化高亮组
        for i, g in ipairs(HL_GROUPS) do
            local c = HL_COLORS[i]
            vim.api.nvim_set_hl(0, g, { bg = c.bg, fg = c.fg, bold = true })
        end

        -- 状态表：{ word -> { ns_id, group_index } }
        local pinned = {}
        -- 轮换指针（指向下一个要使用的 group）
        local next_group = 1

        -- 在所有已加载 buffer 中高亮一个词
        local function apply_word(word, ns_id, group)
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                    for lnum, line in ipairs(lines) do
                        local col = 1
                        while true do
                            local s, e = string.find(line, '%f[%w_]' .. vim.pesc(word) .. '%f[%W_]', col)
                            if not s then break end
                            vim.api.nvim_buf_add_highlight(buf, ns_id, group, lnum - 1, s - 1, e)
                            col = e + 1
                        end
                    end
                end
            end
        end

        -- 清除某个词的高亮
        local function clear_word(word)
            local entry = pinned[word]
            if not entry then return end
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    vim.api.nvim_buf_clear_namespace(buf, entry.ns_id, 0, -1)
                end
            end
            pinned[word] = nil
            vim.notify('取消高亮: ' .. word, vim.log.levels.INFO)
        end

        -- toggle pin 当前词
        local function toggle_pin()
            local word = vim.fn.expand('<cword>')
            if word == '' then return end

            -- 已 pin → toggle off
            if pinned[word] then
                clear_word(word)
                return
            end

            -- 选取下一个 group（跳过已被占用的，但最多 6 个）
            local used = {}
            for _, entry in pairs(pinned) do
                used[entry.group_index] = true
            end
            -- 找到第一个未被使用的 group
            local gi = nil
            for offset = 0, #HL_GROUPS - 1 do
                local idx = ((next_group - 1 + offset) % #HL_GROUPS) + 1
                if not used[idx] then
                    gi = idx
                    break
                end
            end
            if not gi then
                vim.notify('多组高亮已满（最多 6 组），请先用 <leader>sc 清除', vim.log.levels.WARN)
                return
            end
            next_group = (gi % #HL_GROUPS) + 1

            local ns_id = vim.api.nvim_create_namespace('multi_hl_' .. word)
            pinned[word] = { ns_id = ns_id, group_index = gi }
            apply_word(word, ns_id, HL_GROUPS[gi])
            vim.notify('Pin 高亮: ' .. word .. ' [组' .. gi .. ']', vim.log.levels.INFO)
        end

        -- 清除所有 pin
        local function clear_all()
            for word, entry in pairs(pinned) do
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) then
                        vim.api.nvim_buf_clear_namespace(buf, entry.ns_id, 0, -1)
                    end
                end
                pinned[word] = nil
            end
            next_group = 1
            vim.notify('已清除所有多组高亮', vim.log.levels.INFO)
        end

        -- 快捷键
        vim.keymap.set('n', '<leader>sh', toggle_pin, {
            desc = 'Pin/取消高亮当前词（跨所有 buffer，多组）',
        })
        vim.keymap.set('n', '<leader>sc', clear_all, {
            desc = '清除所有 Pin 高亮',
        })

        -- 设置快捷键
        local function map(key, dir, buffer)
        vim.keymap.set('n', key, function()
            require('illuminate')['goto_' .. dir .. '_reference'](false)
        end, {
            desc = dir:sub(1, 1):upper() .. dir:sub(2) .. ' Reference',
            buffer = buffer,
        })
        end

        map(']]', 'next')
        map('[[', 'prev')

        -- LSP 快捷键
        vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
            local buffer = args.buf
            map(']]', 'next', buffer)
            map('[[', 'prev', buffer)
        end,
        })
    end,
    keys = {
        { ']]', desc = '下一个引用' },
        { '[[', desc = '上一个引用' },
    },
}
