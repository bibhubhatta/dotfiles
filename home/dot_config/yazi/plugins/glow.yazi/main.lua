local M = {}

function M:peek(job)
	local child = Command("glow")
		:args({ "-s", "dark", "-w", tostring(job.area.w), tostring(job.file.url) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return require("code"):peek(job)
	end

	local limit = job.area.h
	local i, lines = 0, ""
	repeat
		local next, event = child:read_line()
		if event == 1 then
			goto continue
		elseif event ~= 0 then
			break
		end

		i = i + 1
		if i > job.skip then
			lines = lines .. next
		end

		::continue::
	until i >= job.skip + limit

	child:start_kill()

	if job.skip > 0 and i < job.skip + limit then
		ya.manager_emit("peek", { tostring(math.max(0, i - limit)), only_if = tostring(job.file.url), upper_bound = "" })
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
