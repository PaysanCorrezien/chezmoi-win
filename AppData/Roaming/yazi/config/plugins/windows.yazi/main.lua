local M = {}

-- Get both the target file and its parent directory
local get_target = ya.sync(function()
	local tab = cx.active
	local file_path
	local parent_path
	
	if #tab.selected == 0 then
		if tab.current.hovered then
			file_path = tostring(tab.current.hovered.url)
		else
			file_path = tostring(tab.current.cwd)
		end
	else
		-- For PowerShell, we'll just use the first selected item
		file_path = tostring(tab.selected[1])
	end
	
	-- If path ends with a file extension, get its parent directory
	if file_path:match("%.%w+$") then
		parent_path = file_path:match("(.+)\\[^\\]+$") or file_path
	else
		parent_path = file_path
	end
	
	return file_path, parent_path
end)

local function show_properties(path)
	-- Get the script path using APPDATA environment variable
	local ps_script = os.getenv("APPDATA") .. "\\yazi\\config\\plugins\\windows.yazi\\scripts\\OpenFileDetails.ps1"
	
	local child, spawn_err = Command("pwsh.exe")
		:args({"-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ps_script, path})
		:stderr(Command.PIPED)
		:spawn()
	
	if spawn_err ~= nil then
		ya.notify({
			title = "Failed to show properties",
			content = "Status: " .. spawn_err,
			timeout = 5.0,
			level = "error",
		})
	else
		-- Wait for the process to complete
		local status, wait_err = child:wait()
		if wait_err ~= nil or (status and not status.success) then
			ya.notify({
				title = "Show properties failed",
				content = wait_err or "Process failed",
				timeout = 5.0,
				level = "error",
			})
		end
	end
end

local function open_powershell(path, as_admin)
	-- Get the script path using APPDATA environment variable
	local ps_script = os.getenv("APPDATA") .. "\\yazi\\config\\plugins\\windows.yazi\\scripts\\PowershellSession.ps1"
	
	local args = {"-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ps_script, path}
	if as_admin then
		table.insert(args, "-Admin")
	end
	
	local child, spawn_err = Command("pwsh.exe")
		:args(args)
		:stderr(Command.PIPED)
		:stdout(Command.PIPED)  -- Also capture stdout for debugging
		:spawn()
	
	if spawn_err ~= nil then
		ya.notify({
			title = "Failed to open PowerShell",
			content = "Status: " .. spawn_err,
			timeout = 5.0,
			level = "error",
		})
	else
		-- Wait for the process to complete
		local status, wait_err = child:wait()
		if wait_err ~= nil or (status and not status.success) then
			-- Try to read any error output
			local output = child:read_line()
			ya.notify({
				title = "Failed to open PowerShell",
				content = output or wait_err or "Process failed",
				timeout = 5.0,
				level = "error",
			})
		end
	end
end

local function set_wallpaper(path)
	-- Get the script path using APPDATA environment variable
	local ps_script = os.getenv("APPDATA") .. "\\yazi\\config\\plugins\\windows.yazi\\scripts\\SetWallpaper.ps1"
	
	local child, spawn_err = Command("pwsh.exe")
		:args({"-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ps_script, path})
		:stderr(Command.PIPED)
		:spawn()
	
	if spawn_err ~= nil then
		ya.notify({
			title = "Failed to set wallpaper",
			content = "Status: " .. spawn_err,
			timeout = 5.0,
			level = "error",
		})
	else
		-- Wait for the process to complete
		local status, wait_err = child:wait()
		if wait_err ~= nil or (status and not status.success) then
			local output = child:read_line()
			ya.notify({
				title = "Failed to set wallpaper",
				content = output or wait_err or "Process failed",
				timeout = 5.0,
				level = "error",
			})
		else
			ya.notify({
				title = "Wallpaper set",
				content = "Successfully set wallpaper",
				timeout = 2.0,
				level = "info",
			})
		end
	end
end

local function open_explorer(path)
	local child, spawn_err = Command("explorer.exe")
		:args({path})
		:stderr(Command.PIPED)
		:spawn()
	
	if spawn_err ~= nil then
		ya.notify({
			title = "Failed to open Explorer",
			content = "Status: " .. spawn_err,
			timeout = 5.0,
			level = "error",
		})
	else
		-- Wait for the process to complete
		local status, wait_err = child:wait()
		if wait_err ~= nil or (status and not status.success) then
			local output = child:read_line()
			ya.notify({
				title = "Failed to open Explorer",
				content = output or wait_err or "Process failed",
				timeout = 5.0,
				level = "error",
			})
		end
	end
end

function M.entry(_, job)
	ya.manager_emit("escape", { visual = true })
	
	local file_path, parent_path = get_target()
	if not file_path then return end
	
	local cmd = job.args[1]
	if cmd == "properties" then
		show_properties(file_path)
	elseif cmd == "powershell" then
		open_powershell(parent_path, false)
	elseif cmd == "powershell_admin" then
		open_powershell(parent_path, true)
	elseif cmd == "set-wallpaper" then
		set_wallpaper(file_path)
	elseif cmd == "open-explorer" then
		open_explorer(parent_path)
	else
		ya.notify({
			title = "Unknown command",
			content = "Command not recognized: " .. tostring(cmd),
			timeout = 5.0,
			level = "error",
		})
	end
end

return M
