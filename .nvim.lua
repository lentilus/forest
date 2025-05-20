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
      (heading (text) @title)
    ]],
    select_regex = '^"(.*)"$',
    default_extension = ".typst",
    file_extensions = {".typst"},
  },
  on_attach = on_attach,
}

local function new_zettel()
    name = vim.fn.system({'increment'})
    vim.schedule(function() vim.cmd("e " .. name) end)
end

vim.keymap.set('n', '<leader>nn', new_zettel)

function insert_workspace_symbol_link()
  local ts_builtin    = require('telescope.builtin')
  local actions       = require('telescope.actions')
  local action_state  = require('telescope.actions.state')

  ts_builtin.lsp_workspace_symbols({
    prompt_title = "Workspace Symbols",
    attach_mappings = function(prompt_bufnr, map)
      -- override <CR>
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        local name = entry.symbol_name
        local path = entry.filename
        local id = vim.fn.fnamemodify(path, ':.')
        id = vim.fn.fnamemodify(id, ':r')

        local link = string.format("#local(\"%s\")[%s]", id, name)

        -- get cursor, then inject text
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_text(0, row-1, col, row-1, col, { link })
      end)
      return true
    end,
  })
end

vim.keymap.set(
  'n',
  '<leader>ln',
  insert_workspace_symbol_link,
  { noremap = true, silent = true, desc = 'Insert MD link to workspace symbol' }
)

vim.lsp.enable('zeta')
vim.cmd[[cd ./trees]]
vim.schedule(function() vim.cmd[[e index.typst]] end)

