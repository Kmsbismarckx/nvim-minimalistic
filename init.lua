if vim.fn.has("persistent_undo") == 1 then
	local target_path = vim.fn.expand("~/.filter_nvim_minimal/undo")

	if vim.fn.isdirectory(target_path) == 0 then
		vim.fn.mkdir(target_path, "p")
	end

	vim.opt.undodir = target_path
	vim.opt.undofile = true
end

local o = vim.o

o.swapfile = false
o.relativenumber = true
o.number = true
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.autoindent = true
o.mouse = "a"
o.ignorecase = true
o.smartcase = true
o.cursorline = true
vim.opt.sessionoptions:append("tabpages")
o.termguicolors = true
o.background = "dark"
o.signcolumn = "yes"
o.backspace = "indent,eol,start"
vim.opt.clipboard:append("unnamedplus")
o.splitright = true
o.splitbelow = true
o.completeopt = "menuone,noselect"
o.laststatus = 2

function _G.MinimalGitBranch()
	local git_dir = vim.fs.find(".git", { path = vim.fn.expand("%:p:h"), upward = true, limit = 1 })[1]
	if not git_dir then
		return ""
	end
	local head = io.open(git_dir .. "/HEAD", "r")
	if not head then
		return ""
	end
	local content = head:read("*l")
	head:close()
	if not content then
		return ""
	end
	local branch = content:match("ref: refs/heads/(.+)$")
	return " " .. (branch or content:sub(1, 7)) -- detached HEAD -> short hash
end

o.statusline = "%f %m %r %{v:lua.MinimalGitBranch()} %=%l:%c %P"
o.winborder = "rounded"

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		-- Add a custom format function to show error codes
		format = function(diagnostic)
			local code = diagnostic.code and string.format("[%s]", diagnostic.code) or ""
			return string.format("%s %s", code, diagnostic.message)
		end,
	},
	underline = true,
	update_in_insert = true,
	float = {
		source = true, -- Or "if_many"
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	-- Make diagnostic background transparent
	on_ready = function()
		vim.cmd("highlight DiagnosticVirtualText guibg=NONE")
	end,
})

local map = vim.keymap.set

vim.g.mapleader = " "

map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

map("n", "<leader>xq", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end, { desc = "Diagnostics to quickfix" })

local function diag_jump_and_open_float(count)
	return function()
		vim.diagnostic.jump({
			count = count,
			on_jump = function()
				vim.diagnostic.open_float()
			end,
		})
	end
end

map("n", "]d", diag_jump_and_open_float(1), { desc = "Next Diagnostic" })
map("n", "[d", diag_jump_and_open_float(-1), { desc = "Prev Diagnostic" })

local function gh(user_repo)
	return "https://github.com/" .. user_repo
end

vim.pack.add({
	{ src = gh("folke/tokyonight.nvim") },
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	{ src = gh("neovim/nvim-lspconfig") },
	{ src = gh("echasnovski/mini.pairs") },
	{ src = gh("folke/snacks.nvim") },
	{ src = gh("folke/trouble.nvim") },
	{ src = gh("folke/todo-comments.nvim") },
	{ src = gh("nvim-lua/plenary.nvim") },
	{ src = gh("folke/noice.nvim") },
	{ src = gh("folke/which-key.nvim") },
	{ src = gh("MunifTanjim/nui.nvim") },
	{ src = gh("saghen/blink.cmp"),                version = vim.version.range("1") },
	{ src = gh("rafamadriz/friendly-snippets") },
	{ src = gh("sindrets/diffview.nvim") },
	{ src = gh("stevearc/conform.nvim") },
	{ src = gh("nvim-tree/nvim-web-devicons") },
	{ src = gh("stevearc/oil.nvim") },
	{ src = gh("lewis6991/gitsigns.nvim") },
})

require("tokyonight").setup({
	style = "night",
})
vim.cmd.colorscheme("tokyonight")

require("blink.cmp").setup({
	keymap = {
		preset = "none",

		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-x><C-o>"] = { "show", "show_documentation", "hide_documentation" },
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-e>"] = { "hide", "fallback" },
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		menu = {
			border = "rounded",
			draw = {
				columns = {
					{ "label",      "label_description", gap = 1 },
					{ "kind_icon",  "kind",              gap = 1 },
					{ "source_name" },
				},
			},
		},
		documentation = {
			auto_show = true,
			window = { border = "rounded" },
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
})

local ts = require("nvim-treesitter")

ts.install({
	"lua",
	"vim",
	"vimdoc",
	"markdown",
	"markdown_inline",
	"bash",
	"javascript",
	"typescript",
	"tsx",
	"kotlin",
	"regex",
})

vim.treesitter.language.register("bash", "zsh")

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("minimal-treesitter", { clear = true }),
	callback = function(args)
		local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
		if lang and pcall(vim.treesitter.start, args.buf, lang) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("minimal-lsp-attach", { clear = true }),
	callback = function(event)
		local lmap = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		local lsp = vim.lsp

		lmap("gd", function()
			Snacks.picker.lsp_definitions()
		end, "[G]oto [D]efinition")
		lmap("grr", function()
			Snacks.picker.lsp_references()
		end, "[G]oto [R]eferences")
		lmap("gri", function()
			Snacks.picker.lsp_implementations()
		end, "[G]oto [I]mplementation")
		lmap("grt", function()
			Snacks.picker.lsp_type_definitions()
		end, "[G]oto Type [D]efinition")
		lmap("<leader>ds", lsp.buf.document_symbol, "[D]ocument [S]ymbols")
		lmap("<leader>ws", lsp.buf.workspace_symbol, "[W]orkspace [S]ymbols")

		lmap("K", lsp.buf.hover, "Hover Documentation")
		lmap("<leader>rn", lsp.buf.rename, "[R]e[n]ame")
		lmap("<leader>ca", lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
		lmap("gD", function()
			Snacks.picker.lsp_declarations()
		end, "[G]oto [D]eclaration")
		lmap("<leader>f", function()
			lsp.buf.format({ async = true })
		end, "[F]ormat Buffer")

		local client = lsp.get_client_by_id(event.data.client_id)

		if client and client:supports_method(lsp.protocol.Methods.textDocument_documentHighlight) then
			local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = group,
				callback = lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = group,
				callback = lsp.buf.clear_references,
			})
		end

		if client and client:supports_method(lsp.protocol.Methods.textDocument_inlayHint) then
			lmap("<leader>th", function()
				lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})

vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = { command = "clippy" },
			inlayHints = { enable = true, showParameterNames = true },
		},
	},
})

vim.lsp.config("vtsls", {
	settings = {
		typescriptreact = {
			inlayHints = {
				parameterNames = { enabled = "all" },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
			},
		},
		typescript = {
			inlayHints = {
				parameterNames = { enabled = "all" },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
			},
		},
		javascriptreact = {
			inlayHints = {
				parameterNames = { enabled = "all" },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
			},
		},
		javascript = {
			inlayHints = {
				parameterNames = { enabled = "all" },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
			},
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			completion = { callSnippet = "Replace" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.list_extend(
					{ vim.env.VIMRUNTIME .. "/lua" },
					vim.tbl_map(function(p)
						return p.path .. "/lua"
					end, vim.pack.get())
				),
				checkThirdParty = false,
			},
		},
	},
})

vim.lsp.enable({
	"vtsls",
	"rust_analyzer",
	"lua_ls",
	"html",
	"cssls",
	"jsonls",
	"yamlls",
	"eslint",
	"kotlin_language_server",
})

require("snacks").setup({
	picker = {
		enabled = true,
		ui_select = true,
		formatters = {
			file = {
				filename_first = true,
			},
		},
		win = {
			input = {
				keys = {
					["<C-j>"] = { "list_down", mode = { "i", "n" } },
					["<C-k>"] = { "list_up", mode = { "i", "n" } },
				},
			},
		},
		sources = {
			files = {
				layout = { preset = "dropdown", preview = true },
			},
		},
	},
	input = { enabled = true },
	notifier = { enabled = true },
	indent = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
})

map("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find Files" })
map("n", "<leader>fg", function()
	Snacks.picker.grep()
end, { desc = "Live Grep" })
map("n", "<leader>fd", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader><space>", function()
	Snacks.picker.resume()
end, { desc = "Resume Last Picker" })
map("n", "<leader>fs", function()
	Snacks.picker.lsp_symbols()
end, { desc = "Document Symbols" })
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })

require("todo-comments").setup({})

require("trouble").setup({})

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo Comments (Trouble)" })

require("noice").setup({
	presets = {
		bottom_search = true,
		command_palette = true,
		lsp_doc_border = true,
	},
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
})

vim.o.timeoutlen = 500

require("which-key").setup({})
require("which-key").add({
	{ "<leader>x", group = "Trouble" },
})

require("mini.pairs").setup()

require("diffview").setup({
	enhanced_diff_hl = true,
	view = {
		merge_tool = {
			layout = "diff3_mixed",
		},
	},
	file_panel = {
		listing_style = "tree",
		tree_options = {
			flatten_dirs = true,
			folder_statuses = "only_folded",
		},
		win_config = {
			position = "left",
			width = 35,
		},
	},
})

map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open Git Diff / Conflicts" })
map("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Close Git Diff" })

require("conform").setup({
	formatters_by_ft = {
		typescript = { "eslint_d", "prettier" },
		typescriptreact = { "eslint_d", "prettier" },
		javascript = { "eslint_d", "prettier" },
		javascriptreact = { "eslint_d", "prettier" },
		lua = { "stylua" },
		rust = { "rustfmt", lsp_format = "fallback" },
		kotlin = { "ktlint" },
		["_"] = { "trim_whitespace" },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
	notify_on_error = true,
})

require("oil").setup({
	default_file_explorer = true,
	columns = {
		"icon",
	},
	skip_confirm_for_simple_edits = true,
	view_options = {
		show_hidden = true,
		is_hidden_file = function(name, _)
			return vim.startswith(name, "..")
		end,
	},
	keymaps = {
		["g?"] = "actions.show_help",
		["<C-p>"] = "actions.preview",
		["<C-c>"] = "actions.close",
		["-"] = "actions.parent",
	},
})

map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.api.nvim_create_autocmd("User", {
	pattern = "OilActionsPost",
	callback = function(event)
		local action = event.data.actions[1]
		if action and action.type == "move" then
			Snacks.rename.on_rename_file(action.src_url, action.dest_url)
		end
	end,
})

require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	-- Включаем "GitLens" эффект (автор строки в конце)
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 500,
		virt_text_pos = "eol",
	},
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Навигация: Прыгаем по изменениям (Hunks)
		map("n", "]h", gs.next_hunk, { desc = "Next Git Hunk" })
		map("n", "[h", gs.prev_hunk, { desc = "Prev Git Hunk" })

		-- Быстрые действия с куском кода прямо в файле
		map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
		map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })

		-- Детальный Blame (всплывающее окно с инфой о коммите)
		map("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, { desc = "Blame Line" })
	end,
})
