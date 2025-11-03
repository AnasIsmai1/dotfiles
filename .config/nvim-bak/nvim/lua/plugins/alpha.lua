-- return {
--   "goolord/alpha-nvim",
--   dependencies = {
--     "nvim-tree/nvim-web-devicons",
--   },
--
--   config = function()
--     local alpha = require("alpha")
--     local dashboard = require("alpha.themes.startify")
--
--     alpha.setup(dashboard.opts)
--   end,
-- }
return {
	"goolord/alpha-nvim",
    enabled=false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	hide = {
		stausline = true,
	},

	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header
		-- dashboard.section.header.val = {
		-- "                                                     ",
		-- "                                                     ",
		--   "                                                     ",
		--   "                                                     ",
		--   "                                                     ",
		--   "                                                     ",
		--   "                                                     ",
		--   "                                                     ",
		--   "                                                     ",
		--   "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
		--   "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
		--   "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
		--   "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
		--   "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
		--   "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
		--   "                                                     ",
		--   "                      [ @anas ]                        ",
		-- }

		dashboard.section.header.val = {
			-- [[                                                                       ]],
			-- [[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                     ]],
			[[       ████ ██████           █████      ██                     ]],
			[[      ███████████             █████                             ]],
			[[      █████████ ███████████████████ ███   ███████████   ]],
			[[     █████████  ███    █████████████ █████ ██████████████   ]],
			[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
			[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
			[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
			[[                                                                       ]],
			[[                                                                       ]],
			[[                                                                       ]],
		}

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("n", "  > New file", ":ene <BAR> startinsert <CR>"),
			-- dashboard.button("f", "  > Find file", ":cd $HOME/Workspace | Telescope find_files<CR>"),
			dashboard.button("f", "󰈞  > Find file", ":Telescope find_files<CR>"),
			dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
			-- split cmd opens oil in a horizontal split
			-- dashboard.button("s", "  > Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
			-- wincmd k moves cursor to the window below, the command takes any vim arrow key and moves cursor accordingly
			-- pwd gives current path
			dashboard.button("s", "  > Settings", ":e $MYVIMRC | :cd %:p:h | pwd<CR>"),
			-- dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
			-- dashboard.button("l", "󰒲 > Lazy", "<cmd>Lazy<cr>"),
			dashboard.button("u", "󰒲  > Update plugins", "<cmd>Lazy update<cr>"),
			-- dashboard.button("m", "󱧕 > Mason", "<cmd>Mason<cr>"),
			dashboard.button("R", "󰦛  > Restore Session", "<cmd>SessionRestore<cr>"),
			dashboard.button("q", "󰈆  > Quit NVIM", ":qa<CR>"),
		}

		-- local stats = require("lazy").stats()
		--
		-- local function footer()
		--   local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
		--   return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
		-- end
		--
		local function footer()
			local time = os.date("%H")
			if time >= "01" and time < "06" then
				return "\nLate Night grinds 💤"
			elseif time >= "06" and time < "11" then
				return "\nRise and shine sleepy head ☕"
			elseif time >= "11" and time < "24" then
				return "\nThere's no time like the present 📚📈"
			else
				return "\nThere's no time like the present 📚📈"
			end
		end

		-- local timer = require("timer")
		-- dashboard.section.footer.val = timer.setTimeout(200, footer())
		--

		dashboard.section.footer.val = footer()
		-- Set footer
		--   NOTE: This is currently a feature in my fork of alpha-nvim (opened PR #21, will update snippet if added to main)
		--   To see test this yourself, add the function as a dependecy in packer and uncomment the footer lines
		--   ```init.lua
		--   return require('packer').startup(function()
		--       use 'wbthomason/packer.nvim'
		--       use {
		--           'goolord/alpha-nvim', branch = 'feature/startify-fortune',
		--           requires = {'BlakeJC94/alpha-nvim-fortune'},
		--           config = function() require("config.alpha") end
		--       }
		--   end)
		--   ```
		--  local fortune = require("alpha.fortune")
		--  dashboard.section.footer.val = fortune()
		--  Send config to alpha
		--
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[
      autocmd FileType alpha setlocal nofoldenable
    ]])
	end,
}
