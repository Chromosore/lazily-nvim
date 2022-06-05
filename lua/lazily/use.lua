local lazily = require("lazily")
local normalize = require("lazily.utils.normalize")

local function use(package, spec)
	spec = normalize(spec)

	local lazyspec = {}
	local loadspec = {
		package = package;
		requires = spec.requires;
	}

	if spec.autocmd then
		local autocmd = spec.autocmd

		lazyspec.autocmd = vim.api.nvim_create_autocmd(autocmd.event, {
			pattern = autocmd.pattern;
			callback = function(event)
				if not autocmd.filter or autocmd.filter(event) then
					lazily.load(package)
				end
			end;
		})
	end

	lazily.pending[package] = {
		spec = loadspec;
		lazy = lazyspec;
	}
end

return use
