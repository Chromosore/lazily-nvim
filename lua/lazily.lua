local M = {}


function M.packadd(package)
	vim.cmd(([[packadd  %s]]):format(package))
end


M.pending = {}
local load = M.packadd

function M.setup(opts)
	vim.validate {
		load = { opts.load, "function" };
	}

	load = opts.load
end


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


function M.use(package, spec)
	-- rely on normalize copying spec
	spec = normalize(spec)
	spec.package = package

	if spec.autocmds then
		spec.autocmds = vim.tbl_map(function(autocmd)
			return vim.api.nvim_create_autocmd(autocmd.event, {
				pattern = autocmd.pattern;
				callback = function(event)
					if not autocmd.filter or autocmd.filter(event) then
						M.load(package)
					end
				end;
			})
		end, spec.autocmds)
	end

	if spec.commands then
		spec.commands = vim.tbl_map(function(command)
			vim.api.nvim_create_user_command(command, function(args)
				M.load(package)

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
		spec.mappings = vim.tbl_map(function(mapping)
			local mode, lhs = unpack(mapping)
			vim.keymap.set(mode, lhs, function()
				M.load(package)
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes(lhs, true, true, true),
					"mt", false)
			end)

			return mapping
		end, spec.mappings)
	end

	M.pending[package] = spec
	return spec
end


function M.load(package)
	if not M.pending[package] then return end

	local spec = M.pending[package]
	M.cancel(package)

	if spec.setup then
		for _, hook in ipairs(spec.setup) do hook() end
	end

	if spec.requires then
		for _, dependency in ipairs(spec.requires) do
			if M.pending[dependency] then
				-- load package scheduled for lazy loading
				load(dependency)
			else
				-- load regular package
				load(dependency)
			end
		end
	end

	load(package)

	if spec.config then
		for _, hook in ipairs(spec.config) do hook() end
	end
end


function M.cancel(package)
	if not M.pending[package] then return end
	local spec = M.pending[package]

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

	M.pending[package] = nil
end


return M
