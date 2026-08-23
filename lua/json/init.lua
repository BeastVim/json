local M = {}

function M.setup()
	local missing = {}
	if not Lsp then
		table.insert(missing, "Lsp")
	end
	if not Treesitter then
		table.insert(missing, "Treesitter")
	end
	if not Mason then
		table.insert(missing, "Mason")
	end
	if #missing > 0 then
		vim.notify(
			"json requires BeastVim's global " .. table.concat(missing, ", ") .. " (this plugin only works inside the BeastVim ecosystem)",
			vim.log.levels.ERROR,
			{ title = "json" }
		)
		return
	end

	-- jsonc buffers are parsed with the "json" grammar (there is no separate
	-- "jsonc" parser).
	vim.treesitter.language.register("json", "jsonc")
	Treesitter.ensure_parser("json")

	-- conform.nvim's `formatters_by_ft` is a plain mutable table it exposes
	-- for exactly this -- no BeastVim wrapper needed. `require("conform")`
	-- lazy-loads conform itself via its own module trigger, same as `Mason`/
	-- `Lsp` do for their own plugins.
	Mason.ensure_package({ "prettier" }, function()
		require("conform").formatters_by_ft.json = { "prettier" }
		require("conform").formatters_by_ft.jsonc = { "prettier" }
	end)

	-- Lsp.register (and thus vim.lsp.enable) must not run until the binary is
	-- confirmed installed: a client that fails to spawn once is left broken
	-- by Neovim's LSP client and never retries, even on a later FileType.
	Mason.ensure_package({ "json-lsp" }, function()
		Lsp.register("jsonls", {
			cmd = function(dispatchers)
				local cmd = "vscode-json-language-server"
				if vim.fn.executable(cmd) ~= 1 then
					cmd = Mason.bin(cmd)
				end
				return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
			end,
			filetypes = { "json", "jsonc" },
			root_markers = { ".git" },
			-- Formatting is delegated to prettier via conform above, so the
			-- server's own (lower-quality) formatter is disabled here.
			init_options = { provideFormatter = false },
			settings = {
				json = {
					validate = { enable = true },
				},
			},
			keys = {
				{ "K", vim.lsp.buf.hover, desc = "Hover", cond = "textDocument/hover" },
				{ "<leader>rn", vim.lsp.buf.rename, desc = "Rename", cond = "textDocument/rename" },
				{
					"<leader>la",
					vim.lsp.buf.code_action,
					mode = { "n", "v" },
					desc = "Code action",
					cond = "textDocument/codeAction",
				},
			},
		})
	end)
end

return M
