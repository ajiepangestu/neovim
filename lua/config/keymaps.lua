vim.keymap.set("n", "<leader>pl", ":Lazy<CR>", { desc = "Lazy" })

vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Window right" })

vim.keymap.set("n", "<leader>e", function()
  local snacks = require("snacks")
  
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "snacks_explorer" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  
  snacks.explorer()
end, { desc = "Toggle explorer" })

vim.keymap.set("n", ",,", "<Cmd>normal! ;<CR>", { desc = "Repeat f/t forward" })

vim.keymap.set("n", "<leader>d", function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local is_float = vim.api.nvim_win_get_config(win).relative ~= ""

  if is_float then
    vim.api.nvim_win_close(win, true)
    return
  end

  local ft = vim.bo[buf].filetype
  if ft == "snacks_explorer" or ft == "neo-tree" then
    vim.cmd("close")
    return
  end

  local buftype = vim.bo[buf].buftype
  if buftype == "quickfix" or buftype == "help" then
    vim.cmd("close")
    return
  end

  local editor_count = 0
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    local f = vim.bo[b].filetype
    if f ~= "snacks_explorer" and f ~= "neo-tree" then
      editor_count = editor_count + 1
    end
  end

  if editor_count <= 1 then
    vim.cmd("bdelete")
    vim.schedule(function()
      local explorer_win = nil
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(w)
        local f = vim.bo[b].filetype
        if f == "snacks_explorer" or f == "neo-tree" then
          explorer_win = w
          break
        end
      end

      if not explorer_win then
        require("snacks").explorer()
        vim.wait(100)
        for _, w in ipairs(vim.api.nvim_list_wins()) do
          local b = vim.api.nvim_win_get_buf(w)
          local f = vim.bo[b].filetype
          if f == "snacks_explorer" or f == "neo-tree" then
            explorer_win = w
            break
          end
        end
      end

      if explorer_win and vim.api.nvim_win_is_valid(explorer_win) then
        vim.api.nvim_set_current_win(explorer_win)
        vim.cmd("only")
      end
    end)
  else
    vim.cmd("bdelete")
  end
end, { desc = "Close current focus" })

vim.keymap.set("n", "<leader>q", function()
  local explorer_win = nil

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "snacks_explorer" or ft == "neo-tree" then
      explorer_win = win
      break
    end
  end

  if not explorer_win then
    require("snacks").explorer()
    vim.wait(200)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft == "snacks_explorer" or ft == "neo-tree" then
        explorer_win = win
        break
      end
    end
  end

  if explorer_win and vim.api.nvim_win_is_valid(explorer_win) then
    vim.api.nvim_set_current_win(explorer_win)
    vim.cmd("only")
  end
end, { desc = "Close all except explorer" })
