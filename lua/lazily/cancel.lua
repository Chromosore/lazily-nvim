local lazily = require("lazily")

local function cancel(package)
	if not lazily.pending[package] then return end
	local spec = lazily.pending[package]

	if spec.autocmds then
		for _, autocmd in ipairs(spec.autocmds) do
			vim.api.nvim_del_autocmd(autocmd)
		end
	end

	if spec.commands then
		for _, command in ipairs(spec.commands) do
			vim.api.nvim_del_user_command(command)
		end
	end

	if spec.mappings then
		for _, mapping in ipairs(spec.mappings) do
			local mode, lhs = unpack(mapping)
			vim.keymap.del(mode, lhs)
		end
	end

	lazily.pending[package] = nil
end

return cancel
