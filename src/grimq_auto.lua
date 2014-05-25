-- ============================================================
-- AUTO-OBJECTS
-- ============================================================


function _activateAutos()
	-- cache is toorum mode result, so that we remember being toorum after party is manipulated
	local toorummode = isToorumMode()
	logv("Toorum mode: ".. tostring(toorummode))
	
	logv("Starting auto-secrets... (AUTO_ALL_SECRETS is " .. tostring(AUTO_ALL_SECRETS) .. ")")
	if (AUTO_ALL_SECRETS) then
		fromAllEntitiesInWorld("name", "secret"):foreach(_initializeAutoSecret)
	else
		fromAllEntitiesInWorld(match("id", "^auto_secret")):foreach(_initializeAutoSecret)
	end

	logv("Starting auto-printers...")
	fromAllEntitiesInWorld("name", "auto_printer"):foreach(_initializeAutoHudPrinter)

	logv("Starting auto-torches...")
	fromAllEntitiesInWorld(isTorchHolder):where(match("name", "^auto_")):foreach(function(auto) if (not auto:hasTorch()) then auto:addTorch(); end; end)

	logv("Starting auto-alcoves...")
	fromAllEntitiesInWorld(isAlcoveOrAltar):where(match("name", "^auto_")):foreach(moveItemsFromTileToAlcove)

	logv("Starting autoexec scripts...")
	fromAllEntitiesInWorld(isScript):foreach(_initializeAutoScript)
	
	logi("Started.")
end

function _initializeAutoSecret(auto)
	local plate = spawn("pressure_plate_hidden", auto.level, auto.x, auto.y, auto.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(true)
		:addConnector("activate", auto.id, "activate")
end

function _initializeAutoHudPrinter(auto)
	local plate = spawn("pressure_plate_hidden", auto.level, auto.x, auto.y, auto.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(true)
		:addConnector("activate", "grimq", "execHudPrinter")

	g_HudPrinters[plate.id]	= auto:getScrollText()
	auto:destroy()
end

g_HudPrinters = { }

g_HudPrintFunction = nil

function setFunctionForHudPrint(fn)
	g_HudPrintFunction = fn
end

function printHud(text)
	if (g_HudPrintFunction == nil) then
		hudPrint(strformat(text))
	else
		g_HudPrintFunction(strformat(text))
	end
end

function execHudPrinter(source)
	logv("Executing hudprinter " .. source.id)
	local text = g_HudPrinters[source.id]
	
	if (text ~= nil) then
		printHud(text)
	else
		logw("Auto-hud-printer not found in hudprinters list: " .. source.id)
	end
end

-- NEW
function _initializeAutoScript(ntt)
	if (ntt.autoexec ~= nil) then
		logv("Executing autoexec of " .. ntt.id .. "...)")
		ntt:autoexec();
	end
	
	if (ntt.auto_onStep ~= nil) then
		logv("Install auto_onStep hook for " .. ntt.id .. "...)")
		spawn("pressure_plate_hidden", ntt.level, ntt.x, ntt.y, ntt.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(false)
		:addConnector("activate", ntt.id, "auto_onStep")
	end

	if (ntt.auto_onStepOnce ~= nil) then
		logv("Install auto_onStepOnce hook for " .. ntt.id .. "...)")
		spawn("pressure_plate_hidden", ntt.level, ntt.x, ntt.y, ntt.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(true)
		:addConnector("activate", ntt.id, "auto_onStepOnce")
	end
end
	
function _initializeAutoHooks(ntt)
	if (ntt.autoexecfw ~= nil) then
		logv("Executing autoexecfw of " .. ntt.id .. "...)")
		ntt:autoexecfw();
	end
	
	local autohook = ntt.autohook;
	
	if (autohook == nil) then
		autohook = ntt.autohooks;
	end

	if (autohook ~= nil) then
		if (fw == nil) then
			loge("_initializeAutoHooks called with nil fw ???.")
			return
		end

		for hooktable in from(autohook):toIterator() do
			local target = hooktable.key
			local hooks = from(hooktable.value)
			
			for hook in hooks:toIterator() do
				local hookname = hook.key
				local hookfn = hook.value
				
				if (type(hookfn) == "function") then
					logi("Adding *DEPRECATED* hook for: ".. ntt.id .. "." .. hookname .. " for target " .. target .. " ...")
					fw.addHooks(target, ntt.id .. "_" .. target .. "_" .. hookname, { [hookname] = hook.value } )
					logw("Hook: ".. ntt.id .. "." .. hookname .. " for target " .. target .. " is a function -- *DEPRECATED* use.")
				elseif (type(hookfn) == "string") then
					_installAutoHook(ntt, hookname, target, {fn = hookfn});
				elseif (type(hookfn) == "table") then
					_installAutoHook(ntt, hookname, target, hookfn);
				else
					loge("Hook: ".. ntt.id .. "." .. hookname .. " for target " .. target .. " is an unsupported type. Must be string or table.")
				end
			end
		end
	end
end

function _installAutoHook(ntt, hookname, target, hooktable)
	local hookId = ntt.id .. "_" .. target .. "_" .. hookname;

	logi("Adding hook for: ".. ntt.id .. "." .. hookname .. " for target " .. target .. " ...")
	
	if (hooktable.vars == nil) then
		hooktable.vars = { };
	end

	hooktable.vars._hook_entity = ntt.id;
	hooktable.vars._hook_method = hooktable.fn;
	
	fw.setHookVars(target, hookId, hookname, hooktable.vars)
	
	fw.addHooks(target, hookId, 
		{ 
			[hookname] = function(p1, p2, p3, p4, p5, p6, p7, p8, p9)
				local vars = fw.getHookVars();
				local ntt = findEntity(vars._hook_entity);

				if (ntt == nil) then
					loge("Can't find entity ".. vars._hook_entity);
				else
					return ntt[vars._hook_method](p1, p2, p3, p4, p5, p6, p7, p8, p9);
				end
			end,
		}
		, hooktable.ordinal 
	);
end



function _activateJKosFw()
	fromAllEntitiesInWorld(isScript):foreach(_initializeAutoHooks)
end




