local M = {}

local workspace_dir = vim.fn.stdpath("data") .. "/workspaces"
local current_workspace = nil

local function ensure_workspace_dir()
	if vim.fn.isdirectory(workspace_dir) == 0 then
		vim.fn.mkdir(workspace_dir, "p")
	end
end

local function workspace_path(name)
	return workspace_dir .. "/" .. name .. ".json"
end

local function read_json(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*all")
	f:close()
	local ok, data = pcall(vim.json.decode, content)
	if ok then
		return data
	end
	return nil
end

local function write_json(path, data)
	local f = io.open(path, "w")
	if not f then
		return false
	end
	f:write(vim.json.encode(data))
	f:close()
	return true
end

local function get_all_workspaces()
	ensure_workspace_dir()
	local workspaces = {}
	local files = vim.fn.readdir(workspace_dir)
	for _, file in ipairs(files) do
		if file:match("%.json$") then
			local name = file:gsub("%.json$", "")
			local data = read_json(workspace_path(name))
			if data then
				table.insert(workspaces, {
					name = name,
					folders = data.folders or {},
					last_opened = data.last_opened or "",
				})
			end
		end
	end
	table.sort(workspaces, function(a, b)
		return a.last_opened > b.last_opened
	end)
	return workspaces
end

local function update_last_opened(name)
	local path = workspace_path(name)
	local data = read_json(path)
	if data then
		data.last_opened = os.date("!%Y-%m-%dT%H:%M:%SZ")
		write_json(path, data)
	end
end

function M.save(name)
	if not name or name == "" then
		vim.ui.input({ prompt = "Workspace name: " }, function(input)
			if input and input ~= "" then
				M.save(input)
			end
		end)
		return
	end

	ensure_workspace_dir()

	local folders = {}
	local cwd = vim.fn.getcwd()
	table.insert(folders, cwd)

	for _, arg in ipairs(vim.v.argv) do
		if arg:match("^/") or arg:match("^~") then
			local expanded = vim.fn.expand(arg)
			if vim.fn.isdirectory(expanded) == 1 and expanded ~= cwd then
				table.insert(folders, expanded)
			end
		end
	end

	local data = {
		name = name,
		folders = folders,
		last_opened = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}

	if write_json(workspace_path(name), data) then
		current_workspace = name
		vim.notify("Workspace '" .. name .. "' saved", vim.log.levels.INFO)
	else
		vim.notify("Failed to save workspace '" .. name .. "'", vim.log.levels.ERROR)
	end
end

function M.load(name)
	if not name or name == "" then
		local workspaces = get_all_workspaces()
		if #workspaces == 0 then
			vim.notify("No saved workspaces", vim.log.levels.INFO)
			return
		end

		vim.ui.select(
			vim.tbl_map(function(ws)
				return ws.name
			end, workspaces),
			{ prompt = "Load workspace: " },
			function(choice)
				if choice then
					M.load(choice)
				end
			end
		)
		return
	end

	local path = workspace_path(name)
	local data = read_json(path)
	if not data then
		vim.notify("Workspace '" .. name .. "' not found", vim.log.levels.ERROR)
		return
	end

	local folders = data.folders or {}
	if #folders == 0 then
		vim.notify("Workspace '" .. name .. "' has no folders", vim.log.levels.WARN)
		return
	end

	update_last_opened(name)
	current_workspace = name

	local cmd = "nvim"
	for _, folder in ipairs(folders) do
		cmd = cmd .. " " .. vim.fn.shellescape(folder)
	end

	vim.notify("Loading workspace '" .. name .. "'...", vim.log.levels.INFO)

	vim.fn.jobstart(cmd, {
		detach = true,
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify("Failed to load workspace", vim.log.levels.ERROR)
			end
		end,
	})
end

function M.add_folder(folder)
	if not current_workspace then
		vim.notify("No workspace loaded. Save or load a workspace first.", vim.log.levels.WARN)
		return
	end

	if not folder or folder == "" then
		vim.ui.input({ prompt = "Folder path: ", completion = "dir" }, function(input)
			if input and input ~= "" then
				M.add_folder(input)
			end
		end)
		return
	end

	local expanded = vim.fn.expand(folder)
	if vim.fn.isdirectory(expanded) == 0 then
		vim.notify("Directory not found: " .. expanded, vim.log.levels.ERROR)
		return
	end

	local path = workspace_path(current_workspace)
	local data = read_json(path)
	if not data then
		vim.notify("Workspace file not found", vim.log.levels.ERROR)
		return
	end

	data.folders = data.folders or {}
	for _, f in ipairs(data.folders) do
		if f == expanded then
			vim.notify("Folder already in workspace", vim.log.levels.INFO)
			return
		end
	end

	table.insert(data.folders, expanded)
	if write_json(path, data) then
		vim.notify("Added '" .. expanded .. "' to workspace '" .. current_workspace .. "'", vim.log.levels.INFO)
	else
		vim.notify("Failed to update workspace", vim.log.levels.ERROR)
	end
end

function M.remove_folder()
	if not current_workspace then
		vim.notify("No workspace loaded", vim.log.levels.WARN)
		return
	end

	local path = workspace_path(current_workspace)
	local data = read_json(path)
	if not data or not data.folders or #data.folders == 0 then
		vim.notify("No folders in workspace", vim.log.levels.INFO)
		return
	end

	vim.ui.select(data.folders, { prompt = "Remove folder from workspace: " }, function(choice)
		if choice then
			local new_folders = {}
			for _, f in ipairs(data.folders) do
				if f ~= choice then
					table.insert(new_folders, f)
				end
			end
			data.folders = new_folders
			if write_json(path, data) then
				vim.notify("Removed '" .. choice .. "' from workspace", vim.log.levels.INFO)
			else
				vim.notify("Failed to update workspace", vim.log.levels.ERROR)
			end
		end
	end)
end

function M.list()
	local workspaces = get_all_workspaces()
	if #workspaces == 0 then
		vim.notify("No saved workspaces", vim.log.levels.INFO)
		return
	end

	local items = vim.tbl_map(function(ws)
		local folder_count = #ws.folders
		return {
			name = ws.name,
			folders = ws.folders,
			last_opened = ws.last_opened,
			text = string.format("%s (%d folders)", ws.name, folder_count),
		}
	end, workspaces)

	if pcall(require, "snacks") then
		Snacks.picker.pick({
			title = "Workspaces",
			items = items,
			format = function(item)
				return {
					{ item.text, "Normal" },
				}
			end,
			confirm = function(picker, item)
				picker:close()
				if item then
					M.load(item.name)
				end
			end,
		})
	else
		vim.ui.select(
			vim.tbl_map(function(item)
				return item.name
			end, items),
			{ prompt = "Workspaces: " },
			function(choice)
				if choice then
					M.load(choice)
				end
			end
		)
	end
end

function M.delete(name)
	if not name or name == "" then
		local workspaces = get_all_workspaces()
		if #workspaces == 0 then
			vim.notify("No saved workspaces", vim.log.levels.INFO)
			return
		end

		vim.ui.select(
			vim.tbl_map(function(ws)
				return ws.name
			end, workspaces),
			{ prompt = "Delete workspace: " },
			function(choice)
				if choice then
					M.delete(choice)
				end
			end
		)
		return
	end

	local path = workspace_path(name)
	if vim.fn.filereadable(path) == 1 then
		os.remove(path)
		if current_workspace == name then
			current_workspace = nil
		end
		vim.notify("Workspace '" .. name .. "' deleted", vim.log.levels.INFO)
	else
		vim.notify("Workspace '" .. name .. "' not found", vim.log.levels.ERROR)
	end
end

function M.current()
	if current_workspace then
		vim.notify("Current workspace: " .. current_workspace, vim.log.levels.INFO)
	else
		vim.notify("No workspace loaded", vim.log.levels.INFO)
	end
end

vim.api.nvim_create_user_command("WorkspaceSave", function(opts)
	M.save(opts.args)
end, { nargs = "?", desc = "Save current workspace" })

vim.api.nvim_create_user_command("WorkspaceLoad", function(opts)
	M.load(opts.args)
end, { nargs = "?", desc = "Load a saved workspace" })

vim.api.nvim_create_user_command("WorkspaceList", function()
	M.list()
end, { desc = "List all saved workspaces" })

vim.api.nvim_create_user_command("WorkspaceAdd", function(opts)
	M.add_folder(opts.args)
end, { nargs = "?", desc = "Add folder to current workspace" })

vim.api.nvim_create_user_command("WorkspaceRemove", function()
	M.remove_folder()
end, { desc = "Remove folder from current workspace" })

vim.api.nvim_create_user_command("WorkspaceDelete", function(opts)
	M.delete(opts.args)
end, { nargs = "?", desc = "Delete a saved workspace" })

vim.api.nvim_create_user_command("WorkspaceCurrent", function()
	M.current()
end, { desc = "Show current workspace name" })

vim.keymap.set("n", "<leader>Ws", function()
	M.save()
end, { desc = "Save workspace" })

vim.keymap.set("n", "<leader>Wo", function()
	M.list()
end, { desc = "Open workspace" })

vim.keymap.set("n", "<leader>Wa", function()
	M.add_folder()
end, { desc = "Add folder to workspace" })

vim.keymap.set("n", "<leader>Wr", function()
	M.remove_folder()
end, { desc = "Remove folder from workspace" })

vim.keymap.set("n", "<leader>Wd", function()
	M.delete()
end, { desc = "Delete workspace" })

vim.keymap.set("n", "<leader>Wc", function()
	M.current()
end, { desc = "Show current workspace" })

return M
