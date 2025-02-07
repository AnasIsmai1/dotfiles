return {
  "gbprod/substitute.nvim",
  enabled = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local substitute = require("substitute")

    substitute.setup()

    local keymap = vim.keymap

    keymap.set('n', 's', substitute.operator, { desc = 'Substitute with motion' })
    keymap.set('n', 'ss', substitute.line, { desc = 'Substitute Line' })
    keymap.set('n', 'S', substitute.eol, { desc = 'Substitute with end of line' })
    keymap.set('x', 's', substitute.visual, { desc = 'Substitute with visual mode' })
  end

}
