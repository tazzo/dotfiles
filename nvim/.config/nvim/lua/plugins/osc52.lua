return {
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Abilita il supporto per OSC 52 (Clipboard via SSH/Container)
      local osc52 = require("vim.ui.clipboard.osc52")
      
      vim.g.clipboard = {
        name = "OSC 52",
        copy = {
          ["+"] = osc52.copy,
          ["*"] = osc52.copy,
        },
        paste = {
          ["+"] = osc52.paste,
          ["*"] = osc52.paste,
        },
      }
      
      -- Usa la clipboard di sistema (via OSC 52) come default
      vim.opt.clipboard = "unnamedplus"
    end,
  },
}
