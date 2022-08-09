local function ensure_tbl(item)
	if type(item) == "table" then
		return item
	end
	return { item }
end

local aliases = {
	cmd = "command",
	keys = "mapping",
}

local function normalize(spec)
	spec = vim.deepcopy(spec)

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

	-- if spec.cmd then
	-- end

	return spec
end

return normalize
