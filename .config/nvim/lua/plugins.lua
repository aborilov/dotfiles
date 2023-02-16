local packer = nil

local function init()
  if packer == nil then
    packer = require 'packer'
    packer.init {
      disable_commands = true,
      display = {
        open_fn = function()
          local result, win, buf = require('packer.util').float {
            border = {
              { '╭', 'FloatBorder' },
              { '─', 'FloatBorder' },
              { '╮', 'FloatBorder' },
              { '│', 'FloatBorder' },
              { '╯', 'FloatBorder' },
              { '─', 'FloatBorder' },
              { '╰', 'FloatBorder' },
              { '│', 'FloatBorder' },
            },
          }
          vim.api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal')
          return result, win, buf
        end,
      },
    }
  end

  local use = packer.use
  packer.reset()

  -- Packer
  use 'wbthomason/packer.nvim' 

  use 'lewis6991/impatient.nvim'
  use 'fatih/vim-go'

  use 'nvim-tree/nvim-tree.lua'
  use "nvim-lua/plenary.nvim"
  use "jose-elias-alvarez/null-ls.nvim"
  use "tpope/vim-fugitive"

  use { 'alexghergh/nvim-tmux-navigation', config = function()
        require'nvim-tmux-navigation'.setup {
            disable_when_zoomed = true, -- defaults to false
            keybindings = {
                left = "<C-h>",
                down = "<C-j>",
                up = "<C-k>",
                right = "<C-l>",
                last_active = "<C-\\>",
            }
        }
    end
}

  use {
  'nvim-telescope/telescope.nvim', tag = '0.1.0',
  requires = { {'nvim-lua/plenary.nvim'} }
}

  -- use 'ishan9299/nvim-solarized-lua'
  use 'tjdevries/colorbuddy.nvim'
  use 'svrana/neosolarized.nvim'


  -- Commenting
  -- use 'tomtom/tcomment_vim'
  use 'numToStr/Comment.nvim'

  -- Wrapping/delimiters
  use 'machakann/vim-sandwich'

  -- Pretty symbols
  use 'kyazdani42/nvim-web-devicons'

  -- Completion and linting
  use {'neovim/nvim-lspconfig'}
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    init()
    return packer[key]
  end,
})

return plugins
