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

