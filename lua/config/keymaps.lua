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

local function get_explorer_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(w)
    if vim.bo[buf].filetype == "snacks_explorer" then
      return w
    end
  end
  return nil
end

local function has_real_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      local name = vim.api.nvim_buf_get_name(buf)
      if ft ~= "snacks_explorer" and name ~= "" then
        return true
      end
    end
  end
  return false
end

vim.keymap.set("n", "<leader>d", function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype

  if ft == "snacks_explorer" then
    return
  end

  if vim.api.nvim_win_get_config(win).relative ~= "" then
    vim.api.nvim_win_close(win, true)
    return
  end

  vim.cmd("bdelete!")

  vim.defer_fn(function()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(b) then
        local name = vim.api.nvim_buf_get_name(b)
        local bft = vim.bo[b].filetype
        if bft ~= "snacks_explorer" and name == "" then
          vim.cmd("silent! bdelete!")
        end
      end
    end

    if not has_real_buffers() then
      local explorer_win = get_explorer_win()
      if explorer_win then
        vim.api.nvim_set_current_win(explorer_win)
        vim.cmd("only")
      end
    end
  end, 50)
end, { desc = "Close current buffer" })

vim.keymap.set("n", "<leader>q", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ft = vim.bo[buf].filetype
      if ft ~= "snacks_explorer" then
        vim.cmd("silent! bdelete!")
      end
    end
  end

  vim.defer_fn(function()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(b) then
        local name = vim.api.nvim_buf_get_name(b)
        local bft = vim.bo[b].filetype
        if bft ~= "snacks_explorer" and name == "" then
          vim.cmd("silent! bdelete!")
        end
      end
    end

    local explorer_win = get_explorer_win()
    if not explorer_win then
      require("snacks").explorer()
      vim.defer_fn(function()
        explorer_win = get_explorer_win()
        if explorer_win then
          vim.api.nvim_set_current_win(explorer_win)
          vim.cmd("only")
        end
      end, 100)
    else
      vim.api.nvim_set_current_win(explorer_win)
      vim.cmd("only")
    end
  end, 50)
end, { desc = "Close all buffers, focus explorer" })
