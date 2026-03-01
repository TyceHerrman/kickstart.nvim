return {
	"nemanjamalesija/ts-expand-hover.nvim",
	ft = { "typescript", "typescriptreact" },
	opts = {
		-- Recommended: avoid conflicts with distros/plugins that already map `K`
		keymaps = { hover = "<leader>th" },
	},
}
