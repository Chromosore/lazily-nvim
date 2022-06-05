local lazily = require("lazily")

local function cancel(package)
	if not lazily.pending[package] then return end
	local lazyspec = lazily.pending[package].lazy

	if lazyspec.autocmd then
		vim.api.nvim_del_autocmd(lazyspec.autocmd)
	end

	lazily.pending[package] = nil
end

return cancel
