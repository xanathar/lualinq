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

