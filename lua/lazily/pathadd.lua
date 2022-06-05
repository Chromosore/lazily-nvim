local slash = vim.fn.expand("/")

local function pathadd(path)
	return function(package)
		if #package == 0 then return end

		local pack = path .. slash .. package
		if vim.fn.isdirectory(pack) == 1 then
			vim.opt.runtimepath = vim.opt.runtimepath + pack
		end
	end
end

return pathadd
