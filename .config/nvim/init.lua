-- bootstrap lazy.nvim, LazyVim and your plugins
vim.env.PYTHONHOME = nil

require("config.lazy")
require("config.rez-pyright")
vim.lsp.enable('ruff')

--require("keymaps") -- Loads ~/.config/nvim/lua/keymaps.lua
