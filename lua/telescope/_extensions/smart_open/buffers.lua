local function get_buffer_list()
  local result = {}

  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.loop.fs_stat(vim.api.nvim_buf_get_name(buf)) then
      result[vim.api.nvim_buf_get_name(buf)] = {
        bufnr = buf,
        is_modified = vim.api.nvim_buf_get_option(buf, "modified"),
      }
    end
  end

  return result
end

return get_buffer_list
