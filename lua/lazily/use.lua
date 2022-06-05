local lazily = require("lazily")
local normalize = require("lazily.utils.normalize")

local function use(package, spec)
	spec = normalize(spec)

	local lazyspec = {}
	local loadspec = {
		package = package;
		requires = spec.requires;
	}

	if spec.autocmds then
		lazyspec.autocmds = vim.tbl_map(function(autocmd)
			return vim.api.nvim_create_autocmd(autocmd.event, {
				pattern = autocmd.pattern;
				callback = function(event)
					if not autocmd.filter or autocmd.filter(event) then
						lazily.load(package)
					end
				end;
			})
		end, spec.autocmds)
	end

	lazily.pending[package] = {
		spec = loadspec;
		lazy = lazyspec;
	}
end

return use
