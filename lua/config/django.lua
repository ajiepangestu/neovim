-- Django dependency installer with virtualenv safety checks

local M = {}

local function is_venv_active()
	local venv = vim.env.VIRTUAL_ENV
	if venv and venv ~= "" then
		return true, venv
	end
	return false, nil
end

---Compare two paths as the filesystem sees them: $VIRTUAL_ENV and the path
---built from getcwd() can be spelled differently (trailing slash, symlink) and
---still be the same directory. Without this the "differs from project venv"
---prompt fires on a venv that is in fact the right one.
local function same_path(a, b)
	if not a or not b then
		return false
	end
	return (vim.uv.fs_realpath(a) or vim.fs.normalize(a)) == (vim.uv.fs_realpath(b) or vim.fs.normalize(b))
end

---@return string|nil
local function get_venv_path(project_path)
	local venv_path = project_path .. "/.venv"
	-- `== 1`, not truthiness: isdirectory() returns 0/1 and 0 is truthy in Lua,
	-- so a bare `if` here would report every project as having a .venv.
	if vim.fn.isdirectory(venv_path) == 1 then
		return venv_path
	end
	return nil
end

---Install `packages` one after another, each one starting only once the
---previous has finished. Asynchronous on purpose: pip resolving and building a
---package takes tens of seconds, and vim.fn.systemlist() would freeze the whole
---editor for that entire time.
local function install_next(pip_path, packages, cwd, index, on_done)
	local package = packages[index]
	if not package then
		return on_done(true)
	end

	vim.notify("Installing " .. package .. "...", vim.log.levels.INFO)
	vim.system({ pip_path, "install", package }, { cwd = cwd, text = true }, function(out)
		vim.schedule(function()
			if out.code ~= 0 then
				vim.notify("✗ Failed to install " .. package, vim.log.levels.ERROR)
				local detail = out.stderr ~= "" and out.stderr or out.stdout
				if detail and detail ~= "" then
					vim.notify(detail, vim.log.levels.ERROR)
				end
				return on_done(false)
			end
			vim.notify("✓ " .. package .. " installed", vim.log.levels.INFO)
			install_next(pip_path, packages, cwd, index + 1, on_done)
		end)
	end)
end

---Kicks off the install and returns immediately; the guards below return early
---for the same reason, so none of them report a result. Whether the packages
---actually landed is reported by install_next through vim.notify, long after
---this has returned.
local function install_dependencies(project_path, packages)
	local venv_path = get_venv_path(project_path)

	if not venv_path then
		vim.notify("No .venv folder found in " .. project_path, vim.log.levels.ERROR)
		vim.notify("\nCreate virtualenv first:", vim.log.levels.INFO)
		vim.notify("  cd " .. vim.fn.fnamemodify(project_path, ":t"), vim.log.levels.INFO)
		vim.notify("  python -m venv .venv", vim.log.levels.INFO)
		vim.notify("  source .venv/bin/activate", vim.log.levels.INFO)
		return
	end

	local active, active_venv = is_venv_active()
	if not active then
		vim.notify("Virtualenv not activated!", vim.log.levels.ERROR)
		vim.notify("\nActivate it first:", vim.log.levels.INFO)
		vim.notify("  cd " .. vim.fn.fnamemodify(project_path, ":t"), vim.log.levels.INFO)
		vim.notify("  source .venv/bin/activate", vim.log.levels.INFO)
		vim.notify("\nThen restart Neovim and run :DjangoInstall again", vim.log.levels.INFO)
		return
	end

	if not same_path(active_venv, venv_path) then
		vim.notify(
			"Warning: Active venv (" .. active_venv .. ") differs from project venv (" .. venv_path .. ")",
			vim.log.levels.WARN
		)
		local continue = vim.fn.confirm("Continue with active venv?", "&Yes\n&No", 2)
		if continue ~= 1 then
			vim.notify("Cancelled", vim.log.levels.INFO)
			return
		end
	end

	vim.notify("Installing packages in virtualenv: " .. active_venv, vim.log.levels.INFO)

	-- A venv created by `uv venv` has no pip at all, so this fallback is not
	-- theoretical. `== 1` for the same reason as isdirectory() above.
	local pip_path = active_venv .. "/bin/pip"
	if vim.fn.filereadable(pip_path) ~= 1 then
		pip_path = "pip"
	end

	install_next(pip_path, packages, project_path, 1, function(ok)
		if not ok then
			return
		end
		vim.notify("\nAll packages installed successfully!", vim.log.levels.INFO)
		vim.notify("\nNext steps:", vim.log.levels.INFO)
		vim.notify("1. Restart LSP: :LspRestart", vim.log.levels.INFO)
		vim.notify("2. Open a Python file to activate basedpyright", vim.log.levels.INFO)
	end)
end

local function django_install()
	local cwd = vim.fn.getcwd()

	local active, venv_path = is_venv_active()
	if not active then
		vim.notify("No virtualenv detected!", vim.log.levels.ERROR)
		vim.notify("\nCurrent directory: " .. cwd, vim.log.levels.INFO)
		vim.notify("\nTo install Django dependencies safely:", vim.log.levels.INFO)
		vim.notify("1. Create virtualenv: python -m venv .venv", vim.log.levels.INFO)
		vim.notify("2. Activate it: source .venv/bin/activate", vim.log.levels.INFO)
		vim.notify("3. Restart Neovim", vim.log.levels.INFO)
		vim.notify("4. Run :DjangoInstall again", vim.log.levels.INFO)
		return
	end

	vim.notify("Virtualenv active: " .. venv_path, vim.log.levels.INFO)

	vim.ui.select({
		"django-stubs[compatible-mypy]",
		"ruff",
		"django",
		"All (django + django-stubs + ruff)",
	}, {
		prompt = "Select packages to install:",
	}, function(choice)
		if not choice then
			vim.notify("Cancelled", vim.log.levels.INFO)
			return
		end

		local packages = {}
		if choice == "All (django + django-stubs + ruff)" then
			packages = { "django", "django-stubs[compatible-mypy]", "ruff" }
		else
			packages = { choice }
		end

		install_dependencies(cwd, packages)
	end)
end

vim.api.nvim_create_user_command("DjangoInstall", django_install, {
	desc = "Install Django dependencies with virtualenv safety checks",
})

vim.api.nvim_create_user_command("VenvStatus", function()
	local active, venv_path = is_venv_active()
	if active then
		vim.notify("Virtualenv active: " .. venv_path, vim.log.levels.INFO)
	else
		vim.notify("No virtualenv active", vim.log.levels.WARN)
	end
end, {
	desc = "Check if virtualenv is active",
})

return M
