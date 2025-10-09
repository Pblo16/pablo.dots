return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({ style = "darker" })
      require("onedark").load()
    end,
  },
  {
    "vague2k/vague.nvim",
    config = function()
      require("vague").setup({ transparent = true })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = nil, -- no sobrescribir
    },
  },
}
