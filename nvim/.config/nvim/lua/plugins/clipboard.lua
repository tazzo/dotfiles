return {
  {
    "LazyVim/LazyVim",
    opts = function()
      -- 1. NON usiamo 'unnamedplus' nel container per evitare conflitti di registro
      vim.opt.clipboard = ""

      -- 2. Usiamo un comando automatico: ogni volta che fai 'y' (yank), 
      -- inviamo il testo anche al terminale via OSC 52.
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          -- Se il terminale supporta OSC 52, questo manderà il testo al tuo PC
          if vim.v.event.operator == "y" then
            local osc52 = require("vim.ui.clipboard.osc52")
            osc52.copy("+")(vim.fn.getreg(vim.v.event.regname, 1, true))
          end
        end,
      })
    end,
  },
}
