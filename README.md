# present.nvim
following along with [advent of nvim by tj devries](https://www.youtube.com/playlist?list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM) to learn to build a neovim plugin
# usage
```lua
config = function()
    local present = require("present")
    present.setup()
end
```
## keybinds
### in presentation
`n` -> next slide
`p` -> previous slide
`q` -> quit
### normal mode
these are the defaults, change them by adding 
```lua
vim.keymap.set("n", "<leader>pp", ":PresentStart<CR>")
```
