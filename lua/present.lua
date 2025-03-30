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

local function open_floating_window(config, enter)
    enter = enter or false
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Open the floating window
    local win = vim.api.nvim_open_win(buf, enter, config)

    return { buf = buf, win = win }
end

local window_configurations = function()
    local width = vim.o.columns
    local height = vim.o.lines

    local header_height = 1 + 2 -- 1 + border
    local footer_height = 1 -- no border
    local body_height = height - header_height - footer_height - 2 - 1


    return {
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
	    width = width - 16,
	    height = body_height,
	    style = "minimal",
	    border = { " ", " ", " ", " ", " ", " ", " ", " ", },
	    row = 4,
	    col = 8,
	},
	footer = {
	    relative = "editor",
	    width = width,
	    height = 1,
	    style = "minimal",
	    -- border = "rounded",
	    col = 0,
	    row = height - 1,
	    zindex = 2,
	}
    }
end

local state = {
    parsed = {},
    current_slide = 1,
    float = {},
}

local foreach_float = function(cb)
    for name, float in pairs(state.float) do
	cb(name, float)
    end
end

local present_keymap = function(mode, key, callback)
    vim.keymap.set(mode, key, callback, {
	buffer = state.float.body.buf
    })
end

M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    state.parsed = parse_slides(lines)
    state.current_slide = 1
    state.title = vim.fn.expand("%:t")

    local win_configs = window_configurations()

    state.float.background = open_floating_window(win_configs.background)
    state.float.header = open_floating_window(win_configs.header)
    state.float.footer = open_floating_window(win_configs.footer)
    state.float.body = open_floating_window(win_configs.body, true)

    foreach_float(function(_, float)
	vim.bo[float.buf].filetype = "markdown"
    end)

    local set_slide_content = function(idx)
	local slide = state.parsed.slides[idx]
	local width = vim.o.columns

	local padding = string.rep(" ", (width - #slide.title) / 2)
	local title = padding .. slide.title

	vim.api.nvim_buf_set_lines(state.float.header.buf, 0, -1, false, { title })
	vim.api.nvim_buf_set_lines(state.float.body.buf, 0, -1, false, slide.body)
	local footer = string.format("  %d / %d | %s", state.current_slide, #state.parsed.slides, state.title)
	vim.api.nvim_buf_set_lines(state.float.footer.buf, 0, -1, false, {footer})
    end

    present_keymap("n", "n", function()
	state.current_slide = math.min(state.current_slide + 1, #state.parsed.slides)
	set_slide_content(state.current_slide)
    end)

    present_keymap("n", "p", function()
	state.current_slide = math.max(state.current_slide - 1, 1)
	set_slide_content(state.current_slide)
    end)

    present_keymap("n", "q", function()
	vim.api.nvim_win_close(state.float.body.win, true)
    end)

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
	buffer = state.float.body.buf,
	callback = function()
	    -- reset options after presentation end
	    for option, config in pairs(restore) do
		vim.opt[option] = config.original
	    end

	    foreach_float(function(_, float)
		pcall(vim.api.nvim_win_close, float.win, true)
	    end)
	end
    })

    vim.api.nvim_create_autocmd("VimResized", {
	group = vim.api.nvim_create_augroup("present-resized", {}),
	callback = function()
	    if not vim.api.nvim_win_is_valid(state.float.body.win) or state.float.body.win == nil then
		return
	    end

	    local updated = window_configurations()
	    foreach_float(function(name, float)
		vim.api.nvim_win_set_config(float.win, updated[name])
	    end)
	    vim.api.nvim_win_set_config(state.float.header.win, updated.header)
	    vim.api.nvim_win_set_config(state.float.body.win, updated.body)
	    vim.api.nvim_win_set_config(state.float.background.win, state.float.background.body)
	    set_slide_content(state.current_slide)
	end
    })

    set_slide_content(state.current_slide)
end

M.setup = function()
    vim.keymap.set("n", "<leader>pp", ":PresentStart<CR>")
end

M._parse_slides = parse_slides

return M
