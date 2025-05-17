vim.filetype.add {
  extension = {
    typst = 'typst',
  },
}

-- zeta --
local on_attach = function(client, bufnr)
  print('LSP attached to buffer', bufnr)

  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  vim.api.nvim_buf_create_user_command(bufnr, 'ZetaGraph', function()
    client.request('workspace/executeCommand', { command = 'graph', arguments = {} }, function(err, result)
      if err then
        vim.notify('Error executing graph command: ' .. err.message, vim.log.levels.ERROR)
      else
        vim.notify('Graph command executed.')
      end
    end, bufnr)
  end, { desc = "Execute Zeta LSP 'graph' command" })
end

vim.lsp.config['zeta'] = {
  -- Command and arguments to start the server.
  cmd = { 'zeta', '--logfile=/tmp/zeta.log' },
  filetypes = { 'typst' },
  root_markers = { 'index.typst' },
  init_options = {
    query = [[
      (call item: (ident) @include (#eq? @include "link") (group (string) @target))
      (call item: (ident) @embed (#eq? @embed "embed") (group (string) @target) )
      (call item: (ident) @local (#eq? @local "local") (group (string) @target) )
    ]],
    select_regex = '^"(.*)"$',
    default_extension = ".typst",
    file_extensions = {".typst"},
  },
  on_attach = on_attach,
}

vim.lsp.enable('zeta')
