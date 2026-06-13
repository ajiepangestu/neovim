vim.api.nvim_create_autocmd({ "BufDelete", "WinClosed" }, {
  callback = function()
    vim.schedule(function()
      local has_editor = false
      local explorer_win = nil

      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local b = vim.api.nvim_win_get_buf(w)
        local f = vim.bo[b].filetype
        if f ~= "snacks_explorer" and f ~= "neo-tree" then
          has_editor = true
        elseif f == "snacks_explorer" or f == "neo-tree" then
          explorer_win = w
        end
      end

      if not has_editor then
        if not explorer_win then
          require("snacks").explorer()
          vim.wait(100, function() end)
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
      end
    end)
  end,
})
