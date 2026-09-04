-- Docker: Dockerfiles and compose files.
--
-- Compose needs nothing here beyond what plugins/lsp.lua already sets up.
-- `docker-compose*.y{a,}ml` and `compose*.y{a,}ml` resolve to the plain `yaml`
-- filetype, and the SchemaStore catalogue wired into yamlls maps exactly those
-- patterns -- overlays like `docker-compose.prod.yml` included -- to
-- compose-spec.json. Measured on a three-service file: 92 completion items at a
-- service key, 9 at the document root, hover on every key, and a misspelled
-- `environmnet:` reported as "Property environmnet is not allowed".
--
-- docker_compose_language_service was tried on top of that and taken out again.
-- Measured against the same file, running alongside yamlls:
--
--   completion      0 items at every position probed, trigger characters
--                   included. The schema is what answers.
--   hover           equivalent prose to yamlls', which additionally cites the
--                   schema the text came from.
--   diagnostics     the same schema violations, reported twice.
--   code lens       4 of them, and this is what turns it into a net loss. They
--                   invoke `vscode-containers.compose.up`, a VS Code *extension*
--                   command, and the server advertises no executeCommandProvider
--                   -- nothing here can run them. Their titles carry VS Code icon
--                   markup, so they render literally as `$(play) Run Service`.
--                   With `codelens = { enabled = true }` in plugins/lsp.lua that
--                   is four dead lines above every compose file.
--   document links  the one real gain: `image: postgres:16` links to Docker Hub.
--
-- One working document link does not pay for the rest. Attaching it also means
-- moving compose onto the compound filetype it is the only consumer of, which
-- three things in this config match exactly and would have to be re-registered
-- for: treesitter's `get_lang`, conform's `formatters_by_ft` and nvim-lint's
-- `linters_by_ft`.
--
-- The Dockerfile is what was actually missing: it had a treesitter parser and
-- nothing else.
local Util = require("config.util")

---Run a command in a floating terminal at the project root.
---@param cmd string[]
---@param opts? { title?: string }
local function float(cmd, opts)
	opts = opts or {}
	if vim.fn.executable(cmd[1]) == 0 then
		vim.notify(cmd[1] .. " is not installed", vim.log.levels.ERROR)
		return
	end
	require("snacks").terminal.open(cmd, {
		cwd = Util.root(),
		interactive = true,
		win = {
			style = "terminal",
			border = "rounded",
			title = opts.title or table.concat(cmd, " "),
			title_pos = "center",
			width = 0.9,
			height = 0.9,
		},
	})
end

return {
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
		opts = { ensure_installed = { "dockerfile-language-server", "hadolint" } },
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				dockerls = {
					-- lspconfig roots this on a file literally named `Dockerfile`, so
					-- a project whose only dockerfile is `Dockerfile.dev` -- or one
					-- with several under different directories -- gets a separate
					-- single-file server per buffer. These markers put the root at the
					-- project instead, which is one client rather than N.
					root_markers_extra = {
						["compose.yaml"] = true,
						["compose.yml"] = true,
						["docker-compose.yaml"] = true,
						["docker-compose.yml"] = true,
						[".git"] = true,
					},
					settings = {
						docker = {
							languageserver = {
								formatter = {
									-- Leave the body of a multi-line `RUN ... && \` alone.
									-- The formatter's own indentation of continuations
									-- fights any hand-alignment, and in these stacks those
									-- blocks are long: apt-get chains, `go build` flags,
									-- pnpm install steps.
									ignoreMultilineInstructions = true,
								},
							},
						},
					},
				},
			},
		},
	},

	-- `dockerfile` is already requested by plugins/treesitter.lua; repeated so
	-- this file stands on its own, and `ensure_installed` is opts_extend so the
	-- duplicate is free. `gitignore` is the new one: `.dockerignore` resolves to
	-- that filetype, and getting it wrong is a classic way to ship node_modules
	-- or a .venv into an image.
	{
		"nvim-treesitter/nvim-treesitter",
		-- `opts_extend` has to be repeated on every fragment that adds to the
		-- list, not just on the one that owns the plugin. lazy merges fragments
		-- in file order and reads `opts_extend` from the fragment being merged
		-- (or an EARLIER one); the owning spec here is alphabetically last, so at
		-- this point in the chain it is not visible yet and a plain table would
		-- REPLACE everything the files before it contributed instead of adding
		-- to it. Silently: nothing errors, the packages simply never install.
		opts_extend = { "ensure_installed" },
		opts = { ensure_installed = { "dockerfile", "gitignore" } },
	},

	-- hadolint is the whole point of this file. dockerls validates syntax; it
	-- says nothing about the build itself. hadolint reports the things that
	-- actually bite in these stacks -- an unpinned `apt-get install` (DL3008),
	-- `npm install` where the lockfile should be respected, a missing
	-- `--no-install-recommends`, `COPY` of the whole context ahead of the
	-- dependency layer -- and runs the file's `RUN` bodies through shellcheck on
	-- top of that.
	{
		"mfussenegger/nvim-lint",
		opts = { linters_by_ft = { dockerfile = { "hadolint" } } },
	},

	-- Container inspection without leaving the editor: image/container list,
	-- logs, exec, prune. Same shape as <leader>gg for lazygit.
	--
	-- <leader>k, not d or D: `<leader>d` closes the buffer and `<leader>D` is the
	-- debug group. k is for kontainer.
	{
		"folke/snacks.nvim",
		keys = {
			{
				"<leader>kd",
				function()
					if vim.fn.executable("lazydocker") == 0 then
						vim.notify(
							"lazydocker is not installed.\nInstall it with:  go install github.com/jesseduffield/lazydocker@latest",
							vim.log.levels.WARN
						)
						return
					end
					float({ "lazydocker" }, { title = " LazyDocker " })
				end,
				desc = "LazyDocker",
			},
			{
				"<leader>kl",
				function()
					float({ "docker", "compose", "logs", "-f", "--tail=200" }, { title = " compose logs " })
				end,
				desc = "Compose logs (follow)",
			},
			{
				"<leader>kp",
				function()
					float({ "docker", "compose", "ps", "--all" }, { title = " compose ps " })
				end,
				desc = "Compose ps",
			},
		},
	},

	{
		"folke/which-key.nvim",
		-- Same reason as the `ensure_installed` fragments: `opts_extend` is read
		-- from the fragment being merged or an earlier one, and the which-key spec
		-- that declares it lives in plugins/editor.lua. Files sorting before that
		-- would otherwise REPLACE the group list instead of adding to it -- which
		-- is exactly how `<leader>D` lost its "debug" label.
		opts_extend = { "spec" },
		opts = { spec = { { "<leader>k", group = "docker" } } },
	},
}
