local config = require("aerial.config")

local M = {}

---@param client table
---@return boolean
M.client_supports_symbols = function(client)
  return client.server_capabilities.documentSymbolProvider
    and config.lsp.priority[client.name] ~= -1
end

return M
