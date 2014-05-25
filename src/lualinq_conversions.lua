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




