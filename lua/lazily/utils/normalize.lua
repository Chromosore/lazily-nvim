local function ensure_tbl(item)
	if type(item) == "table" then
		return item
	end
	if item == nil then
		return nil
	end
	return { item }
end

local function ensure_fn(value)
	if type(value) == "function" then
		return value
	end
	if type(value) == "string" then
		local fn, err = load(value)
		if err ~= nil then
			error(err)
		end
		return fn
	end
	error("`value` must be function or string, got " .. type(value))
end

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

	for _, field in ipairs({"setup", "config"}) do
		if spec[field] then
			spec[field] = vim.tbl_map(ensure_fn, ensure_tbl(spec[field]))
		end
	end

	return spec
end

return normalize
