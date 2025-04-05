# present.nvim
this plugin turns a markdown file into a presentation in nvim
# features
- each markdown heading becomes the title of a presentation slide
- you can execute code in markdown codeblocks, you must specify the executors in the config as shown below
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
`n` -> next slide<br>
`p` -> previous slide<br>
`q` -> quit<br>
`x` -> execute lua codeblock in slide
### normal mode
default start presentation keybind
```lua
vim.keymap.set("n", "<leader>pp", ":PresentStart<CR>")
```
# resources
following along with [advent of nvim by tj devries](https://www.youtube.com/playlist?list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM) to learn to build a neovim plugin
