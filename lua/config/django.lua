-- Django dependency installer with virtualenv safety checks

local M = {}

local function is_venv_active()
	local venv = vim.env.VIRTUAL_ENV
	if venv and venv ~= "" then
		return true, venv
	end
	return false, nil
end

local function get_venv_path(project_path)
	local venv_path = project_path .. "/.venv"
	if vim.fn.isdirectory(venv_path) then
		return venv_path
	end
	return nil
end

local function run_command(cmd, cwd)
	local result = vim.fn.systemlist(cmd)
	local exit_code = vim.v.shell_error
	return result, exit_code == 0
end

local function install_dependencies(project_path, packages)
	local venv_path = get_venv_path(project_path)

	if not venv_path then
		vim.notify("No .venv folder found in " .. project_path, vim.log.levels.ERROR)
		vim.notify("\nCreate virtualenv first:", vim.log.levels.INFO)
		vim.notify("  cd " .. vim.fn.fnamemodify(project_path, ":t"), vim.log.levels.INFO)
		vim.notify("  python -m venv .venv", vim.log.levels.INFO)
		vim.notify("  source .venv/bin/activate", vim.log.levels.INFO)
		return false
	end

	local active, active_venv = is_venv_active()
	if not active then
		vim.notify("Virtualenv not activated!", vim.log.levels.ERROR)
		vim.notify("\nActivate it first:", vim.log.levels.INFO)
		vim.notify("  cd " .. vim.fn.fnamemodify(project_path, ":t"), vim.log.levels.INFO)
		vim.notify("  source .venv/bin/activate", vim.log.levels.INFO)
		vim.notify("\nThen restart Neovim and run :DjangoInstall again", vim.log.levels.INFO)
		return false
	end

	if active_venv ~= venv_path then
		vim.notify("Warning: Active venv (" .. active_venv .. ") differs from project venv (" .. venv_path .. ")", vim.log.levels.WARN)
		local continue = vim.fn.confirm("Continue with active venv?", "&Yes\n&No", 2)
		if continue ~= 1 then
			vim.notify("Cancelled", vim.log.levels.INFO)
			return false
		end
	end

	vim.notify("Installing packages in virtualenv: " .. active_venv, vim.log.levels.INFO)

	local pip_path = active_venv .. "/bin/pip"
	if not vim.fn.filereadable(pip_path) then
		pip_path = "pip"
	end

	for _, package in ipairs(packages) do
		vim.notify("Installing " .. package .. "...", vim.log.levels.INFO)
		local cmd = { pip_path, "install", package }
		local result, success = run_command(cmd, project_path)

		if success then
			vim.notify("✓ " .. package .. " installed", vim.log.levels.INFO)
		else
			vim.notify("✗ Failed to install " .. package, vim.log.levels.ERROR)
			vim.notify(table.concat(result, "\n"), vim.log.levels.ERROR)
			return false
		end
	end

	vim.notify("\nAll packages installed successfully!", vim.log.levels.INFO)
	vim.notify("\nNext steps:", vim.log.levels.INFO)
	vim.notify("1. Restart LSP: :LspRestart", vim.log.levels.INFO)
	vim.notify("2. Open a Python file to activate basedpyright", vim.log.levels.INFO)

	return true
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
