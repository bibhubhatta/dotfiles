local M = {}

function M:peek(job)
	local limit = job.area.h
	local child = Command("hexyl")
		:args({
			"--border", "none",
			"--terminal-width", tostring(job.area.w),
			"--color", "always",
			"--skip-offset", tostring(job.skip * 16),
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
		ya.manager_emit("peek", { tostring(math.max(0, job.skip - limit)), only_if = tostring(job.file.url), upper_bound = "" })
	else
		ya.preview_widget(job, { ui.Text.parse(lines):area(job.area) })
	end
end

function M:seek(job)
	local h = cx.active.preview.area.h
	local step = math.floor(job.units * h / 10)
	local new_skip = math.max(0, cx.active.preview.skip + step)
	ya.manager_emit("peek", { tostring(new_skip), only_if = tostring(job.file.url), upper_bound = "" })
end

return M
