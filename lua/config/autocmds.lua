local closing = false

vim.api.nvim_create_autocmd({ "BufDelete", "WinClosed" }, {
  callback = function()
    if closing then return end
    vim.schedule(function()
      if closing then return end
      
      local has_real_buffer = false
      local explorer_win = nil

      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(w)
        local f = vim.bo[b].filetype
        local bt = vim.bo[b].buftype
        
        if f == "snacks_explorer" or f == "neo-tree" then
          explorer_win = w
        elseif bt == "" then
          local name = vim.api.nvim_buf_get_name(b)
          if name ~= "" then
            has_real_buffer = true
          end
        end
      end

      if not has_real_buffer and explorer_win then
        closing = true
        vim.api.nvim_set_current_win(explorer_win)
        vim.cmd("only")
        vim.defer_fn(function()
          closing = false
        end, 100)
      end
    end)
  end,
})
