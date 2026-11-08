-- markview
-- markview-smart-tables

vim.pack.add({
    "https://github.com/OXY2DEV/markview.nvim",
    "https://github.com/gunasekar/markview-smart-tables.nvim",
})

require("markview-smart-tables").setup({ wrap_width = 0.9 })  -- 90% of window

require("markview").setup({
    renderers = {
        markdown_table = function(buffer, item)
            require("markview-smart-tables").render(buffer, item)
        end,
    },
})
