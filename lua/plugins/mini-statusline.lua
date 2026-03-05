---@diagnostic disable: undefined-global
return {
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function()
        -- 状态栏
        local statusline = require("mini.statusline")
        statusline.setup({
            use_icons = vim.g.have_nerd_font or true,
            set_vim_settings = true,
        })

        -- 自定义位置显示
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
            return "%2l:%-2v"
        end

        -- 文本对象增强
        require("mini.ai").setup({ n_lines = 500 })

        -- 包围符号操作
        require("mini.surround").setup()
        end,
    },
}
