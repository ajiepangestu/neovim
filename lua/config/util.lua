-- Small helpers that replace the parts of the LazyVim API this config used to
-- depend on: project root detection, formatting and treesitter feature checks.

local M = {}

--------------------------------------------------------------------------------
-- Root detection
--------------------------------------------------------------------------------

-- Tried in order. A string is a detector name, a table is a list of patterns.
M.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- LSP clients that should never decide the project root.
M.root_lsp_ignore = { "null-ls" }

local function realpath(path)
	if path == nil or path == "" then
		return nil
	end
	return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
end

local function bufpath(buf)
	local name = vim.api.nvim_buf_get_name(buf)
	return name ~= "" and realpath(name) or nil
end

local detectors = {}

function detectors.cwd()
	return { vim.uv.cwd() }
end

function detectors.lsp(buf)
	local path = bufpath(buf)
	if not path then
		return {}
	end

	local roots = {}
	for _, client in pairs(vim.lsp.get_clients({ bufnr = buf })) do
		if not vim.tbl_contains(M.root_lsp_ignore, client.name) then
			for _, ws in pairs(client.config.workspace_folders or {}) do
				roots[#roots + 1] = vim.uri_to_fname(ws.uri)
			end
			if client.root_dir then
				roots[#roots + 1] = client.root_dir
			end
		end
	end

	return vim.tbl_filter(function(root)
		return path:find(vim.fs.normalize(root), 1, true) == 1
	end, roots)
end

function detectors.pattern(buf, patterns)
	local path = bufpath(buf) or vim.uv.cwd()
	local match = vim.fs.find(patterns, { path = path, upward = true })[1]
	return match and { vim.fs.dirname(match) } or {}
end

---Detect the project root for a buffer, falling back to the cwd.
---@param opts? { buf?: number }
---@return string
function M.root(opts)
	opts = opts or {}
	local buf = opts.buf
	if buf == nil or buf == 0 then
		buf = vim.api.nvim_get_current_buf()
	end

	for _, spec in ipairs(M.root_spec) do
		local paths = type(spec) == "string" and detectors[spec](buf) or detectors.pattern(buf, spec)

		local roots = {}
		for _, path in ipairs(paths) do
			local resolved = realpath(path)
			if resolved and not vim.tbl_contains(roots, resolved) then
				roots[#roots + 1] = resolved
			end
		end

		-- deepest match wins
		table.sort(roots, function(a, b)
			return #a > #b
		end)

		if roots[1] then
			return roots[1]
		end
	end

	return realpath(vim.uv.cwd()) or vim.uv.cwd()
end

---Root of the enclosing git repository, or the project root as a fallback.
---@return string
function M.git_root()
	local buf = vim.api.nvim_get_current_buf()
	local dir = detectors.pattern(buf, { ".git" })[1]
	return dir and realpath(dir) or M.root()
end

--------------------------------------------------------------------------------
-- Formatting
--------------------------------------------------------------------------------

---Format the current buffer with conform (LSP as fallback).
---@param opts? conform.FormatOpts
function M.format(opts)
	require("conform").format(vim.tbl_extend("force", {
		lsp_format = "fallback",
		timeout_ms = 3000,
	}, opts or {}))
end

--------------------------------------------------------------------------------
-- Treesitter
--------------------------------------------------------------------------------

M.ts = {}

local installed = nil ---@type table<string, boolean>?
local queries = {} ---@type table<string, boolean>

---@param refresh? boolean
function M.ts.installed(refresh)
	if refresh or not installed then
		installed = {}
		local ok, ts = pcall(require, "nvim-treesitter")
		if ok and ts.get_installed then
			for _, lang in ipairs(ts.get_installed("parsers")) do
				installed[lang] = true
			end
		end
	end
	return installed
end

---Is there a parser (and optionally a query) for this filetype/buffer?
---@param what? string|number filetype or buffer, defaults to the current buffer
---@param query? string e.g. "highlights", "indents", "folds"
---@return boolean
function M.ts.have(what, query)
	what = what or vim.api.nvim_get_current_buf()
	what = type(what) == "number" and vim.bo[what].filetype or what
	local lang = vim.treesitter.language.get_lang(what)
	if lang == nil or M.ts.installed()[lang] == nil then
		return false
	end
	if query then
		local key = lang .. ":" .. query
		if queries[key] == nil then
			queries[key] = vim.treesitter.query.get(lang, query) ~= nil
		end
		return queries[key]
	end
	return true
end

--------------------------------------------------------------------------------
-- File explorer (snacks) — used by the buffer and terminal keymaps
--------------------------------------------------------------------------------

M.explorer = {}

---@return number? win
function M.explorer.find_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "snacks_explorer" then
			return win
		end
	end
end

---Open the explorer and focus it, reusing the window if it is already open.
function M.explorer.open()
	local win = M.explorer.find_win()
	if win then
		vim.api.nvim_set_current_win(win)
		return
	end

	require("snacks").explorer()
	vim.defer_fn(function()
		local opened = M.explorer.find_win()
		if opened then
			vim.api.nvim_set_current_win(opened)
		end
	end, 50)
end

function M.explorer.toggle()
	local win = M.explorer.find_win()
	if win then
		vim.api.nvim_win_close(win, true)
		return
	end
	M.explorer.open()
end

---Is this a real, listed file buffer?
---@param buf number
function M.explorer.is_file_buffer(buf)
	return vim.api.nvim_buf_is_valid(buf)
		and vim.api.nvim_buf_is_loaded(buf)
		and vim.bo[buf].buflisted
		and not vim.bo[buf].filetype:match("snacks_explorer")
end

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------

---Set a buffer/window-local option, but only when nothing else already set it
---(a ftplugin or another plugin keeps winning).
---@param option string
---@param value any
---@return boolean set
function M.set_default(option, value)
	local current = vim.api.nvim_get_option_value(option, { scope = "local" })
	local global = vim.api.nvim_get_option_value(option, { scope = "global" })
	if current ~= global and current ~= "" then
		return false
	end
	vim.api.nvim_set_option_value(option, value, { scope = "local" })
	return true
end

return M
