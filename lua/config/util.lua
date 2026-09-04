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

---Should this buffer be reformatted on save? Buffer-local `autoformat` wins over
---the global one, so <leader>uF can exempt a single buffer from a global yes.
---
---Lives here because more than one thing keys off it: conform's format_on_save
---and the eslint fix-all pass in plugins/nextjs.lua, which has to make the same
---decision so <leader>uf turns off the whole on-save pipeline, not half of it.
---@param buf number
---@return boolean
function M.autoformat_enabled(buf)
	if vim.b[buf].autoformat ~= nil then
		return vim.b[buf].autoformat
	end
	return vim.g.autoformat ~= false
end

---Format the current buffer with conform (LSP as fallback).
---@param opts? conform.FormatOpts
function M.format(opts)
	require("conform").format(vim.tbl_extend("force", {
		lsp_format = "fallback",
		timeout_ms = 3000,
	}, opts or {}))
end

--------------------------------------------------------------------------------
-- Python
--------------------------------------------------------------------------------

---The interpreter a python project should be driven with: an activated venv
---wins, then a venv sitting in the project itself, then whatever python3 is on
---$PATH.
---
---Resolved at call time, never when a spec is loaded. venv-selector sets
---$VIRTUAL_ENV when a venv is picked, nvim-dap calls function values in a
---configuration just before starting a session, and neotest asks per run -- so
---all three see the current pick.
---@param root? string project directory to look for a venv in (default: cwd)
---@return string
function M.python_path(root)
	local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
	if venv and venv ~= "" then
		local exe = venv .. "/bin/python"
		if vim.uv.fs_stat(exe) then
			return exe
		end
	end
	for _, dir in ipairs({ ".venv", "venv", "env" }) do
		local exe = (root or vim.fn.getcwd()) .. "/" .. dir .. "/bin/python"
		if vim.uv.fs_stat(exe) then
			return exe
		end
	end
	local system = vim.fn.exepath("python3")
	return system ~= "" and system or "python"
end

--------------------------------------------------------------------------------
-- Debugging
--------------------------------------------------------------------------------

local dap_inputs = {} ---@type table<string, string>

---Ask for a value a DAP configuration needs, once per Neovim session.
---
---Remote debugging needs two things this config cannot guess: which port the
---debugger inside the container listens on, and where the source tree is
---mounted there. Both are stable for a given project and neither is stable
---across projects, so a plain `vim.fn.input` in the configuration would ask the
---same question before every single session. The answer is remembered instead,
---and `:DapRemoteReset` (plugins/dap.lua) forgets it.
---@param key string identifies the question, not the answer
---@param prompt string
---@param default string offered as editable text, and used for an empty answer
---@return string
function M.dap_input(key, prompt, default)
	if dap_inputs[key] == nil then
		local answer = vim.fn.input(prompt, default)
		dap_inputs[key] = answer ~= "" and answer or default
	end
	return dap_inputs[key]
end

---Forget every remembered answer.
function M.dap_input_reset()
	dap_inputs = {}
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
