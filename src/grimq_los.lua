VISIBLE = 2
BLOCKED = 1
NOTVISIBLE = 0

function lineOfSightStraight(level, sx, sy, dx, dy, facing)
	if (sx ~= dx and dy ~= sy) then return false; end
	
	local x1 = math.min(sx, dx)
	local x2 = math.max(sx, dx)
	local y1 = math.min(sy, dy)
	local y2 = math.max(sy, dy)
	
	local facing
	
	for x=_x1, _x2 do
		for y = _y1, _y2 do
			if (isWall(level, x, y)) then return false; end
			local doors = grimq.from(entitiesAt(level, x, y)):where(grimq.isDoor)):toIterator()
			
			for d in doors do
				
			end
		end
	end
	
	return true
end






