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

local function read_file(path)
	local f = io.open(path, "r")
	if f then
		local content = f:read("*all")
		f:close()
		return content
	end
	return nil
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

local function append_to_file(path, content)
	local f = io.open(path, "a")
	if f then
		f:write(content)
		f:close()
		return true
	end
	return false
end

local function validate_python_module(name)
	if not name or name == "" then
		return false, "Module name cannot be empty"
	end
	if name:match("^%d") then
		return false, "Module name cannot start with a number"
	end
	if not name:match("^[%a_][%w_]*$") then
		return false, "Module name can only contain letters, numbers, and underscores"
	end
	return true
end

local function validate_settings_module(settings_module)
	if not settings_module or settings_module == "" then
		return false, "Settings module cannot be empty"
	end

	local parts = vim.split(settings_module, ".", { plain = true })
	for _, part in ipairs(parts) do
		local valid, err = validate_python_module(part)
		if not valid then
			return false, string.format("Invalid module part '%s': %s", part, err)
		end
	end

	if #parts < 2 then
		return false, "Settings module should be in format 'project.settings'"
	end

	return true
end

local function detect_django_folder(root_path)
	local candidates = { "api", "backend", "server", "django", "app", "python" }

	for _, folder in ipairs(candidates) do
		local path = root_path .. "/" .. folder
		-- `== 1`, not truthiness: isdirectory() returns 0/1 and 0 is truthy in Lua.
		if vim.fn.isdirectory(path) == 1 then
			if file_exists(path .. "/manage.py") or file_exists(path .. "/requirements.txt") then
				return folder
			end
		end
	end

	for _, item in ipairs(vim.fn.readdir(root_path)) do
		local path = root_path .. "/" .. item
		if vim.fn.isdirectory(path) == 1 and file_exists(path .. "/manage.py") then
			return item
		end
	end

	return nil
end

local function check_pyproject_toml(api_path)
	local pyproject_path = api_path .. "/pyproject.toml"
	if not file_exists(pyproject_path) then
		return nil
	end

	local content = read_file(pyproject_path)
	if not content then
		return nil
	end

	if content:match("%[tool%.pyright%]") or content:match("%[tool%.basedpyright%]") then
		return "has_config"
	else
		return "exists_no_config"
	end
end

local function create_pyright_config(api_path, settings_module)
	local config = string.format(
		[[{
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
]],
		settings_module
	)

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

local function add_to_pyproject_toml(api_path, settings_module)
	local config = string.format(
		[[

[tool.basedpyright]
venvPath = "."
venv = ".venv"
pythonVersion = "3.11"
typeCheckingMode = "basic"
reportMissingImports = true
reportMissingTypeStubs = false
reportAttributeAccessIssue = "none"
reportGeneralTypeIssues = "none"
extraPaths = ["."]
include = ["."]
exclude = ["**/node_modules", "**/__pycache__", "**/.venv"]

[tool.basedpyright.defineConstant]
DJANGO_SETTINGS_MODULE = "%s"
]],
		settings_module
	)

	local path = api_path .. "/pyproject.toml"
	if append_to_file(path, config) then
		vim.notify("Added basedpyright config to " .. path, vim.log.levels.INFO)
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

	local django_folder = detect_django_folder(cwd)
	if not django_folder then
		vim.notify("No Django project folder found in " .. cwd, vim.log.levels.ERROR)
		vim.notify(
			"Expected folder with manage.py: api/, backend/, server/, django/, app/, or python/",
			vim.log.levels.INFO
		)
		return
	end

	local api_path = cwd .. "/" .. django_folder

	vim.ui.input({
		prompt = "Django folder: ",
		default = django_folder,
	}, function(folder_name)
		if not folder_name or folder_name == "" then
			vim.notify("Cancelled", vim.log.levels.INFO)
			return
		end

		local final_api_path = cwd .. "/" .. folder_name
		if vim.fn.isdirectory(final_api_path) ~= 1 then
			vim.notify("Folder " .. folder_name .. " does not exist", vim.log.levels.ERROR)
			return
		end

		local project_name = folder_name:gsub("-", "_"):gsub("^%l", string.upper)
		local default_settings = project_name:lower() .. ".settings"

		vim.ui.input({
			prompt = "Django settings module: ",
			default = default_settings,
		}, function(settings_module)
			if not settings_module or settings_module == "" then
				vim.notify("Cancelled", vim.log.levels.INFO)
				return
			end

			local valid, err = validate_settings_module(settings_module)
			if not valid then
				vim.notify("Invalid settings module: " .. err, vim.log.levels.ERROR)
				vim.notify("Example: myproject.settings", vim.log.levels.INFO)
				return
			end

			local created = 0
			local pyproject_status = check_pyproject_toml(final_api_path)

			if pyproject_status == "has_config" then
				vim.notify(
					"pyproject.toml already has pyright config, skipping pyrightconfig.json",
					vim.log.levels.INFO
				)
			elseif pyproject_status == "exists_no_config" then
				vim.ui.select({ "Add to pyproject.toml", "Create pyrightconfig.json" }, {
					prompt = "pyproject.toml exists. How to add basedpyright config?",
				}, function(choice)
					if choice == "Add to pyproject.toml" then
						if add_to_pyproject_toml(final_api_path, settings_module) then
							created = created + 1
						end
					else
						if create_pyright_config(final_api_path, settings_module) then
							created = created + 1
						end
					end

					if create_editorconfig(cwd) then
						created = created + 1
					end

					if created > 0 then
						vim.notify(string.format("Created/updated %d config file(s)", created), vim.log.levels.INFO)
						vim.notify("\nNext steps:", vim.log.levels.INFO)
						vim.notify(
							"1. cd " .. folder_name .. " && python -m venv .venv && source .venv/bin/activate",
							vim.log.levels.INFO
						)
						vim.notify("2. pip install django django-stubs[compatible-mypy] ruff", vim.log.levels.INFO)
						vim.notify("3. Restart LSP: :LspRestart", vim.log.levels.INFO)
					else
						vim.notify("No files created (already exist?)", vim.log.levels.WARN)
					end
				end)
				return
			else
				if create_pyright_config(final_api_path, settings_module) then
					created = created + 1
				end
			end

			if create_editorconfig(cwd) then
				created = created + 1
			end

			if created > 0 then
				vim.notify(string.format("Created %d config file(s)", created), vim.log.levels.INFO)
				vim.notify("\nNext steps:", vim.log.levels.INFO)
				vim.notify(
					"1. cd " .. folder_name .. " && python -m venv .venv && source .venv/bin/activate",
					vim.log.levels.INFO
				)
				vim.notify("2. pip install django django-stubs[compatible-mypy] ruff", vim.log.levels.INFO)
				vim.notify("3. Restart LSP: :LspRestart", vim.log.levels.INFO)
			else
				vim.notify("No files created (already exist?)", vim.log.levels.WARN)
			end
		end)
	end)
end

vim.api.nvim_create_user_command("MonorepoSetup", setup_monorepo, {
	desc = "Setup monorepo config files (Django + Next.js)",
})

return M
