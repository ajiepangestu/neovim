-- Monorepo setup command
-- Creates pyrightconfig.json for Django API and .editorconfig for root

local M = {}

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function write_file(path, content)
	local f = io.open(path, "w")
	if f then
		f:write(content)
		f:close()
		return true
	end
	return false
end

local function create_pyright_config(api_path, settings_module)
	local config = string.format([[{
  "venvPath": ".",
  "venv": ".venv",
  "pythonVersion": "3.11",
  "typeCheckingMode": "basic",
  "reportMissingImports": true,
  "reportMissingTypeStubs": false,
  "reportAttributeAccessIssue": "none",
  "reportGeneralTypeIssues": "none",
  "extraPaths": ["."],
  "include": ["."],
  "exclude": ["**/node_modules", "**/__pycache__", "**/.venv"],
  "defineConstant": {
    "DJANGO_SETTINGS_MODULE": "%s"
  }
}
]], settings_module)

	local path = api_path .. "/pyrightconfig.json"
	if file_exists(path) then
		vim.notify("pyrightconfig.json already exists in " .. api_path, vim.log.levels.WARN)
		return false
	end

	if write_file(path, config) then
		vim.notify("Created " .. path, vim.log.levels.INFO)
		return true
	end
	return false
end

local function create_editorconfig(root_path)
	local config = [[root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false
]]

	local path = root_path .. "/.editorconfig"
	if file_exists(path) then
		vim.notify(".editorconfig already exists in " .. root_path, vim.log.levels.WARN)
		return false
	end

	if write_file(path, config) then
		vim.notify("Created " .. path, vim.log.levels.INFO)
		return true
	end
	return false
end

local function setup_monorepo()
	local cwd = vim.fn.getcwd()

	-- Check if api folder exists
	local api_path = cwd .. "/api"
	if not vim.fn.isdirectory(api_path) then
		vim.notify("api/ folder not found in " .. cwd, vim.log.levels.ERROR)
		vim.notify("Please run this command from the monorepo root directory", vim.log.levels.INFO)
		return
	end

	-- Prompt for Django settings module
	vim.ui.input({
		prompt = "Django settings module (e.g., myproject.settings): ",
		default = "myproject.settings",
	}, function(settings_module)
		if not settings_module or settings_module == "" then
			vim.notify("Cancelled", vim.log.levels.INFO)
			return
		end

		-- Create configs
		local created = 0
		if create_pyright_config(api_path, settings_module) then
			created = created + 1
		end
		if create_editorconfig(cwd) then
			created = created + 1
		end

		if created > 0 then
			vim.notify(string.format("Created %d config file(s)", created), vim.log.levels.INFO)
			vim.notify("\nNext steps:", vim.log.levels.INFO)
			vim.notify("1. cd api && python -m venv .venv && source .venv/bin/activate", vim.log.levels.INFO)
			vim.notify("2. pip install django django-stubs[compatible-mypy] ruff", vim.log.levels.INFO)
			vim.notify("3. Restart LSP: :LspRestart", vim.log.levels.INFO)
		else
			vim.notify("No files created (already exist?)", vim.log.levels.WARN)
		end
	end)
end

-- Create user command
vim.api.nvim_create_user_command("MonorepoSetup", setup_monorepo, {
	desc = "Setup monorepo config files (Django + Next.js)",
})

return M
