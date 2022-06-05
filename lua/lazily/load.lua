local lazily = require("lazily")

local function load(spec)
	if type(spec) == "string" then
		local package = spec
		if lazily.pending[package] then
			spec = lazily.pending[package].spec
			lazily.cancel(package)
		else
			spec = { package = package }
		end
	end

	local package = spec.package or spec[1]
	if lazily.loaded[package] then return end

	if spec.requires then
		for _, dependency in ipairs(spec.requires) do
			load(dependency)
		end
	end

	lazily.packadd(package)
	lazily.loaded[package] = true
end

return load
