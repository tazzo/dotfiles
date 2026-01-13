return {
  {
    "LazyVim/LazyVim",
    init = function()
      -- Neovim 0.10+ ha il supporto nativo per OSC 52.
      -- Lo configuriamo manualmente per evitare i conflitti con i provider esterni.
      vim.g.clipboard = {
        name = "OSC 52",
        copy = {
          ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
          ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
          -- Il paste via OSC 52 è spesso bloccato dai terminali.
          -- Restituiamo una tabella vuota per evitare l'errore "invalid data".
          ["+"] = function() return {} end,
          ["*"] = function() return {} end,
        },
      }
    end,
  },
}
