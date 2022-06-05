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

return M
