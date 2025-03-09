local present = require("present")

vim.keymap.set("n", "<leader>pp", function()
    present.start_presentation()
end)

