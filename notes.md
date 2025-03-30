---
id: nvim plugin from scratch - advent of nvim
aliases: []
tags:
  - nvim
---
# part 1
## setup
plugin must have a `lua` folder which holds all things that can be required

`plugin` dir holds all the files that get run on startup

To source the plugin with lazy you return a table with a `dir` field pointing to the plugin directory 

the other option for running code on startup is adding a `config` field into that table and making it a lua function
## writing the actual plugin
it returns a table called M

we parse the lines into a list of slides

then we create a floating window, draw the first slide on it

### todo
create keymaps to go forward, backward, quit, and mapping them to the buffer

readme with usage
# part 2 - managing floating windows
we made the window full screen size and took the border off

and we also have options that we store before opening the presentation and then reset on BufLeave with an autocommand, currently to remove/restore the command line

im back i got that dog in me

alright we have parsed the slides differently so they are in a class that has a title and a body

and then we created separate floating windows for the title and the body, so we can do stuff to the title we don't want done to the body

then set the filetypes of the buffers to markdown

then we centered the title, added a border

then we slightly indented the body text

then we made a background so that the indented body text didn't show the background

phew, done
## part 3 - plugins and autocommands
put the window config definition into its own function

autocommand to reload window sizes on vim resize

NOTE:
doesn't work when it gets too big
    if ur resizing idrc about you anyway tho
## part 4 - how to iterate
tip 1 - keeping a "global" state table 

created a function that takes in a function and applies it to all the buffers, that is quite nice
    try to make it hard to forget to do things

made a footer that displays slide number and title of the file
## part 5 - testing and CI
### tests with plenary
creating file and dir `~/programming/nvim-plugins/present.nvim/tests/parse_slides_spec.lua`, important that the file ends with spec

not going to write all of this down, just go to that file and follow the conventions

he explained how to use a .github/ dir to make (what i assume is a github action?) that runs the tests on push, I am not going to do that but could in the future - he copied most of the stuff from telescope

yeah it's a github action for CI, it runs the tests on each push or pull rquest.
## part 6 - custom commands and lazy loading
a few simple commands to show what plugin does

define these in the plugin/ dir

defined a command that lazy loads and starts the presentation
## part 7 - executing markdown code blocks live
we are parsing the slides differently so that they have a list of code blocks which have fields for the language of the block and the body

to execute those blocks, at least in lua, we are overwriting the print function to another function

`noaucommand = true` when creating a window to not close out of the other windows, thats usefule

but this is quote cool, only works for windows right now and only considers the first code block, but we could change that fairly easily
