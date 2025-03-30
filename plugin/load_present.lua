-- require("present").setup({})

vim.api.nvim_create_user_command("PresentStart", function()
    -- "lazy loaded" - only loads the plugin when this function is called
    require("present").start_presentation()
end, {})
