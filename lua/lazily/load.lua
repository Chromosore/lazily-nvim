local lazily = require("lazily")

local function load(package)
	if not lazily.pending[package] then return end

	local spec = lazily.pending[package].spec
	lazily.cancel(package)

	if spec.requires then
		for _, dependency in ipairs(spec.requires) do
			load(dependency)
		end
	end

	lazily.packadd(package)
end

return load
