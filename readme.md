diagnostic-jump.nvim
====================

open diagnostic popup of error nearest cursor unless popup is open, then
navigate diagnostics.

### example config

djump = require("diagnostic-jump")
```lua
djump.setup({
    format = function(diagnostic)
        return vim.split(diagnostic.message, "\n")[1]
    end,
    prefix = "",
    suffix = "",
    focusable = false,
    header = ""
})

-- navigate diagnostics
vim.keymap.set("n", "<c-k>", djump.prev)
vim.keymap.set("n", "<c-j>", djump.next)

-- navigate only errors
local opts = { severity = { min = vim.diagnostic.severity.ERROR } }
vim.keymap.set("n", "<leader><c-k>", function() djump.prev(opts, opts) end)
vim.keymap.set("n", "<leader><c-j>", function() djump.next(opts, opts) end)
```
