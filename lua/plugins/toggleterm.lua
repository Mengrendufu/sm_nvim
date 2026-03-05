-- lua/plugins/toggleterm.lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    size = 20,
    open_mapping = [[<c-\>]],
    shell = vim.fn.has("win32") == 1
      and (vim.loop.os_getenv("NEOVIM_TERM_NAME") or "pwsh")
      or vim.o.shell,
    shellcmdflag = vim.fn.has("win32") == 1
      and "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
      or nil,
    shellredir = vim.fn.has("win32") == 1 and "" or nil,
    shellpipe = vim.fn.has("win32") == 1 and "" or nil,
    shellquote = vim.fn.has("win32") == 1 and "" or nil,
    shellxquote = vim.fn.has("win32") == 1 and "" or nil,
    hide_numbers = true,
    shade_terminals = true,
    direction = 'float',
    float_opts = {
      border = 'curved',
    },
    start_in_insert = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

     -- 👇 以下完全保留你原有的自定义终端快捷键配置
    function _G.set_terminal_keymaps()
      local opt = {buffer = 0}
      -- 1. 恢复一键退出终端模式（最符合直觉的 Vim 操作）
      vim.keymap.set('t', [[<C-\><C-\>]], [[<C-\><C-n>]], opt)
    end

    -- 优雅发送粘贴文本到终端
    function _G.send_paste_to_term(term_id)
      term_id = term_id or 1

      -- 获取当前可视选择的文本，如果没有选择则使用复制寄存器内容
      local text = ""
      local mode = vim.fn.mode()

      if mode == "v" or mode == "V" or mode == "\x16" then
        -- 保存当前选择到寄存器 't'（临时寄存器，避免覆盖常用寄存器）
        vim.cmd('normal! "ty')
        text = vim.fn.getreg('t')
      else
        -- 使用最近复制的内容（寄存器 0）
        text = vim.fn.getreg('0')
        if text == "" then
          -- 如果寄存器0为空，尝试无名寄存器
          text = vim.fn.getreg('"')
        end
      end

      if text == "" then
        vim.notify("没有可发送的文本", vim.log.levels.WARN)
        return
      end

      -- 处理换行符：根据 shell 类型智能处理
      local shell = vim.o.shell:lower()
      if string.find(shell, "powershell") then
        -- PowerShell 中使用反引号续行符
        text = text:gsub("\r\n", "\n"):gsub("\r", "\n")  -- 标准化为 \n
        -- 只在非空行且不是最后一行时添加续行符
        local lines = vim.split(text, "\n")
        for i, line in ipairs(lines) do
          if i < #lines and line ~= "" then
            lines[i] = line .. " `"
          end
        end
        text = table.concat(lines, "\n")
      elseif string.find(shell, "cmd") then
        -- CMD 中使用 ^ 作为续行符
        text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
        local lines = vim.split(text, "\n")
        for i, line in ipairs(lines) do
          if i < #lines and line ~= "" then
            lines[i] = line .. " ^"
          end
        end
        text = table.concat(lines, "\n")
      else
        -- Unix shell 中使用 \ 作为续行符
        text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
        local lines = vim.split(text, "\n")
        for i, line in ipairs(lines) do
          if i < #lines and line ~= "" then
            lines[i] = line .. " \\"
          end
        end
        text = table.concat(lines, "\n")
      end

       -- 发送到终端
      require("toggleterm").exec(text, term_id)
      vim.notify("已发送文本到终端 " .. term_id, vim.log.levels.INFO)
    end

    -- 发送可视行（保留换行符，作为单个命令发送）
    function _G.send_visual_lines_to_term(term_id)
      term_id = term_id or 1
      require("toggleterm").send_lines_to_terminal("visual_lines", false, { args = term_id })
    end

    -- 发送可视选择（精确选择，保留换行符）
    function _G.send_visual_selection_to_term(term_id)
      term_id = term_id or 1
      require("toggleterm").send_lines_to_terminal("visual_selection", false, { args = term_id })
    end

    -- 发送当前行（保留缩进）
    function _G.send_current_line_to_term(term_id)
      term_id = term_id or 1
      require("toggleterm").send_lines_to_terminal("single_line", false, { args = term_id })
    end

     -- 当终端打开时自动应用这些快捷键
    vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function()
            vim.notify("终端已打开，使用 shell: " .. vim.o.shell, vim.log.levels.INFO)
            _G.set_terminal_keymaps()
        end
    })

    -- 发送粘贴文本的快捷键映射
    vim.keymap.set("n", "<leader>tsp", "<cmd>lua _G.send_paste_to_term(1)<CR>", { desc = "发送粘贴文本到终端1" })
    vim.keymap.set("v", "<leader>tsp", "<cmd>lua _G.send_paste_to_term(1)<CR>", { desc = "发送选中文本到终端1" })
    vim.keymap.set("n", "<leader>ts2p", "<cmd>lua _G.send_paste_to_term(2)<CR>", { desc = "发送粘贴文本到终端2" })
    vim.keymap.set("v", "<leader>ts2p", "<cmd>lua _G.send_paste_to_term(2)<CR>", { desc = "发送选中文本到终端2" })

    -- 发送选择文本的快捷键映射（使用 toggleterm 内置函数，保留换行符）
    vim.keymap.set("v", "<leader>tsl", "<cmd>lua _G.send_visual_lines_to_term(1)<CR>", { desc = "发送可视行到终端1" })
    vim.keymap.set("v", "<leader>tss", "<cmd>lua _G.send_visual_selection_to_term(1)<CR>", { desc = "发送精确选择到终端1" })
    vim.keymap.set("n", "<leader>tsl", "<cmd>lua _G.send_current_line_to_term(1)<CR>", { desc = "发送当前行到终端1" })
    vim.keymap.set("n", "<leader>ts2l", "<cmd>lua _G.send_current_line_to_term(2)<CR>", { desc = "发送当前行到终端2" })
  end
}
