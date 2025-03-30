---@diagnostic disable: undefined-field
local parse = require"present"._parse_slides

local eq = assert.are.same

describe("present.parse_slides", function()
    it("should parse an empty file", function()
	eq({
	    slides = {
		{
		    title = '',
		    body = {},
		    blocks = {},
		}
	    }
	},
	parse {})
    end)

    it("should parse a file with one slide", function()
	eq({
	    slides = {
		{
		    title = '# first slide',
		    body = {
			"body"
		    },
		    blocks = {},
		}
	    }
	},
	parse {
	    "# first slide",
	    "body",
	})
    end)

    it("should parse a file with one slide and a code block", function()

	local result = parse {
	    "# first slide",
	    "body",
	    "```python",
	    "print('hello world')",
	    "```",
	}

	eq(1, #result.slides)

	local slide = result.slides[1]
	eq("# first slide", slide.title)
	eq( {
	    "body",
	    "```python",
	    "print('hello world')",
	    "```",
	}, slide.body)

	local blocks = {
	    {
		language = "python",
		body = "print('hello world')"
	    }
	}
	eq(blocks, slide.blocks)

    end)
end)
