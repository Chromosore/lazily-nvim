local function packadd(package)
	vim.cmd(([[packadd  %s]]):format(package))
end

return packadd
