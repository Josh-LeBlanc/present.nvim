local M = {}

---@class present.Slides
---@field slides present.Slide[]: the slides of the file

---@class present.Slide
---@field title string
---@field body string[]

--- Takes some lines and parses them
---@param lines string[]: lines in the buffer
---@return present.Slides: slides class of lines
local parse_slides = function(lines)
    ---@type present.Slides
    local slides = { slides = {} }
    local current_slide = {
	title = "",
	body = {}
    }

    local seperator = "^#"

    for _, line in ipairs(lines) do
	if line:find(seperator) then
	    if #current_slide.title > 0 then
		table.insert(slides.slides, current_slide)
	    end

	    current_slide = {
		title = line,
		body = {}
	    }
	else
	    table.insert(current_slide.body, line)
	end
    end

    table.insert(slides.slides, current_slide)

    return slides
end

local function open_floating_window(config)
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Open the floating window
    local win = vim.api.nvim_open_win(buf, true, config)

    return { buf = buf, win = win }
end

M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    local parsed = parse_slides(lines)

    local width = vim.o.columns
    local height = vim.o.lines
    ---@type vim.api.keyset.win_config[]
    local windows = {
	background = {
	    relative = "editor",
	    width = width,
	    height = height,
	    style = "minimal",
	    col = 0,
	    row = 0,
	    zindex = 1,
	},
	header = {
	    relative = "editor",
	    width = width,
	    height = 1,
	    style = "minimal",
	    border = "rounded",
	    col = 0,
	    row = 0,
	    zindex = 2,
	},
	body = {
	    relative = "editor",
	    width = width - 8,
	    height = height - 5,
	    style = "minimal",
	    border = { " ", " ", " ", " ", " ", " ", " ", " ", },
	    row = 4,
	    col = 8,
	},
	-- footer = {}
    }

    local background_float = open_floating_window(windows.background)
    local header_float = open_floating_window(windows.header)
    local body_float = open_floating_window(windows.body)

    vim.bo[header_float.buf].filetype = "markdown"
    vim.bo[body_float.buf].filetype = "markdown"

    local set_slide_content = function(idx)
	local slide = parsed.slides[idx]

	local padding = string.rep(" ", (width - #slide.title) / 2)
	local title = padding .. slide.title

	vim.api.nvim_buf_set_lines(header_float.buf, 0, -1, false, { title })
	vim.api.nvim_buf_set_lines(body_float.buf, 0, -1, false, slide.body)
    end

    local current_slide = 1
    vim.keymap.set("n", "n", function()
	current_slide = math.min(current_slide + 1, #parsed.slides)
	set_slide_content(current_slide)
    end,
    {
	buffer = body_float.buf
    })

    vim.keymap.set("n", "p", function()
	current_slide = math.max(current_slide - 1, 1)
	set_slide_content(current_slide)
    end,
    {
	buffer = body_float.buf
    })

    vim.keymap.set("n", "q", function()
	vim.api.nvim_win_close(body_float.win, true)
    end,
    {
	buffer = body_float.buf
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
	buffer = body_float.buf,
	callback = function()
	    -- reset options after presentation end
	    for option, config in pairs(restore) do
		vim.opt[option] = config.original
	    end

	    pcall(vim.api.nvim_win_close, header_float.win, true)
	    pcall(vim.api.nvim_win_close, background_float.win, true)
	end
    })
    set_slide_content(current_slide)
end

M.setup = function()

    local present = require("present")

    vim.keymap.set("n", "<leader>pp", function()
	present.start_presentation()
    end)

end

return M
