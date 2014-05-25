-- ------------------------------------------------------------------------
-- This project is developed by Marco Mastropaolo (Xanathar) 
-- as a personal project and is in no way affiliated with Almost Human.
-- You can use this scripts in any Legend of Grimrock dungeon you want; 
-- credits are appreciated though not necessary.
-- ------------------------------------------------------------------------
-- If you want to use this code in a Lua project outside Grimrock, 
-- please refer to the files and license included 
-- at http://code.google.com/p/lualinq/
-- ------------------------------------------------------------------------

---------------------------------------------------------------------------
-- CONFIGURATION OPTIONS                                                 --
---------------------------------------------------------------------------

-- change this if you don't want all secrets to be "auto"
AUTO_ALL_SECRETS = true

-- how much log information is printed: 3 => verbose, 2 => info, 1 => only warning and errors, 0 => only errors, -1 => silent
LOG_LEVEL = 2

-- prefix for the printed logs
LOG_PREFIX = "GrimQ: "

-- set this to false when the allEntities bug gets fixed for faster iterations
PATCH_ALLENTITIES_BUG = true

---------------------------------------------------------------------------
-- IMPLEMENTATION BELOW, DO NOT CHANGE
---------------------------------------------------------------------------

VERSION_SUFFIX = ".DEBUG"
MAXLEVEL = 1
CONTAINERITEM_MAXSLOTS = 10
















-- ============================================================
-- DEBUG TRACER
-- ============================================================

LIB_VERSION_TEXT = "1.5.1"
LIB_VERSION = 151

function setLogLevel(level)
	LOG_LEVEL = level;
end

function _log(level, prefix, text)
	if (level <= LOG_LEVEL) then
		print(prefix .. LOG_PREFIX .. text)
	end
end

function logq(self, method)
	if (LOG_LEVEL >= 3) then
		logv("after " .. method .. " => " .. #self.m_Data .. " items : " .. _dumpData(self))
	end
end

function _dumpData(self)
	local items = #self.m_Data
	local dumpdata = "q{ "
	
	for i = 1, 3 do
		if (i <= items) then
			if (i ~= 1) then
				dumpdata = dumpdata .. ", "
			end
			dumpdata = dumpdata .. tostring(self.m_Data[i])
		end
	end
	
	if (items > 3) then
		dumpdata = dumpdata .. ", ..." .. items .. " }"
	else
		dumpdata = dumpdata .. " }"
	end

	return dumpdata
end



function logv(txt)
	_log(3, "[..] ", txt)
end

function logi(txt)
	_log(2, "[ii] ", txt)
end

function logw(txt)
	_log(1, "[W?] ", txt)
end

function loge(txt)
	_log(0, "[E!] ", txt)
end


-- ============================================================
-- CONSTRUCTOR
-- ============================================================

-- [private] Creates a linq data structure from an array without copying the data for efficiency
function _new_lualinq(method, collection)
	local self = { }
	
	self.classid_71cd970f_a742_4316_938d_1998df001335 = 2
	
	self.m_Data = collection
	
	self.concat = _concat
	self.select = _select
	self.selectMany = _selectMany
	self.where = _where
	self.whereIndex = _whereIndex
	self.take = _take
	self.skip = _skip
	self.zip = _zip
	
	self.distinct = _distinct 
	self.union = _union
	self.except = _except
	self.intersection = _intersection
	self.exceptby = _exceptby
	self.intersectionby = _intersectionby
	self.exceptBy = _exceptby
	self.intersectionBy = _intersectionby

	self.first = _first
	self.last = _last
	self.min = _min
	self.max = _max
	self.random = _random

	self.any = _any
	self.all = _all
	self.contains = _contains

	self.count = _count
	self.sum = _sum
	self.average = _average

	self.dump = _dump
	
	self.map = _map
	self.foreach = _foreach
	self.xmap = _xmap

	self.toArray = _toArray
	self.toDictionary = _toDictionary
	self.toIterator = _toIterator
	self.toTuple = _toTuple

	-- shortcuts
	self.each = _foreach
	self.intersect = _intersection
	self.intersectby = _intersectionby
	self.intersectBy = _intersectionby
	
	
	logq(self, "from")

	return self
end
-- ============================================================
-- GENERATORS
-- ============================================================

-- Tries to autodetect input type and uses the appropriate from method
function from(auto)
	if (auto == nil) then
		return fromNothing()
	elseif (type(auto) == "function") then
		return fromIterator(auto)
	elseif (type(auto) == "table") then
		if (auto["classid_71cd970f_a742_4316_938d_1998df001335"] ~= nil) then
			return auto
		elseif (auto[1] == nil) then
			return fromDictionary(auto)
		elseif (type(auto[1]) == "function") then
			return fromIteratorsArray(auto)
		else
			return fromArrayInstance(auto)
		end
	end
	return fromNothing()
end

-- Creates a linq data structure from an array without copying the data for efficiency
function fromArrayInstance(collection)
	return _new_lualinq("fromArrayInstance", collection)
end

-- Creates a linq data structure from an array copying the data first (so that changes in the original
-- table do not reflect here)
function fromArray(array)
	local collection = { }
	for k,v in ipairs(array) do
		table.insert(collection, v)
	end
	return _new_lualinq("fromArray", collection)
end

-- Creates a linq data structure from a dictionary (table with non-consecutive-integer keys)
function fromDictionary(dictionary)
	local collection = { }
	
	for k,v in pairs(dictionary) do
		local kvp = {}
		kvp.key = k
		kvp.value = v
		
		table.insert(collection, kvp)
	end
	
	return _new_lualinq("fromDictionary", collection)
end

-- Creates a linq data structure from an iterator returning single items
function fromIterator(iterator)
	local collection = { }
	
	for s in iterator do
		table.insert(collection, s)
	end
	
	return _new_lualinq("fromIterator", collection)
end

-- Creates a linq data structure from an array of iterators each returning single items
function fromIteratorsArray(iteratorArray)
	local collection = { }

	for _, iterator in ipairs(iteratorArray) do
		for s in iterator do
			table.insert(collection, s)
		end
	end
	
	return _new_lualinq("fromIteratorsArray", collection)
end

-- Creates a linq data structure from a table of keys, values ignored
function fromSet(set)
	local collection = { }

	for k,v in pairs(set) do
		table.insert(collection, k)
	end
	
	return _new_lualinq("fromIteratorsArray", collection)
end


-- Creates an empty linq data structure
function fromNothing()
	return _new_lualinq("fromNothing", { } )
end

-- ============================================================
-- QUERY METHODS
-- ============================================================

-- Concatenates two collections together
function _concat(self, otherlinq)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		table.insert(result, value)
	end
	for idx, value in ipairs(otherlinq.m_Data) do
		table.insert(result, value)
	end
	
	return _new_lualinq(":concat", result)
end

-- Replaces items with those returned by the selector function or properties with name selector
function _select(self, selector)
	local result = { }

	if (type(selector) == "function") then
		for idx, value in ipairs(self.m_Data) do
			local newvalue = selector(value)
			if (newvalue ~= nil) then
				table.insert(result, newvalue)
			end
		end
	elseif (type(selector) == "string") then
		for idx, value in ipairs(self.m_Data) do
			local newvalue = value[selector]
			if (newvalue ~= nil) then
				table.insert(result, newvalue)
			end
		end
	else
		loge("select called with unknown predicate type");
	end	
	return _new_lualinq(":select", result)
end


-- Replaces items with those contained in arrays returned by the selector function
function _selectMany(self, selector)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		local newvalue = selector(value)
		if (newvalue ~= nil) then
			for ii, vv in ipairs(newvalue) do
				if (vv ~= nil) then
					table.insert(result, vv)
				end
			end
		end
	end
	
	return _new_lualinq(":selectMany", result)
end


-- Returns a linq data structure where only items for whose the predicate has returned true are included
function _where(self, predicate, refvalue, ...)
	local result = { }

	if (type(predicate) == "function") then
		for idx, value in ipairs(self.m_Data) do
			if (predicate(value, refvalue, from({...}):toTuple())) then
				table.insert(result, value)
			end
		end	
	elseif (type(predicate) == "string") then
		local refvals = {...}
		
		if (#refvals > 0) then
			table.insert(refvals, refvalue);
			return _intersectionby(self, predicate, refvals);
		elseif (refvalue ~= nil) then
			for idx, value in ipairs(self.m_Data) do
				if (value[predicate] == refvalue) then
					table.insert(result, value)
				end
			end	
		else
			for idx, value in ipairs(self.m_Data) do
				if (value[predicate] ~= nil) then
					table.insert(result, value)
				end
			end	
		end
	else
		loge("where called with unknown predicate type");
	end
	
	return _new_lualinq(":where", result)
end




-- Returns a linq data structure where only items for whose the predicate has returned true are included, indexed version
function _whereIndex(self, predicate)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		if (predicate(idx, value)) then
			table.insert(result, value)
		end
	end	
	
	return _new_lualinq(":whereIndex", result)
end

-- Return a linq data structure with at most the first howmany elements
function _take(self, howmany)
	return self:whereIndex(function(i, v) return i <= howmany; end)
end

-- Return a linq data structure skipping the first howmany elements
function _skip(self, howmany)
	return self:whereIndex(function(i, v) return i > howmany; end)
end

-- Zips two collections together, using the specified join function
function _zip(self, otherlinq, joiner)
	otherlinq = from(otherlinq) 

	local thismax = #self.m_Data
	local thatmax = #otherlinq.m_Data
	local result = {}
	
	if (thatmax < thismax) then thismax = thatmax; end
	
	for i = 1, thismax do
		result[i] = joiner(self.m_Data[i], otherlinq.m_Data[i]);
	end
	
	return _new_lualinq(":zip", result)
end

-- Returns only distinct items, using an optional comparator
function _distinct(self, comparator)
	local result = {}
	
	for idx, value in ipairs(self.m_Data) do
		local found = false

		for _, value2 in ipairs(result) do
			if (comparator == nil) then
				if (value == value2) then found = true; end
			else
				if (comparator(value, value2)) then found = true; end
			end			
		end
	
		if (not found) then
			table.insert(result, value)
		end
	end
	
	return _new_lualinq(":distinct", result)
end

-- Returns the union of two collections, using an optional comparator
function _union(self, other, comparator)
	return self:concat(from(other)):distinct(comparator)
end

-- Returns the difference of two collections, using an optional comparator
function _except(self, other, comparator)
	other = from(other)
	return self:where(function (v) return not other:contains(v, comparator) end)
end

-- Returns the intersection of two collections, using an optional comparator
function _intersection(self, other, comparator)
	other = from(other)
	return self:where(function (v) return other:contains(v, comparator) end)
end

-- Returns the difference of two collections, using a property accessor
function _exceptby(self, property, other)
	other = from(other)
	return self:where(function (v) return not other:contains(v[property]) end)
end

-- Returns the intersection of two collections, using a property accessor
function _intersectionby(self, property, other)
	other = from(other)
	return self:where(function (v) return other:contains(v[property]) end)
end

-- ============================================================
-- CONVERSION METHODS
-- ============================================================

-- Converts the collection to an array
function _toIterator(self)
	local i = 0
	local n = #self.m_Data
	return function ()
			i = i + 1
			if i <= n then return self.m_Data[i] end
		end
end

-- Converts the collection to an array
function _toArray(self)
	return self.m_Data
end

-- Converts the collection to a table using a selector functions which returns key and value for each item
function _toDictionary(self, keyValueSelector)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		local key, value = keyValueSelector(value)
		if (key ~= nil) then
			result[key] = value
		end
	end
	
	return result
end

-- Converts the lualinq struct to a tuple
function _toTuple(self)
	return unpack(self.m_Data)
end




-- ============================================================
-- TERMINATING METHODS
-- ============================================================

-- Return the first item or default if no items in the colelction
function _first(self, default)
	if (#self.m_Data > 0) then
		return self.m_Data[1]
	else
		return default
	end
end

-- Return the last item or default if no items in the colelction
function _last(self, default)
	if (#self.m_Data > 0) then
		return self.m_Data[#self.m_Data]
	else
		return default
	end
end

-- Returns true if any item satisfies the predicate. If predicate is null, it returns true if the collection has at least one item.
function _any(self, predicate)
	if (predicate == nil) then return #self.m_Data > 0; end

	for idx, value in ipairs(self.m_Data) do
		if (predicate(value)) then
			return true
		end
	end
	
	return false
end

-- Returns true if all items satisfy the predicate. If predicate is null, it returns true if the collection is empty.
function _all(self, predicate)
	if (predicate == nil) then return #self.m_Data == 0; end

	for idx, value in ipairs(self.m_Data) do
		if (not predicate(value)) then
			return false
		end
	end
	
	return true
end

-- Returns the number of items satisfying the predicate. If predicate is null, it returns the number of items in the collection.
function _count(self, predicate)
	if (predicate == nil) then return #self.m_Data; end

	local result = 0

	for idx, value in ipairs(self.m_Data) do
		if (predicate(value)) then
			result = result + 1
		end
	end
	
	return false
end


-- Prints debug data.
function _dump(self)
	print(_dumpData(self));
end

-- Returns a random item in the collection, or default if no items are present
function _random(self, default)
	if (#self.m_Data == 0) then return default; end
	return self.m_Data[math.random(1, #self.m_Data)]
end

-- Returns true if the collection contains the specified item
function _contains(self, item, comparator)
	for idx, value in ipairs(self.m_Data) do
		if (comparator == nil) then
			if (value == item) then return true; end
		else
			if (comparator(value, item)) then return true; end
		end
	end
	return false
end


-- Calls the action for each item in the collection. Action takes 1 parameter: the item value.
-- If the action is a string, it calls that method with the additional parameters
function _foreach(self, action, ...)
	if (type(action) == "function") then
		for idx, value in ipairs(self.m_Data) do
			action(value, from({...}):toTuple())
		end
	elseif (type(action) == "string") then
		for idx, value in ipairs(self.m_Data) do
			value[action](value, from({...}):toTuple())
		end
	else
		loge("foreach called with unknown action type");
	end

	
	return self
end

-- Calls the accumulator for each item in the collection. Accumulator takes 2 parameters: value and the previous result of 
-- the accumulator itself (firstvalue for the first call) and returns a new result.
function _map(self, accumulator, firstvalue)
	local result = firstvalue

	for idx, value in ipairs(self.m_Data) do
		result = accumulator(value, result)
	end
	
	return result
end

-- Calls the accumulator for each item in the collection. Accumulator takes 3 parameters: value, the previous result of 
-- the accumulator itself (nil on first call) and the previous associated-result of the accumulator(firstvalue for the first call) 
-- and returns a new result and a new associated-result.
function _xmap(self, accumulator, firstvalue)
	local result = nil
	local lastval = firstvalue

	for idx, value in ipairs(self.m_Data) do
		result, lastval = accumulator(value, result, lastval)
	end
	
	return result
end

-- Returns the max of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _max(self, selector)
 	if (selector == nil) then 
		selector = function(n) return n; end
	end
  	return self:xmap(function(v, r, l) local res = selector(v); if (l == nil or res > l) then return v, res; else return r, l; end; end, nil)
end

-- Returns the min of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _min(self, selector)
	if (selector == nil) then 
		selector = function(n) return n; end
	end
  	return self:xmap(function(v, r, l) local res = selector(v); if (l == nil or res < l) then return v, res; else return r, l; end; end, nil)
end

-- Returns the sum of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _sum(self, selector)
	if (selector == nil) then 
		selector = function(n) return n; end
	end
	return self:map(function(n, r) r = r + selector(n); return r; end, 0)
end

-- Returns the average of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _average(self, selector)
	local count = self:count()
	if (count > 0) then
		return self:sum(selector) / count
	else
		return 0
	end
end















-- ============================================================
-- ENUMERATIONS
-- ============================================================

-- Enumeration of all the inventory slots
inventory = 
{
	head = 1,
	torso = 2,
	legs = 3,
	feet = 4,
	cloak = 5,
	neck = 6,
	handl = 7,
	handr = 8,
	gauntlets = 9,
	bracers = 10,
	
	hands = { 7, 8 },
	backpack = { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },
	armor = { 1, 2, 3, 4, 5, 6, 9 },
	all = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },
}

-- Enumeration of all the direction/facing values
facing = 
{
	north = 0,
	east = 1,
	south = 2,
	west = 3
}

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




-- ============================================================
-- PREDICATES
-- ============================================================

function isMonster(entity)
	return entity.setAIState ~= nil
end

function isItem(entity)
	return entity.getWeight ~= nil
end

function isAlcoveOrAltar(entity)
	return entity.getItemCount ~= nil
end

function isContainerOrAlcove(entity)
	return entity.containedItems ~= nil
end

function isDoor(entity)
	return (entity.setDoorState ~= nil)
end

function isLever()
	return (entity.getLeverState ~= nil) 
end

function isLock(entity)
	return (entity.setOpenedBy ~= nil) and (entity.setDoorState == nil)
end

function isPit(entity)
	return (entity.setPitState ~= nil)
end

function isSpawner(entity)
	return (entity.setSpawnedEntity ~= nil)
end

function isScript(entity)
	return (entity.setSource ~= nil)
end

function isPressurePlate(entity)
	return (entity.isDown ~= nil)
end

function isTeleport(entity)
	return (entity.setChangeFacing ~= nil)
end

function isTimer(entity)
	return (entity.setTimerInterval ~= nil)
end

function isTorchHolder(entity)
	return (entity.hasTorch ~= nil)
end

function isWallText(entity)
	return (entity.getWallText ~= nil)
end

function match(attribute, namepattern)
	return function(entity) 
		return string.find(entity[attribute], namepattern) ~= nil
	end
end

function has(attribute, value)
	return function(entity) 
		return entity[attribute] == value
	end
end

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
		return;
	end
	
	local spawner = spawners[math.random(1, #spawners)]
	
	local dist = partyDist(spawner.x, spawner.y)
	
	if dist < minDistance then
		return;
	end
	
	spawner:activate()
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




	
	
	
	
	
	
	
	
	
	-- ============================================================
-- STRING FUNCTIONS
-- ============================================================


-- $1.. $9 -> replaces with func parameters
-- $champ1..$champ4 -> replaces with name of champion of slot x
-- $CHAMP1..$CHAMP4 -> replaces with name of champion in ordinal x
-- $rchamp -> random champion, any
-- $RCHAMP -> random champion, alive
function strformat(text, ...)
	local args = {...}
	
	for i, v in ipairs(args) do
		text = string.gsub(text, "$" .. i, tostring(v))
	end
	
	for i = 1, 4 do
		local c = party:getChampion(i)
		
		local name = c:getName()
		text = string.gsub(text, "$champ" .. i, name)
		
		local ord = c:getOrdinal()
		text = string.gsub(text, "$CHAMP" .. ord, name)
	end
	
	text = string.gsub(text, "$rchamp", fromChampions():select(function(c) return c:getName(); end):random())
	text = string.gsub(text, "$RCHAMP", fromAliveChampions():select(function(c) return c:getName(); end):random())
	
	return text
end


-- see http://lua-users.org/wiki/StringRecipes
function strstarts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- see http://lua-users.org/wiki/StringRecipes
function strends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function strmatch(value, pattern)
	return string.find(value, pattern) ~= nil
end

function strlines(str)
	local count = 0 
    local byte_char = string.byte("\n")
    for i = 1, #str do
        if string.byte(str, i) == byte_char then
            count = count + 1 
        end 
    end 
    return count + 1
end

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




-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================

function _banner()
	logi("GrimQ Version " .. LIB_VERSION_TEXT .. VERSION_SUFFIX .. " - Marco Mastropaolo (Xanathar)")
end

-- added by JKos -- note: as of v1.5 grimq *REQUIRES* jkos fw.
function activate()
	logi("Starting with jkos-fw bootstrap...")
	grimq._activateAutos()
	grimq._activateJKosFw()
end

_banner()

MAXLEVEL = getMaxLevels()

if (isWall == nil) then
	loge("This version of GrimQ requires Legend of Grimrock 1.3.6 or later!")
end


















