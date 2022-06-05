local M = {}

setmetatable(M, {
	__index = function(table, key)
		local exists, module = pcall(require,
			string.format("lazily.%s", key))

		if exists then
			table[key] = module
			return module
		end
	end;
})

M.pending = {}

M.opts = {
	load = M.packadd;
}

function M.setup(opts)
	vim.validate {
		load = { opts.load, "function" };
	}

	M.opts = vim.tbl_extend("force", M.opts, opts)
end

return M
