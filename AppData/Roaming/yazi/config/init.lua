    function Linemode:size_and_mtime()
    local time = (self._file.cha and self._file.cha.mtime or 0) // 1  -- Changed from modified to mtime
    local timestr
    if time > 0 then
      timestr = os.date("%d/%m/%y %H:%M", time)
    else
      timestr = ""
    end
  
    local size = self._file:size()
    local sizestr
    if not size or size == 0 then
      sizestr = "0 B"
    elseif size < 1024 then
      sizestr = string.format("%d B", size)
    elseif size < 1024 * 1024 then
      sizestr = string.format("%.2f KB", size / 1024)
    else
      sizestr = string.format("%.2f MB", size / (1024 * 1024))
    end
  
    return ui.Line(string.format(" %s | %s ", sizestr, timestr))
  end

    --NOTE: for the fullborder plugin:
    require("full-border"):setup {
    	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    	type = ui.Border.ROUNDED,
    }

    --NOTE: https://yazi-rs.github.io/docs/tips/#user-group-in-status
    Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ui.Line {}
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		ui.Span(":"),
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		ui.Span(" "),
	}
end, 500, Status.RIGHT)
--NOTE: for the copy-file-contents plugin:
        require("copy-file-contents"):setup({
	clipboard_cmd = "default",
	append_char = "\n",
	notification = true,
})
-- note: for the starship plugin
require("starship"):setup()
-- Configure smart-enter plugin
require("smart-enter"):setup({
    open_multi = false
})
