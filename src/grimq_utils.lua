-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- saves an item into the table
function saveItem(item, slot)
   local itemTable = { }
   itemTable.id = item.id
   itemTable.name = item.name
   itemTable.stackSize = item:getStackSize()
   itemTable.fuel = item:getFuel()
   itemTable.charges = item:getCharges()
   itemTable.scrollText = item:getScrollText()
   itemTable.scrollImage = item:getScrollImage()
   itemTable.slot = slot
   
	for j = 1, CONTAINERITEM_MAXSLOTS do
		if (item:getItem(j) ~= nil) then
			if (itemTable.subItems == nil) then itemTable.subItems = {}; end
			table.insert(itemTable.subItems, saveItem(item:getItem(j), j))
		end
	end
   
   return itemTable
end

-- loads an item from the table
function loadItem(itemTable, level, x, y, facing, id, restoresubids)
	if (tonumber(id) ~= nil) then
		id = nil
	end

   local spitem = nil
   if (level ~= nil) then
	  spitem = spawn(itemTable.name, level, x, y, facing, id)
   else
	  spitem = spawn(itemTable.name, nil, nil, nil, nil, id)
   end
   if itemTable.stackSize > 0 then
	  spitem:setStackSize(itemTable.stackSize)
   end
   if itemTable.charges > 0 then
	  spitem:setCharges(itemTable.charges)
   end            
   
   if itemTable.scrollText ~= nil then
	  spitem:setScrollText(itemTable.scrollText)
   end
      
   if itemTable.scrollImage ~= nil then
	  spitem:setScrollImage(itemTable.scrollImage)
   end
   
   spitem:setFuel(itemTable.fuel)
   
   if (itemTable.subItems ~= nil) then
	  for _, subTable in pairs(itemTable.subItems) do
		 local subid = nil
		 if (restoresubids) then
			subid = subTable.id
		 end
	  
		 local subItem = loadItem(subTable, nil, nil, nil, nil, subid, restoresubids)
		 if (subTable.slot ~= nil) then
			spitem:insertItem(subTable.slot, subItem)
		 else
			spitem:addItem(subItem)
		 end
	  end
   end
   
   return spitem
end

-- Creates a copy of an item
function copyItem(item)
	return loadItem(saveItem(item))
end

-- Moves an item, preserving id
function moveItem(item, level, x, y, facing)
	local saved = saveItem(item)
	destroy(item)
	return loadItem(saved, level, x, y, facing, saved.id, true)
end

-- Moves an item, preserving id, faster version if we know the item is in the world
function moveItemFromFloor(item, level, x, y, facing)
	local saved = saveItem(item)
	item:destroy()
	return loadItem(saved, level, x, y, facing, saved.id, true)
end

-- Moves an item to a container/alcove
-- New 1.4: preserves ids
function moveFromFloorToContainer(alcove, item)
	alcove:addItem(moveItemFromFloor(item))
end

-- New 1.4: preserves ids
function moveItemsFromTileToAlcove(alcove)
	from(entitiesAt(alcove.level, alcove.x, alcove.y))
		:where(isItem)
		:foreach(function(i) 
			moveFromFloorToContainer(alcove, i)
		end)
end

g_ToorumMode = nil
function isToorumMode()
	if (g_ToorumMode == nil) then
		local rangerDetected = fromChampions():where(function(c) return (c:getClass() == "Ranger"); end):count()
		local zombieDetected = fromChampions():where(function(c) return ((not c:getEnabled()) and (c:getStatMax("health") == 0)); end):count()

		g_ToorumMode = (rangerDetected >= 1) and (zombieDetected == 3)
	end
	
	return g_ToorumMode
end

function dezombifyParty()
	local portraits = { "human_female_01", "human_female_02", "human_male_01", "human_male_02" }
	local genders = { "female", "female", "male", "male" }
	local names = { "Sylyna", "Yennica", "Contar", "Sancsaron" }

	for c in fromChampions():where(function(c) return ((not c:getEnabled()) and (c:getStatMax("health") == 0)); end):toIterator() do
		c:setStatMax("health", 25)
		c:setStatMax("energy", 10)
		c:setPortrait("assets/textures/portraits/" .. portraits[i] .. ".tga")
		c:setName(names[i])
		c:setSex(genders[i])
	end
end


function reverseFacing(facing)
	return (facing + 2) % 4;
end


function getChampionFromOrdinal(ord)
	return grimq.fromChampions():where(function(c) return c:getOrdinal() == ord; end):first()
end

function setLogLevel(level)
	LOG_LEVEL = level
end

-- 1.3
function directionFromPos(fromx, fromy, tox, toy)
	local dx = tox - fromx
	local dy = toy - fromy
	return directionFromDelta(dx, dy)
end

function directionFromDelta(dx, dy)
	if (dx > dy) then dy = 0; else dx = 0; end

	if (dy < 0) then return 0; 
	elseif (dx > 0) then return 1;
	elseif (dy > 0) then return 2;
	else return 3; end
end

function find(id, ignoreCornerCases)
	local entity = findEntity(id)
	if (entity ~= nil) then	return entity; end
	
	entity = fromPartyInventory(true, inventory.all, true):where("id", id):first()
	if (entity ~= nil) then	return entity; end
	
	if (not ignoreCornerCases) then
		local containers = fromAllEntitiesInWorld(isItem)
					:selectMany(function(i) return from(i:containedItems()):toArray(); end)
		
		entity = containers
			:where(function(ii) return ii.id == id; end)
			:first()
	
		if (entity ~= nil) then	return entity; end
		
		entity = containers
			:selectMany(function(i) return from(i:containedItems()):toArray(); end)
			:where(function(ii) return ii.id == id; end)
			:first()
	end
		
	return entity
end

function getEx(entity)
	-- entity isn't in world, try inventory
	local itemInInv = fromPartyInventoryEx(true, inventory.all, true)
		:where(function(i) return i.entity == entity; end)		
		:first()
		
	if (itemInInv ~= nil) then
		return itemInInv
	end
	
	-- inventory failed, we try alcoves and containers
	-- if we don't have an entity level, we in an obscure "item in sack in alcove" scenario
	if (entity.level == nil) then
		local topcontainers = fromAllEntitiesInWorld(isContainerOrAlcove)
		
		local container = topcontainers
						:where(function(a) return from(a:containedItems()):where(function(ii) return ii == entity; end):any(); end)
						:first()
						
		if (container ~= nil) then
			local itemInInv = fromContainerItemEx(container)
				:where(function(i) return i.entity == entity; end)		
				:first()					
				
			return itemInInv
		end
		
		container = topcontainers
						:selectMany(function(i) return from(i:containedItems()):toArray(); end)
						:where(function(a) return from(a:containedItems()):where(function(ii) return ii == entity; end):any(); end)
						:first()
						
		if (container ~= nil) then
			local itemInInv = fromContainerItemEx(container)
				:where(function(i) return i.entity == entity; end)		
				:first()					
				
			return itemInInv
		else
			logw("findAndCallback can't find item " .. entity.id)
			return
		end
	end
	
	-- we are in classic alcove or container scenario here
	local alcoveOrContainer = from(entitiesAt(entity.level, entity.x, entity.y))
		:where(isContainerOrAlcove)
		:where(function(a) return from(a:containedItems()):where(function(ii) return ii == entity; end):any(); end)
		:first()
		
	if (alcoveOrContainer ~= nil) then
		if (isAlcoveOrAltar(alcoveOrContainer)) then
			return _createExtEntity(-1, entity, nil, nil, false, -1, alcoveOrContainer, nil)
		else
			local itemInInv = fromContainerItemEx(alcoveOrContainer)
				:where(function(i) return i.entity == entity; end)		
				:first()					
				
			return itemInInv		
		end
	end
	
	-- the simplest case sadly happens last
	local wentity = findEntity(entity.id)
	
	if (wentity ~= nil) then	
		return _createExtEntity(-1, entity, nil, nil, false, -1, nil, true)
	end
	
	logw("findAndCallback can't find entity " .. entityid)
end

function gameover()
	damageTile(party.level, party.x, party.y, party.facing, 64, "physical", 100000000)
end

function findEx(entityid)
	local entity = find(entityid)
	
	if (entity == nil) then 
		return nil
	end
	
	return getEx(entity)
end

function replace(entity, entityToSpawn, desiredId)
	local ex = getEx(entity)
	
	if (ex ~= nil) then
		ex:replace(entityToSpawn, desiredId)
	end
end

function destroy(entity)
	local ex = getEx(entity)
	
	if (ex ~= nil) then
		ex:destroy()
	end
end

function partyGainExp(amount)
	grimq.fromAliveChampions():foreach(function(c) c:gainExp(amount); end)
end


function shuffleCoords(l, x, y, f, max)
	local m = 17 * l + 5 * x + 13 * y - 7 * f
	return (m % max) + 1
end

function randomReplacer(name, listOfReplace)
	for o in fromAllEntitiesInWorld("name", name) do
		local newname = listOfReplace[math.random(1, #listOfReplace)]
		
		if (newname ~= "") then
			spawn(newname, o.level, o.x, o.y, o.facing)
		end
		o:destroy()
	end
end

function decorateWalls(level, listOfDecorations, useRandomNumbers)
	for x = -1, 32 do
		for y = -1, 32 do
			if (x < 0 or x > 31 or y < 0 or y > 31 or isWall(level, x, y)) then
				for f = 0, 3 do
					local dx, dy = getForward(f)
					if (not isWall(level, x + dx, y + dy)) then
						local rf = (f + 2) % 4
						local hasdeco = grimq.from(entitiesAt(level, x + dx, y + dy)):where(function(o)
							return ((o.facing == rf) or (string.find(o.name, "stairs") ~= nil)) and (not grimq.isItem(o)) and (not grimq.isMonster(o)) end):any()
						
						if (not hasdeco) then
							local index = 1
							
							if (useRandomNumbers) then
								index = math.random(1, #listOfDecorations)
							else
								index = shuffleCoords(level, x + dx, y + dy, rf, #listOfDecorations)
							end
							
							local newname = listOfDecorations[index]
							if (newname ~= "") then
								if (type(newname) == "table") then
									for _, w in ipairs(newname) do
										spawn(w, level, x+dx, y+dy, rf)
									end
								else
									spawn(newname, level, x+dx, y+dy, rf)
								end
							end
						end
					end
				end
			end
		end
	end
end


function decorateOver(level, nameOverWhich, listOfDecorations, useRandomNumbers)
	grimq.fromAllEntities(level):where("name", nameOverWhich):foreach(function(o)
		local index = 1
		
		if (useRandomNumbers) then
			index = math.random(1, #listOfDecorations)
		else
			index = shuffleCoords(level, o.x, o.y, o.facing, #listOfDecorations)
		end
		
		local newname = listOfDecorations[index]
		if (newname ~= "") then
			if (type(newname) == "table") then
				for _, w in ipairs(newname) do
					spawn(w, level, o.x, o.y, o.facing)
				end
			else
				spawn(newname, level, o.x, o.y, o.facing)
			end
		end
	end)
end

function partyDist(x, y)
	return math.abs(party.x - x) + math.abs(party.y - y)
end


function spawnSmart(level, spawners, spawnedEntityNames, maxEntities, minDistance)
	minDistance = minDistance or 7;
	
	local count = grimq.fromAllEntities(level)
		:where(grimq.isMonster)
		:intersectionby("name", spawnedEntityNames)
		:count();

	if count >= maxEntities then
		return 0;
	end
	
	local spawner = spawners[math.random(1, #spawners)]
	
	local dist = partyDist(spawner.x, spawner.y)
	
	if dist < minDistance then
		return 0;
	end
	
	spawner:activate()
	return 1;
end	
	
function replaceMonster(m, newname)
	local x = m.x
	local y = m.y
	local f = m.facing
	local l = m.level
	local id = m.id
	local hp = m:getHealth()
	local lvl = m:getLevel()
	
	if (tonumber(id) ~= nil) then
		id = nil
	end
	
	if (hp > 0) then
		m:destroy()
		spawn(newname, l, x, y, f, id)
			:setLevel(lvl)
			:setHealth(hp)
	end
end

function spawnOver(entity, spawnname, overridefacing)
	local facing = overridefacing or entity.facing;
	
	spawn(spawnname, entity.level, entity.x, entity.y, facing);
end




	
	
	
	
	
	
	
	
	
	