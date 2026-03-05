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

        -- ========== 自定义跨 buffer 高亮 ==========
        local ns_id = vim.api.nvim_create_namespace('illuminate_all_buffers')
        local current_word = nil

        -- 在所有 buffer 中高亮
        local function highlight_all_buffers()
        local word = vim.fn.expand('<cword>')
        if word == '' or word == current_word then return end

        current_word = word

        -- 清除所有 buffer 的高亮
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
            end
        end

        -- 在所有 buffer 中添加高亮
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

            for line_num, line in ipairs(lines) do
                local start_col = 1
                while true do
                local s, e = string.find(line, '%f[%w]' .. vim.pesc(word) .. '%f[%W]', start_col)
                if not s then break end

                vim.api.nvim_buf_add_highlight(
                    buf,
                    ns_id,
                    'IlluminatedWordText',
                    line_num - 1,
                    s - 1,
                    e
                )
                start_col = e + 1
                end
            end
            end
        end
        end

        -- 清除所有高亮
        local function clear_all_highlights()
        current_word = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
            end
        end
        end

        -- 快捷键
        vim.keymap.set('n', '<leader>sh', highlight_all_buffers, {
        desc = '高亮所有文件中的当前词',
        })

        vim.keymap.set('n', '<leader>sc', clear_all_highlights, {
        desc = '清除所有文件的高亮',
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
