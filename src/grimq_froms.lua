-- ============================================================
-- LUALINQ GENERATORS
-- ============================================================

-- Returns a grimq structure filled with names of entities contained
-- in one of the fw sets.
function fromFwSet(listname, sublistname)
	local set = fw.lists[listname];
	
	if (set ~= nil) and (sublistname ~= nil) then
		set = set[sublistname];
	end
	
	return fromSet(set);
end



-- Returns a grimq structure containing all champions
function fromChampions()
	local collection = { }
	for i = 1, 4 do
		collection[i] = party:getChampion(i)
	end
	return fromArrayInstance(collection)
end

-- Returns a grimq structure containing all enabled and alive champions
function fromAliveChampions()
	local collection = { }
	for i = 1, 4 do
		local c = party:getChampion(i)
		if (c:isAlive() and c:getEnabled()) then
			table.insert(collection, c) -- fixed in 1.5
		end
	end
	return fromArrayInstance(collection)
end

-- Returns a grimq structure containing all the items in the champion's inventory
-- 		champion => the specified champion to which the inventory is returned
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromChampionInventory(champion, recurseIntoContainers, inventorySlots, includeMouse)
	return fromChampionInventoryEx(champion, recurseIntoContainers, inventorySlots, includeMouse)
		:select("entity")
end

-- Returns a grimq structure containing all the items in the party inventory
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromPartyInventory(recurseIntoContainers, inventorySlots, includeMouse)
	return fromChampions():selectMany(function(v) return fromChampionInventory(v, recurseIntoContainers, inventorySlots, includeMouse):toArray(); end)
end

-- [private] Creates an extended object
function _createExtEntity(_slotnumber, _entity, _champion, _container, _ismouse, _containerSlot, _alcove, _isworld)
	return {
		slot = _slotnumber,
		entity = _entity,
		item = _entity, -- this is for backward compatibilty only!!
		champion = _champion,
		container = _container,
		ismouse = _ismouse,
		containerSlot = _containerSlot,
		alcove = _alcove,
		isworld = _isworld,
		
		destroy = function(self)
			if (self.entity == party) then
				gameover()
			elseif (self.container ~= nil) then
				self.container:removeItem(self.slot)
			elseif (self.slot >= 0) then
				self.champion:removeItem(self.slot)
			elseif (self.ismouse) then
				setMouseItem(nil)
			else
				self.entity:destroy()
			end
		end,
				
		replaceCallback = function(self, constructor)
			local obj = nil
			if (self.entity == party) then
				gameover()
			elseif (self.container ~= nil) then
				self.container:removeItem(self.slot)
				obj = constructor()
				self.container:insertItem(self.slot, obj)
			elseif (self.slot >= 0) then
				self.champion:removeItem(self.slot)
				obj = constructor()
				self.champion:insertItem(self.slot, obj)
			elseif (self.ismouse) then
				setMouseItem(nil)
				obj = constructor()
				setMouseItem(obj)
			elseif (self.alcove ~= nil) then
				self.entity:destroy()
				obj = constructor()
				self.alcove:addItem(obj)
			elseif (self.isworld) then
				local l = self.entity.level
				local x = self.entity.x
				local y = self.entity.y
				local f = self.entity.facing
				self.entity:destroy()
				obj = constructor(l, x, y, f)
			else 
				logw("itemobject.replaceCallback fallback on incompatible default")
			end
			return obj
		end,
		
		replace = function(self, itemname, desiredid)
			return self:replaceCallback(function(l,x,y,f) return spawn(itemname, l, x, y, f, desiredid); end)
		end,
		
		debug = function(self)
			local obj = nil
			if (self.entity == party) then
				print("=> entity is party")
			elseif (self.container ~= nil) then
				print("=> entity is slot " .. self.slot .. " of cont " .. self.container.id)
			elseif (self.slot >= 0) then
				print("=> entity is slot " .. self.slot .. " of champion ord#" .. self.champion:getOrdinal())
			elseif (self.ismouse) then
				print("=> entity is on mouse")
			elseif (self.alcove ~= nil) then
				print("=> entity is in alcove " .. self.alcove.id)
			elseif (self.isworld) then
				local l = self.entity.level
				local x = self.entity.x
				local y = self.entity.y
				local f = self.entity.facing
				print("=> entity is in world at level=".. l, " pos = (" .. x .. "," .. y .. ") facing=" .. f)
			else 
				logw("itemobject.replaceCallback fallback on incompatible default")
			end
			return obj
		end,
		
	}
end

function _appendContainerItem(collection, item, champion, containerslot)
	--print("appending contents of container " .. item.id)
	for j = 1, CONTAINERITEM_MAXSLOTS do
		if (item:getItem(j) ~= nil) then
			--print("  appended " .. item:getItem(j).id)
			table.insert(collection, _createExtEntity(j, item:getItem(j), champion, item, false, containerslot))
			_appendContainerItem(collection, item:getItem(j), nil, j)
		end
	end
end

-- Returns a grimq structure containing item objects in the champion's inventory
-- 		champion => the specified champion to which the inventory is returned
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromChampionInventoryEx(champion, recurseIntoContainers, inventorySlots, includeMouse)
	if (inventorySlots == nil) then
		inventorySlots = inventory.all
	end

	local collection = { }
	for idx = 1, #inventorySlots do
		local i = inventorySlots[idx];
		local item = champion:getItem(i)
		
		if (item ~= nil) then
			table.insert(collection, _createExtEntity(i, item, champion, nil, false, -1))
			
			if (recurseIntoContainers) then
				_appendContainerItem(collection, item, champion, i)
			end
		end
	end
	
	if (includeMouse and (getMouseItem() ~= nil)) then
		local item = getMouseItem()
		table.insert(collection, _createExtEntity(-1, item, nil, nil, true, -1))
		
		if (recurseIntoContainers) then
			_appendContainerItem(collection, item, nil, -1)
		end
	end
	
	return fromArrayInstance(collection)
end

-- Returns a grimq structure filled with extended entities of the contents of a container
function fromContainerItemEx(item)
	local collection = { }
	_appendContainerItem(collection, item, nil, -1)
	return fromArrayInstance(collection)
end


-- Returns a grimq structure containing all the item-objects in the party inventory
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromPartyInventoryEx(recurseIntoContainers, inventorySlots, includeMouse)
	return fromChampions():selectMany(function(v) return fromChampionInventoryEx(v, recurseIntoContainers, inventorySlots, includeMouse):toArray(); end)
end

-- Returns a grimq structure cotaining all the entities in the dungeon respecting a given *optional* condition
function fromAllEntitiesInWorld(predicate, refvalue, ...)
	local result = { }

	if (predicate == nil) then
		for lvl = 1, MAXLEVEL do
			for value in fromAllEntities(lvl):toIterator() do
				table.insert(result, value)
			end
		end
	elseif (type(predicate) == "function") then
		for lvl = 1, MAXLEVEL do
			for value in fromAllEntities(lvl):toIterator() do
				if (predicate(value)) then
					table.insert(result, value)
				end				
			end
		end
	else 
		local refvals = {...}
		
		if (#refvals > 0) then
			local refset = { }
			for _, l in ipairs(refvals) do refset[l] = true; end
			refset[refvalue] = true;
		
			for lvl = 1, MAXLEVEL do
				for value in fromAllEntities(lvl):toIterator() do
					if (refset[value[predicate]]) then
						table.insert(result, value)
					end
				end
			end
		else
			for lvl = 1, MAXLEVEL do
				for value in fromAllEntities(lvl):toIterator() do
					if (value[predicate] == refvalue) then
						table.insert(result, value)
					end
				end
			end
		end
	end
	
	return fromArrayInstance(result)
end

-- Returns a grimq structure cotaining all the entities in an area
function fromEntitiesInArea(level, x1, y1, x2, y2, skipx, skipy)
	local itercoll = { }
	if (skipx == nil) then skipx = -10000; end
	if (skipy == nil) then skipy = -10000; end
	
	local stepx = 1
	if (x1 > x2) then stepx = -1; end

	local stepy = 1
	if (y1 > y2) then stepy = -1; end
	
	for x = x1, x2, stepx do
		for y = y1, y2, stepy do
			if (skipx ~= x) or (skipy ~= y) then
				table.insert(itercoll, entitiesAt(level, x, y))
			end
		end
	end
	
	return fromIteratorsArray(itercoll)
end

function fromEntitiesAround(level, x, y, radius, includecenter)
	if (radius == nil) then radius = 1; end
	
	if (includecenter == nil) or (not includecenter) then
		return fromEntitiesInArea(level, x - radius, y - radius, x + radius, y + radius, x, y)
	else
		return fromEntitiesInArea(level, x - radius, y - radius, x + radius, y + radius)
	end
end

function fromEntitiesForward(level, x, y, facing, distance, includeorigin)
	if (distance == nil) then distance = 1; end
	local dx, dy = getForward(facing)
	local dx = dx * distance
	local dy = dy * distance

	if (includeorigin == nil) or (not includeorigin) then
		return fromEntitiesInArea(level, x, y, x + dx, y + dy, x, y)
	else
		return fromEntitiesInArea(level, x, y, x + dx, y + dy, nil, nil)
	end
end

function fromAllEntities(level)
	if (PATCH_ALLENTITIES_BUG) then
		local result = { }
		for i=0,31 do
			for j=0,31 do
				for k in entitiesAt(level,i,j) do
					table.insert(result, k)
				end
			end
		end		
		return fromArrayInstance(result)
	else
		return grimq.from(allEntities(level))
	end
end




