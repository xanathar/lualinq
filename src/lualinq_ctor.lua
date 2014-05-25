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
