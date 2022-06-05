local function normalize(spec)
	local spec = vim.deepcopy(spec)

	for _, field in ipairs({"autocmd", "command", "mapping"}) do
		if spec[field] then
			if spec[field .. "s"] then
				error(("Cannot use both %s and %s"):format(field, field .. "s"))
			else
				spec[field .. "s"] = { spec[field] }
				spec[field] = nil
			end
		end
	end

	return spec
end

return normalize
