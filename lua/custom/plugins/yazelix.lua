if vim.fn.executable 'yzx' == 1 then
  vim.keymap.set('n', '<M-r>', function()
    local buffer_path = vim.fn.expand '%:p'
    if buffer_path == '' then return end

    vim.system({ 'yzx', 'reveal', buffer_path }, { text = true }, function(result)
      if result.code == 0 then return end

      vim.schedule(function()
        local msg = vim.trim(result.stderr or result.stdout or 'unknown error')
        vim.notify('yzx reveal failed: ' .. msg, vim.log.levels.WARN)
      end)
    end)
  end, { desc = 'Reveal in Yazelix Yazi sidebar' })
end
