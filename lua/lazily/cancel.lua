local lazily = require("lazily")

local function cancel(package)
	if not lazily.pending[package] then return end
	local lazyspec = lazily.pending[package].lazy

	if lazyspec.autocmds then
		for _, autocmd in ipairs(lazyspec.autocmds) do
			vim.api.nvim_del_autocmd(autocmd)
		end
	end

	if lazyspec.commands then
		for _, command in ipairs(lazyspec.commands) do
			vim.api.nvim_del_user_command(command)
		end
	end

	lazily.pending[package] = nil
end

return cancel
