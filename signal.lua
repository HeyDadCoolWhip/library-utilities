--Original: https://raw.githubusercontent.com/Quenty/NevermoreEngine/23c4c96158a582b30f13d58ebb8b9f8139aca130/src/signal/src/Shared/signal.lua

local HttpService = game:GetService("HttpService")

local ENABLE_TRACEBACK = false

local signal = {}
signal.__index = signal
signal.ClassName = "signal"

function signal.issignal(value)
	return type(value) == "table" and getmetatable(value) == signal
end

function signal.new()
	local self = setmetatable({}, )

	self._bindableEvent = Instance.new("BindableEvent")
	self._argMap = {}
	self._source = ENABLE_TRACEBACK and debug.traceback() or ""

	self._bindableEvent.Event:Connect(function(key)
		self._argMap[key] = nil

		if (not self._bindableEvent) and (not next(self._argMap)) then
			self._argMap = nil
		end
	end)

	return self
end

function signal:Fire(...)
	if not self._bindableEvent then
		warn(("signal is already destroyed. %s"):format(self._source))
		return
	end

	local args = table.pack(...)
    local key = HttpService:GenerateGUID(false)

	self._argMap[key] = args
	self._bindableEvent:Fire(key)
end

function signal:Connect(handler)
	if not (type(handler) == "function") then
		error(("connect(%s)"):format(typeof(handler)), 2)
	end

	return self._bindableEvent.Event:Connect(function(key)
		local args = self._argMap[key]
		if args then
			handler(table.unpack(args, 1, args.n))
		else
			error("Missing arg data, probably due to reentrance.")
		end
	end)
end

function signal:Wait()
	local key = self._bindableEvent.Event:Wait()
	local args = self._argMap[key]
	if args then
		return table.unpack(args, 1, args.n)
	else
		error("Missing arg data, probably due to reentrance.")
		return nil
	end
end

function signal:Destroy()
	if self._bindableEvent then
		self._bindableEvent:Destroy()
		self._bindableEvent = nil
	end

	setmetatable(self, nil)
end

return signal
