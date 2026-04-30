local M = {}

function M:peek(job)
	local limit = job.area.h
	local child = Command("hexyl")
		:arg({
			"--border", "none",
			"--terminal-width", tostring(job.area.w),
			"--color", "always",
			"--skip", tostring(job.skip * 16),
			"--length", tostring(limit * 16),
			tostring(job.file.url),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return
	end

	local i, lines = 0, ""
	repeat
		local next, event = child:read_line()
		if event == 1 then
			goto continue
		elseif event ~= 0 then
			break
		end
		i = i + 1
		lines = lines .. next
		::continue::
	until i >= limit

	child:start_kill()

	if i == 0 and job.skip > 0 then
		ya.emit("peek", { math.max(0, job.skip - limit), only_if = job.file.url, upper_bound = true })
	else
		ya.preview_widget(job, { ui.Text.parse(lines):area(job.area) })
	end
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end

	local step = math.floor(job.units * job.area.h / 10)
	step = step == 0 and ya.clamp(-1, job.units, 1) or step

	ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
end

return M
