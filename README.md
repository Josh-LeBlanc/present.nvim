# present.nvim
this plugin turns a markdown file into a presentation in nvim
# usage
put this in your nvim config, you can set up your own executors for executing code blocks
```lua
config = function()
    local present = require("present")
    present.setup({
        executors = {
            python = "python",
            javascript = "node",
            -- add in the style of
            -- <markdown-code-block-label> = <command to run code>
        }
    })
end
```
## keybinds
### in presentation
`n` -> next slide
`p` -> previous slide
`q` -> quit
`x` -> execute lua codeblock in slide
### normal mode
default start presentation keybind
```lua
vim.keymap.set("n", "<leader>pp", ":PresentStart<CR>")
```
# resources
following along with [advent of nvim by tj devries](https://www.youtube.com/playlist?list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM) to learn to build a neovim plugin
