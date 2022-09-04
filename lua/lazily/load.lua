local lazily = require("lazily")

local function load(package)
	if not lazily.pending[package] then return end

	local spec = lazily.pending[package]
	lazily.cancel(package)

	if spec.setup then
		for _, hook in ipairs(spec.setup) do hook() end
	end

	if spec.requires then
		for _, dependency in ipairs(spec.requires) do
			if lazily.pending[dependency] then
				-- load package scheduled for lazy loading
				load(dependency)
			else
				-- load regular package
				lazily.opts.load(dependency)
			end
		end
	end

	lazily.opts.load(package)

	if spec.config then
		for _, hook in ipairs(spec.config) do hook() end
	end
end

return load
