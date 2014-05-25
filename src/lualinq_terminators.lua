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















