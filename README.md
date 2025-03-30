# present.nvim
this plugin turns a markdown file into a presentation in nvim
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
`x` -> execute lua codeblock in slide 
### normal mode
these are the defaults, change them by adding 
```lua
vim.keymap.set("n", "<leader>pp", ":PresentStart<CR>")
```
# resources
following along with [advent of nvim by tj devries](https://www.youtube.com/playlist?list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM) to learn to build a neovim plugin
