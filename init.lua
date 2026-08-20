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
o.completeopt = "menuone,noselect,popup,fuzzy"
o.pumheight = 10
o.pumborder = "rounded"
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
		current_line = false,
		source = "if_many",
		format = function(diagnostic)
			local code = diagnostic.code and string.format("[%s]", diagnostic.code) or ""
			return string.format("%s %s", code, diagnostic.message)
		end,
	},
	virtual_lines = {
		current_line = true,
	},
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = { source = true, border = "rounded" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
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
	{ src = gh("echasnovski/mini.pick") },
	{ src = gh("echasnovski/mini.pairs") },
	{ src = gh("sindrets/diffview.nvim") },
	{ src = gh("stevearc/conform.nvim") },
	{ src = gh("nvim-tree/nvim-web-devicons") },
	{ src = gh("stevearc/oil.nvim") },
})

require("tokyonight").setup({
	style = "night",
})
vim.cmd.colorscheme("tokyonight")

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

local lsp_kind_icons = {
	"  Text",
	"  Method",
	"  Function",
	"  Constructor",
	"  Field",
	"  Variable",
	"  Class",
	"  Interface",
	"  Module",
	"  Property",
	"  Unit",
	"  Value",
	"  Enum",
	"  Keyword",
	"  Snippet",
	"  Color",
	"  File",
	"  Reference",
	"  Folder",
	"  EnumMember",
	"  Constant",
	"  Struct",
	"  Event",
	"  Operator",
	"  TypeParameter",
}

local function lsp_completion_convert(item)
	return { kind = lsp_kind_icons[item.kind] or item.kind }
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("minimal-lsp-attach", { clear = true }),
	callback = function(event)
		local lmap = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		local lsp = vim.lsp

		lmap("gd", lsp.buf.definition, "[G]oto [D]efinition")
		lmap("gr", lsp.buf.references, "[G]oto [R]eferences")
		lmap("gI", lsp.buf.implementation, "[G]oto [I]mplementation")
		lmap("<leader>D", lsp.buf.type_definition, "Type [D]efinition")
		lmap("<leader>ds", lsp.buf.document_symbol, "[D]ocument [S]ymbols")
		lmap("<leader>ws", lsp.buf.workspace_symbol, "[W]orkspace [S]ymbols")

		lmap("K", lsp.buf.hover, "Hover Documentation")
		lmap("<leader>rn", lsp.buf.rename, "[R]e[n]ame")
		lmap("<leader>ca", lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
		lmap("gD", lsp.buf.declaration, "[G]oto [D]eclaration")
		lmap("<leader>f", function()
			lsp.buf.format({ async = true })
		end, "[F]ormat Buffer")

		local client = lsp.get_client_by_id(event.data.client_id)

		if client and client:supports_method(lsp.protocol.Methods.textDocument_completion) then
			lsp.completion.enable(true, client.id, event.buf, {
				autotrigger = true,
				convert = lsp_completion_convert,
			})
			lmap("<C-x><C-o>", lsp.completion.get, "Trigger Completion", "i")
		end

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
		typescript = {
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

require("mini.pick").setup({
	options = {
		content_from_bottom = true, -- list grows bottom-up, like fzf/telescope
		use_cache = true, -- cache matches across repeated prompts
	},
	window = {
		config = function()
			local height = math.floor(0.7 * vim.o.lines)
			local width = math.floor(0.7 * vim.o.columns)
			return {
				anchor = "NW",
				height = height,
				width = width,
				row = math.floor((vim.o.lines - height) / 2),
				col = math.floor((vim.o.columns - width) / 2),
			}
		end,
	},
})

map("n", "<leader>ff", function()
	MiniPick.builtin.files()
end, { desc = "Find Files" })
map("n", "<leader>fg", function()
	MiniPick.builtin.grep_live()
end, { desc = "Live Grep" })
map("n", "<leader>fd", function()
	MiniPick.builtin.buffers()
end, { desc = "Buffers" })
map("n", "<leader><space>", function()
	MiniPick.builtin.resume()
end, { desc = "Resume Last Picker" })

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
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
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
