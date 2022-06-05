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

	if spec.commands then
		lazyspec.commands = vim.tbl_map(function(command)
			vim.api.nvim_create_user_command(command, function(args)
				lazily.load(package)

				local range =
					args.range == 0
						and ""
					or args.range == 1
						and ("%d"):format(args.line1)
					or  args.range == 2
						and ("%d,%d"):format(args.line1, args.line2)
					or  (","):rep(args.range - 2)
						.. ("%d,%d"):format(args.line1, args.line2)

				vim.api.nvim_command(("%s%s%s %s"):format(
					range, command, args.bang and "!" or "", args.args))
			end, {
				range = true;
				bang = true;
				nargs = "*";
			})

			return command
		end, spec.commands)
	end

	if spec.mappings then
		lazyspec.mappings = vim.tbl_map(function(mapping)
			local mode, lhs = unpack(mapping)
			vim.keymap.set(mode, lhs, function()
				lazily.load(package)
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes(lhs, true, true, true),
					"mt", false)
			end)

			return mapping
		end, spec.mappings)
	end

	lazily.pending[package] = {
		spec = loadspec;
		lazy = lazyspec;
	}
end

return use
