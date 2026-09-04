local Util = require("config.util")

--------------------------------------------------------------------------------
-- mypy
--
-- basedpyright already type-checks, but it cannot read django-stubs: the Django
-- plugin that turns `models.CharField()` into `str` on the instance is a *mypy*
-- plugin, and only mypy loads it. `:DjangoInstall` (lua/config/django.lua) has
-- always offered django-stubs[compatible-mypy] and nothing ever ran it.
--
-- Both gates below have to pass before mypy runs at all, because an ungated
-- mypy is worse than no mypy: it is slow, and in a project that has not adopted
-- it every unannotated function turns into a wall of diagnostics.
--------------------------------------------------------------------------------

---mypy from the project venv, or from the one venv-selector activated. NOT from
---mason or $PATH: a mypy outside the venv has no django-stubs, so it would fail
---on the very `plugins = ["mypy_django_plugin.main"]` line that makes it worth
---running, and fail on every save.
---@param root string
---@return string?
local function venv_mypy(root)
	local venv = vim.env.VIRTUAL_ENV
	if venv and venv ~= "" and vim.uv.fs_stat(venv .. "/bin/mypy") then
		return venv .. "/bin/mypy"
	end
	for _, dir in ipairs({ ".venv", "venv", "env" }) do
		local exe = root .. "/" .. dir .. "/bin/mypy"
		if vim.uv.fs_stat(exe) then
			return exe
		end
	end
end

local mypy_config_cache = {} ---@type table<string, string|false>

---The project's mypy configuration, in the order mypy itself looks for one.
---Passed explicitly with --config-file rather than left to discovery, because
---nvim-lint runs the linter in Neovim's cwd, which in a monorepo is not the
---directory holding the config.
---@param root string
---@return string?
local function mypy_config(root)
	if mypy_config_cache[root] == nil then
		mypy_config_cache[root] = false
		for file, section in pairs({
			["mypy.ini"] = false,
			[".mypy.ini"] = false,
			["pyproject.toml"] = "[tool.mypy]",
			["setup.cfg"] = "[mypy]",
		}) do
			local path = root .. "/" .. file
			if vim.uv.fs_stat(path) then
				-- pyproject.toml and setup.cfg exist in nearly every python
				-- project; only their mypy section means mypy is wanted here.
				if not section or table.concat(vim.fn.readfile(path), "\n"):find(section, 1, true) then
					mypy_config_cache[root] = path
					break
				end
			end
		end
	end
	return mypy_config_cache[root] or nil
end

---Forget the cache, for when a config is added to a project mid-session.
vim.api.nvim_create_user_command("MypyRescan", function()
	mypy_config_cache = {}
	vim.notify("mypy config cache cleared", vim.log.levels.INFO)
end, { desc = "Re-detect the project's mypy configuration" })

return {
	-- Django tooling: djlint formatter and djls LSP
	{
		"mason-org/mason.nvim",
		-- `opts_extend` has to be repeated on every fragment that adds to the
		-- list, not just on the one that owns the plugin. lazy merges fragments
		-- in file order and reads `opts_extend` from the fragment being merged
		-- (or an EARLIER one); the owning spec here is alphabetically last, so at
		-- this point in the chain it is not visible yet and a plain table would
		-- REPLACE everything the files before it contributed instead of adding
		-- to it. Silently: nothing errors, the packages simply never install.
		opts_extend = { "ensure_installed" },
		opts = { ensure_installed = { "djlint", "basedpyright", "django-language-server" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- Tag and attribute completion in Django templates. djls handles the
				-- `{% %}` / `{{ }}` side, not the surrounding markup.
				html = { filetypes_extra = { htmldjango = true } },

				-- djls also claims plain `html`, so pin it to real Django projects.
				-- Without this it attaches to any html file (e.g. Go templates).
				djls = {
					workspace_required = true,
					root_dir = function(bufnr, on_dir)
						local root = vim.fs.root(bufnr, { "manage.py" })
						if root then
							on_dir(root)
						end
					end,
				},
				-- ruff resolves its own config per file, but without a root it starts
				-- in single-file mode, so `ruff.toml` / `[tool.ruff]` settings sitting
				-- beside manage.py are only picked up once this is set. Declared here
				-- rather than in a `setup` hook: plugins/lsp.lua already defines one
				-- for ruff, and a second would silently replace it.
				ruff = { root_markers_extra = { ["manage.py"] = true } },
				basedpyright = {
					-- Point the server at the project's interpreter. Without this it
					-- analyses with the python that started Neovim, and every symbol
					-- from an installed package resolves to nothing: `models.CharField`
					-- hovers as "Unknown" and goto-definition returns no result unless
					-- Neovim happens to have been launched from an activated shell.
					-- Picking a venv later with :VenvSelect updates the running client,
					-- so this only has to get startup right.
					before_init = function(_, config)
						config.settings.python.pythonPath = Util.python_path(config.root_dir)
					end,
					-- A Django project is not guaranteed to have any of the markers
					-- basedpyright ships with (pyproject.toml, setup.py,
					-- requirements.txt, .git); manage.py is the one file it always has.
					-- Without a root the server runs in single-file mode, where `grr`
					-- only ever finds references inside the current buffer.
					--
					-- It matters when those markers DO exist, too: in a monorepo the
					-- .git at the top would otherwise make the whole repo the python
					-- root, while manage.py picks out the Django app directory.
					root_markers_extra = { ["manage.py"] = true },
					settings = {
						python = {},
						basedpyright = {
							analysis = {
								typeCheckingMode = "basic",
								diagnosticMode = "openFilesOnly",
								autoImportCompletions = true,
							},
						},
					},
				},
			},
		},
	},
	-- Format Django templates with djlint
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.htmldjango = { "djlint" }

			opts.formatters = opts.formatters or {}
			opts.formatters.djlint = vim.tbl_extend("force", opts.formatters.djlint or {}, {
				prepend_args = { "--profile", "django" },
			})
		end,
	},
	-- htmldjango / python / toml parsers already come from plugins/treesitter.lua,
	-- and htmldjango is a default filetype of emmet_language_server.

	-- Debugging with debugpy. mason-nvim-dap's default handler registers the
	-- `python` adapter and a plain "Launch file" configuration; the extras below
	-- are the Django-specific ones, plus a launch config whose interpreter
	-- follows the venv picked by venv-selector instead of whatever $VIRTUAL_ENV
	-- happened to be at startup.
	{
		"jay-babu/mason-nvim-dap.nvim",
		optional = true,
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "python" })
		end,
	},
	{
		"mfussenegger/nvim-dap",
		optional = true,
		-- nvim-dap takes no opts of its own; lazy still runs this before the
		-- plugin's own config(), which is all this needs.
		opts = function()
			local dap = require("dap")

			-- A separate adapter for the remote case, for the same reason as
			-- `delve-remote` in plugins/go.lua: mason-nvim-dap owns
			-- `dap.adapters.python` and registers it asynchronously once debugpy
			-- finishes installing, so replacing it here would race.
			--
			-- It has to be a plain socket connection, NOT the executable adapter
			-- mason registers. `python -m debugpy --listen` already runs debugpy's
			-- own adapter inside the container and speaks DAP on that port, so
			-- there is nothing left for a second adapter to do. Sending the usual
			-- `attach` + `connect = { host, port }` through a locally spawned
			-- debugpy-adapter *looks* right and hangs: measured against a container
			-- publishing 5678, the local adapter opens an ephemeral port of its own,
			-- emits `debugpyWaitingForServer` for it and waits for the debuggee to
			-- dial back -- which a process inside a container cannot do. No error,
			-- no timeout, just a session that never initializes.
			dap.adapters["debugpy-remote"] = function(callback, config)
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 5678,
				})
			end

			dap.configurations.python = vim.list_extend(dap.configurations.python or {}, {
				{
					type = "python",
					request = "launch",
					name = "Python: Launch file (venv)",
					program = "${file}",
					console = "integratedTerminal",
					pythonPath = Util.python_path,
				},
				{
					type = "python",
					request = "launch",
					name = "Django: runserver",
					program = "${workspaceFolder}/manage.py",
					-- --noreload: the autoreloader forks, and the debugger would stay
					-- attached to the parent process where no breakpoint ever hits.
					args = { "runserver", "--noreload" },
					django = true,
					console = "integratedTerminal",
					pythonPath = Util.python_path,
				},
				{
					type = "python",
					request = "launch",
					name = "Django: manage.py <command>",
					program = "${workspaceFolder}/manage.py",
					args = function()
						return vim.split(vim.fn.input("manage.py "), " ", { trimempty = true })
					end,
					django = true,
					console = "integratedTerminal",
					pythonPath = Util.python_path,
				},
				-- The container case. Every configuration above starts a python on
				-- this machine, which cannot work when the interpreter, the
				-- installed packages and the source paths are all inside the image.
				--
				-- In the container:
				--
				--   pip install debugpy
				--   python -m debugpy --listen 0.0.0.0:5678 --wait-for-client \
				--     manage.py runserver 0.0.0.0:8000 --noreload
				--
				-- and publish 5678. `--noreload` for the same reason as above: the
				-- autoreloader forks and the debugger keeps the parent.
				--
				-- No `pythonPath` here -- attaching does not start an interpreter,
				-- the one in the container is already running.
				{
					type = "debugpy-remote",
					request = "attach",
					name = "Django: attach to debugpy in a container",
					host = function()
						return Util.dap_input("py_remote_host", "debugpy host: ", "127.0.0.1")
					end,
					port = function()
						return tonumber(Util.dap_input("py_remote_port", "debugpy port: ", "5678"))
					end,
					-- Without this a breakpoint is accepted and never hit: this side
					-- talks about /home/you/project/app/views.py and debugpy only
					-- knows /app/app/views.py.
					pathMappings = {
						{
							localRoot = "${workspaceFolder}",
							remoteRoot = function()
								return Util.dap_input("py_remote_root", "Project path inside the container: ", "/app")
							end,
						},
					},
					django = true,
					-- Step into Django itself, not just your own code. When a request
					-- dies somewhere in the middleware chain or in the ORM, that is
					-- exactly where the frame you need is.
					justMyCode = false,
				},
			})
		end,
	},

	-- Test running with neotest. The interpreter comes from the same resolver
	-- the language server and debugpy use, so a project venv is picked up
	-- without the shell having activated it -- pytest-django and the settings
	-- module it needs live in that venv, not in the system python.
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = { "nvim-neotest/neotest-python" },
		opts = {
			adapters = {
				["neotest-python"] = {
					python = function()
						return Util.python_path(Util.root())
					end,
					-- `runner` is left unset on purpose: neotest-python picks pytest
					-- when the project has it and falls back to unittest, which is
					-- what a Django project without pytest-django wants.
					dap = { justMyCode = false },
				},
			},
		},
	},

	-- Type checking with django-stubs. Write-only: mypy re-checks the whole
	-- import graph, which takes seconds even warm, so running it on InsertLeave
	-- like ruff would make typing stutter for a result that cannot change until
	-- the file is saved anyway.
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = { python = { "mypy" } },
			events_by_linter = { mypy = { "BufWritePost" } },
			linters = {
				mypy = {
					cmd = function()
						return venv_mypy(Util.root())
					end,
					condition = function()
						local root = Util.root()
						return venv_mypy(root) ~= nil and mypy_config(root) ~= nil
					end,
					prepend_args = {
						"--config-file",
						function()
							return mypy_config(Util.root())
						end,
						-- Share the cache the command line uses instead of dropping a
						-- second .mypy_cache wherever Neovim happens to be cd'd to.
						"--cache-dir",
						function()
							return Util.root() .. "/.mypy_cache"
						end,
					},
				},
			},
		},
	},

	-- Pick the virtualenv that basedpyright/ruff should use
	{
		"linux-cultist/venv-selector.nvim",
		ft = "python",
		cmd = "VenvSelect",
		opts = {
			options = {
				notify_user_on_venv_activation = true,
			},
		},
		keys = { { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select virtualenv", ft = "python" } },
	},
}
