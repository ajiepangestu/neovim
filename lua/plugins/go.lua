-- Go, including Fiber projects (html/template views).
--
-- Fiber's default view engine renders plain `.html` files containing `{{ ... }}`
-- actions. Those stay on the `html` filetype so emmet, tailwind and the html LSP
-- keep working; prettier is skipped for them further down because it reflows the
-- template actions. Files with an explicit Go template extension get the
-- `gohtmltmpl` filetype and treesitter highlighting instead.
vim.filetype.add({
	extension = {
		gohtml = "gohtmltmpl",
		gotmpl = "gohtmltmpl",
		tmpl = "gohtmltmpl",
	},
})
vim.treesitter.language.register("gotmpl", "gohtmltmpl")

--------------------------------------------------------------------------------
-- Struct tags and test scaffolding
--
-- Two things gopls does not do. In a Fiber project the first is constant work:
-- every request and response struct needs `json:"..."`, and a binding struct
-- usually wants `form:"..."` and `validate:"..."` beside it. Both tools are
-- plain CLIs, so this is a thin wrapper rather than another plugin.
--------------------------------------------------------------------------------

---Walk up from the cursor to the first node of one of `types`.
---@param types string[]
---@return TSNode?
local function ancestor(types)
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok or not node then
		return nil
	end
	while node do
		if vim.tbl_contains(types, node:type()) then
			return node
		end
		node = node:parent()
	end
end

---Name of the type declaration the cursor is inside, e.g. the `User` of
---`type User struct { ... }`.
---@return string?
local function struct_at_cursor()
	local decl = ancestor({ "type_declaration" })
	if not decl then
		return nil
	end
	for child in decl:iter_children() do
		if child:type() == "type_spec" then
			local name = child:field("name")[1]
			return name and vim.treesitter.get_node_text(name, 0) or nil
		end
	end
end

---Name of the function or method the cursor is inside.
---@return string?
local function func_at_cursor()
	local fn = ancestor({ "function_declaration", "method_declaration" })
	if not fn then
		return nil
	end
	local name = fn:field("name")[1]
	return name and vim.treesitter.get_node_text(name, 0) or nil
end

---Run a tool that rewrites the file on disk, then reload the buffer.
---@param cmd string[]
---@param on_ok? fun()
local function run_and_reload(cmd, on_ok)
	-- These tools read the file, not the buffer, so unsaved edits would be lost
	-- when the rewritten version is read back in.
	if vim.bo.modified then
		vim.cmd("write")
	end
	vim.system(cmd, { text = true }, function(out)
		vim.schedule(function()
			if out.code ~= 0 then
				local detail = out.stderr ~= "" and out.stderr or out.stdout
				vim.notify(cmd[1] .. ": " .. (detail ~= "" and detail or "exited " .. out.code), vim.log.levels.ERROR)
				return
			end
			vim.cmd("checktime")
			if on_ok then
				on_ok()
			end
		end)
	end)
end

---@param remove boolean
local function modify_tags(tags, remove)
	local struct = struct_at_cursor()
	if not struct then
		vim.notify("Cursor is not inside a struct declaration", vim.log.levels.WARN)
		return
	end
	local cmd = {
		"gomodifytags",
		"-file",
		vim.api.nvim_buf_get_name(0),
		"-struct",
		struct,
		remove and "-remove-tags" or "-add-tags",
		tags ~= "" and tags or "json",
		"-quiet",
		"-w",
	}
	if not remove then
		-- What `json:"userID"` should look like. snakecase is gomodifytags' own
		-- default and the usual Go convention for wire formats.
		vim.list_extend(cmd, { "-transform", "snakecase" })
	end
	run_and_reload(cmd)
end

vim.api.nvim_create_user_command("GoTagAdd", function(opts)
	modify_tags(opts.args, false)
end, { nargs = "?", desc = "Add struct tags (default: json)" })

vim.api.nvim_create_user_command("GoTagRemove", function(opts)
	modify_tags(opts.args, true)
end, { nargs = "?", desc = "Remove struct tags (default: json)" })

vim.api.nvim_create_user_command("GoTests", function(opts)
	local file = vim.api.nvim_buf_get_name(0)
	local cmd = { "gotests", "-w" }
	if opts.bang then
		table.insert(cmd, "-all")
	else
		local fn = func_at_cursor()
		if not fn then
			vim.notify("Cursor is not inside a function (use :GoTests! for the whole file)", vim.log.levels.WARN)
			return
		end
		vim.list_extend(cmd, { "-only", "^" .. fn .. "$" })
	end
	table.insert(cmd, file)
	run_and_reload(cmd, function()
		vim.notify("Wrote " .. vim.fn.fnamemodify(file, ":t:r") .. "_test.go", vim.log.levels.INFO)
	end)
end, { bang = true, desc = "Generate table-driven tests (bang: every function in the file)" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_go_tools", { clear = true }),
	pattern = "go",
	callback = function(ev)
		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
		end
		map("<leader>ct", "<cmd>GoTagAdd<cr>", "Add json struct tags")
		map("<leader>cT", function()
			-- Not "validate" by default: gomodifytags gives every tag the same
			-- transformed field name, so a validate tag would come out as
			-- `validate:"full_name"` rather than a rule like `validate:"required"`.
			vim.ui.input({ prompt = "Tags to add (comma separated): ", default = "json,form" }, function(tags)
				if tags and tags ~= "" then
					vim.cmd("GoTagAdd " .. tags)
				end
			end)
		end, "Add struct tags (prompt)")
		map("<leader>cR", "<cmd>GoTagRemove<cr>", "Remove json struct tags")
		map("<leader>cg", "<cmd>GoTests<cr>", "Generate test for function")
	end,
})

---Prefer the gopls installed by the Go toolchain (`go install golang.org/x/tools/
---gopls@latest`), which is built with the local Go version — the same binary the
---VS Code Go extension manages. A distro-packaged gopls on $PATH is often several
---releases behind. Returns nil to fall back to whatever `gopls` $PATH resolves to.
local function gopls_cmd()
	local bin = vim.env.GOBIN
	if not bin or bin == "" then
		local gopath = vim.env.GOPATH
		if not gopath or gopath == "" then
			gopath = vim.fs.normalize("~/go")
		end
		bin = gopath .. "/bin"
	end
	local exe = bin .. "/gopls"
	if vim.uv.fs_stat(exe) then
		return { exe }
	end
end

---Does the buffer look like a Go html/template rather than plain html?
---@param buf number
local function is_go_template(buf)
	if vim.bo[buf].filetype ~= "html" then
		return false
	end
	local head = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 200, false), "\n")
	return head:find("{{", 1, true) ~= nil
end

return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "gofumpt", "goimports", "gomodifytags", "gotests" })
			-- Only install gopls when the system doesn't already ship one; a mason
			-- gopls would shadow it on $PATH and can drift from the local toolchain.
			if vim.fn.executable("gopls") == 0 then
				table.insert(opts.ensure_installed, "gopls")
			end
		end,
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- Emmet in Go templates too (see plugins/nextjs.lua for the server)
				emmet_language_server = { filetypes_extra = { gohtmltmpl = true } },
				-- Tag and attribute completion in Go templates. gopls only checks
				-- the `{{ ... }}` actions; the surrounding markup is plain html.
				html = { filetypes_extra = { gohtmltmpl = true } },
				gopls = {
					-- lspconfig lists `gotmpl`, but nothing produces that filetype
					-- here: .gohtml/.gotmpl/.tmpl map to `gohtmltmpl` above so
					-- treesitter and emmet work. Without this gopls never attaches.
					filetypes_extra = { gohtmltmpl = true },
					cmd = gopls_cmd(),
					settings = {
						gopls = {
							gofumpt = true,
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							semanticTokens = true,
							-- Attaching gopls to templates is not enough on its own:
							-- it only analyses `{{ ... }}` in files whose extension is
							-- listed here (default is empty). Fiber's plain .html views
							-- are left out on purpose — that would treat every html
							-- file in the project as a Go template.
							templateExtensions = { "gohtml", "gotmpl", "tmpl" },
							-- Do NOT exclude `vendor`: in a vendored module every
							-- dependency lives there, and filtering it out breaks
							-- go-to-definition into third-party packages.
							directoryFilters = { "-.git", "-node_modules" },
							codelenses = {
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							analyses = {
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
						},
					},
				},
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "go", "gomod", "gosum", "gowork", "gotmpl" } },
	},

	-- Debugging Go with delve. mason-nvim-dap's default handler registers the
	-- `delve` adapter and its launch configurations ("Delve: Debug", "Delve:
	-- Debug test", ...) once the binary is installed, so this only has to ask
	-- for the install.
	{
		"jay-babu/mason-nvim-dap.nvim",
		optional = true,
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "delve" })
		end,
	},

	-- Debugging a Fiber app that runs inside a container. mason-nvim-dap's
	-- configurations all start delve locally, which cannot work when the binary,
	-- its GOPATH and its source paths live in the image.
	--
	-- In the container, run the target under a headless delve:
	--
	--   dlv debug --headless --listen=:2345 --api-version=2 \
	--     --accept-multiclient ./cmd/api
	--
	-- and publish 2345. `--accept-multiclient` is what lets you detach and
	-- reattach without restarting the process; without it the first disconnect
	-- kills the server.
	{
		"mfussenegger/nvim-dap",
		optional = true,
		opts = function()
			local dap = require("dap")
			local Util = require("config.util")

			-- A separate adapter name rather than wrapping `dap.adapters.delve`:
			-- mason-nvim-dap registers that one when the delve package finishes
			-- installing, which is asynchronous and may land after this runs.
			-- Replacing it here would either be overwritten or overwrite it,
			-- depending on the order -- and that order is not ours to control.
			dap.adapters["delve-remote"] = function(callback, config)
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 2345,
				})
			end

			dap.configurations.go = vim.list_extend(dap.configurations.go or {}, {
				{
					type = "delve-remote",
					request = "attach",
					-- `remote`, not `local`: the server is already debugging the
					-- target, so nvim-dap must not send a launch request.
					mode = "remote",
					name = "Fiber: attach to dlv in a container",
					host = function()
						return Util.dap_input("go_remote_host", "dlv host: ", "127.0.0.1")
					end,
					port = function()
						return tonumber(Util.dap_input("go_remote_port", "dlv port: ", "2345"))
					end,
					-- Without this every breakpoint is silently ignored: nvim-dap
					-- sends the path on this machine, delve compares it against the
					-- path compiled into the binary, and they never match.
					substitutePath = {
						{
							from = "${workspaceFolder}",
							to = function()
								return Util.dap_input("go_remote_root", "Module path inside the container: ", "/app")
							end,
						},
					},
				},
			})
		end,
	},

	-- Test running with neotest. neotest-golang shells out to `go test -json`,
	-- so it needs no extra tooling, and its `dap` strategy reuses the delve
	-- installed above for <leader>Nd.
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = { "fredrikaverpil/neotest-golang" },
		opts = {
			adapters = {
				["neotest-golang"] = {
					-- `-count=1` defeats Go's test cache, which a test runner has to
					-- do: a cached PASS from before the last edit is worse than no
					-- result. `-race` is deliberately absent -- it is the right flag
					-- for Fiber handlers under httptest, but it costs a 2-10x
					-- slowdown on every <leader>Nr and needs a C toolchain, so it
					-- belongs in CI or in this list when you go looking for a race.
					go_test_args = { "-v", "-count=1" },
					dap_go_enabled = true,
				},
			},
		},
	},

	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.go = { "goimports", "gofumpt" }

			-- Don't let prettier rewrite Fiber/Go templates that live in .html files.
			-- Both entries need it: plugins/formatting.lua prefers the prettierd
			-- daemon and only falls back to prettier, so vetoing one would leave the
			-- other free to reflow the template. This is the only place that sets a
			-- condition on them -- a second one elsewhere would overwrite this.
			opts.formatters = opts.formatters or {}
			for _, name in ipairs({ "prettier", "prettierd" }) do
				opts.formatters[name] = vim.tbl_extend("force", opts.formatters[name] or {}, {
					condition = function(_, ctx)
						return not is_go_template(ctx.buf)
					end,
				})
			end
		end,
	},
}
