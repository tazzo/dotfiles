return {
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Neovim 0.10+ supporta OSC 52 nativamente per la copia.
      -- Configuriamo i registri "+" e "*" affinché usino solo la funzione di copia.
      local osc52 = require("vim.ui.clipboard.osc52")
      vim.g.clipboard = {
        name = "OSC 52",
        copy = {
          ["+"] = osc52.copy("+"),
          ["*"] = osc52.copy("*"),
        },
        paste = {
          -- Disabilitiamo il paste via OSC 52 per evitare errori "invalid data" o "Nothing in register".
          -- Incollerai usando Ctrl+Shift+V del terminale.
          ["+"] = function() return {} end,
          ["*"] = function() return {} end,
        },
      }
      
      -- Opzionale: non usare unnamedplus per evitare che 'p' cerchi di parlare con la clipboard dell'host
      -- vim.opt.clipboard = "" 
    end,
  },
}