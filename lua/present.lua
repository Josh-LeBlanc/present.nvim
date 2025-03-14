local M = {}

---@class present.Slides
---@field slides string[]: the slides of the file

--- Takes some lines and parses them
---@param lines string[]: lines in the buffer
---@return present.Slides: slides class of lines
local parse_slides = function(lines)
    ---@type present.Slides
    local slides = { slides = {} }
    local current_slide = {}

    local seperator = "^#"

    for _, line in ipairs(lines) do
	if line:find(seperator) then
	    if #current_slide > 0 then
		table.insert(slides.slides, current_slide)
	    end

	    current_slide = {}
	end

	table.insert(current_slide, line)
    end

    table.insert(slides.slides, current_slide)

    return slides
end

local function open_floating_window(opts)
    opts = opts or {}

    -- Get current editor size
    local width = vim.o.columns
    local height = vim.o.lines

    -- Default size to 80% of screen if not provided
    local win_width = opts.width or width
    local win_height = opts.height or height

    -- Calculate center position
    local row = math.floor((height - win_height) / 2)
    local col = math.floor((width - win_width) / 2)

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Window options
    local win_opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = { " ", " ", " ", " ", " ", " ", " ", " ", }
    }

    -- Open the floating window
    local win = vim.api.nvim_open_win(buf, true, win_opts)

    return { buf = buf, win = win }
end

M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    local parsed = parse_slides(lines)
    local float = open_floating_window()
    local current_slide = 1

    vim.keymap.set("n", "n", function()
	current_slide = math.min(current_slide + 1, #parsed.slides)
	vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
    end,
    {
	buffer = float.buf
    })

    vim.keymap.set("n", "p", function()
	current_slide = math.max(current_slide - 1, 1)
	vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
    end,
    {
	buffer = float.buf
    })

    vim.keymap.set("n", "q", function()
	vim.api.nvim_win_close(float.win, true)
    end,
    {
	buffer = float.buf
    })

    local restore = {
	cmdheight = {
	    original = vim.o.cmdheight,
	    present = 0
	}
    }

    -- set options for presentation
    for option, config in pairs(restore) do
	vim.opt[option] = config.present
    end

    -- reset values when we are done with presentation
    vim.api.nvim_create_autocmd("BufLeave", {
	buffer = float.buf,
	callback = function()
	    -- reset options after presentation end
	    for option, config in pairs(restore) do
		vim.opt[option] = config.original
	    end
	end
    })
    vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
end

M.setup = function()

    local present = require("present")

    vim.keymap.set("n", "<leader>pp", function()
	present.start_presentation()
    end)

end

return M
