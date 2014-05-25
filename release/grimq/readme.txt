ChangeLog
=========
05-May-2013: Version 1.5
	o GrimQ: Now GrimQ *NEEDS* jkos framework around to work (as such old bootstrap code has been removed)
	o GrimQ: fromFwSet(listname, sublistname) returns a collection with one of fw sets of names
	o GrimQ: loadItem fixed when restoring old ids (but really, don't rely on items ids. please)
	o GrimQ: addded spawnSmart to implement smart spawner sets
	o GrimQ: added partyDist utility function
	o GrimQ: fixed a bug where inventory functions printed information on the console
	o GrimQ: fixed a bug where inventory functions ignored inventory slots information
	o GrimQ: fromAllEntitiesInWorld now supports extra syntax like lualinq where (see below)
	o LuaLinq: toTuple() converts a lua linq structure to a tuple
	o LuaLinq: added exceptby and intersectionby methods
	o LuaLinq: added dump to debug data interactively
	o LuaLinq: added some shortcuts for foreach and other methods with longish names
	o LuaLinq: fromSet creates a structure from a set (table where only the key matters)
	o LuaLinq: where can take multiple possible reference values, or parameters which will be passed to the predicate
	o LuaLinq: foreach now accepts a string to call a method of the object itself. Also, in both modes (string or function) it 
				accepts extra parameters which will be relayed to the method/function


25-Mar-2013: Version 1.4
	o GrimQ: NEW: moveItem and moveItemFromFloor to automagically move an item around
	o GrimQ: NEW: partyGainExp(amount) function
	o GrimQ: NEW: shuffleCoords(..) to generate "almost-random" numbers from a set of coordinates
	o GrimQ: NEW: randomReplacer to replace all instances of an object with another chosen at random
	o GrimQ: NEW: decorateWalls and decorateOver to automatically insert decorations in dungeons
	o GrimQ: NEW: auto_onStep and auto_onStepOnce autos in scripting entities
	o GrimQ: automatic patch for allEntities bug in game engine (defaults at true) - thanks MarbleMouth!
	o GrimQ: loadItem support restoring ids of items in containers
	o GrimQ: fromAllEntitiesInWorld supports a where predicate in the function itself for optimizations
	o GrimQ: autoprinters support overriding the function to use as hudPrint
	o GrimQ: version check *SHOULD* work now. Or not, who knows ?
	o GrimQ: fromAliveChampions() fixed
	o GrimQ: fromEntitiesForward(),fromEntitiesInArea() and fromEntitiesAround() TONS of bugs fixed
	o GrimQ: moveFromFloorToContainer and moveItemsFromTileToAlcove now preserve ids
	o GrimQ: optimizations in find and getEx



23-Jan-2013: Version 1.3.2
	o GrimQ: Fixed (hopefully) all corner cases
	o GrimQ: Extended items generalized to extended entities
	o GrimQ: findEx(id) – equivalent of findEntity, but works also for items in inventory or mouse cursor and returns an extended entity instead
	o GrimQ: getEx(entity) – returns the extended entity from an entity
	o GrimQ: fromContainerItemEx - returns a grimq structure filled with extended entities of the contents of a container


23-Jan-2013: Version 1.3 / 1.3.1
	o GrimQ: Now requires LoG 1.3.6 or later
	o GrimQ: Simplified setup - no need to set MAXLEVEL any longer
	o GrimQ: Fixed issues on destroy and replace methods for inventory management
	o GrimQ: loadItem and copyItem now preserve scroll images and container slots
	o GrimQ: loadItem now allows an id to be passed 
	o GrimQ: setLogLevel to dynamically change the log level at runtime
	o GrimQ: directionFromPos(fromx, fromy, tox, toy) - returns a facing value given starting and end positions
	o GrimQ: directionFromDelta(dx, dy) - returns a direction given the differences in x and y (the opposite of getForward)
	o GrimQ: destroy(entity) - can be called on any item and most entities and automatically destroys the entity in the best way, without concerns about where the entity is or what the entity is
	o GrimQ: replace(entity, entityToSpawn, desiredId) - can be called on any item and most entities and automatically replace the entity with another in the best way, without concerns about where the entity is or what the entity is
	o GrimQ: find(id) - equivalent of findEntity, but works also for items in inventory or mouse cursor
	o GrimQ: gameover() - kills the party (equivalent to destroy(party))
	o GrimQ: isContainerOrAlcove(entity) - returns true if entity is either a container or an alcove/altar




04-Dec-2012: Version 1.2
	o LuaLinq: "from" detects a Lualinq structure and inteprets it correctly
	o LuaLinq: all methods taking a second LuaLinq now can take anything you can feed a "from" method with
	o LuaLinq: "select" method accepts a property name instead of a selector function
	o LuaLinq: "where" method accepts a property name and a value instead of a predicate
	o LuaLinq: private methods are prefixed with an underscore
	o GrimQ: new: reverseFacing, getChampionFromOrdinal, strformat, string methods
	o GrimQ: added *optional* integrations with JKos framework hooks
	o GrimQ: added AUTO_ALL_SECRETS options to shortcut all secrets to be auto


27-Nov-2012: Version 1.1
	o Includes: distinct, union, except, intersection
	o GrimQ: includeMouse on fromPartyInventory
	o GrimQ: new: fromPartyInventoryEx, fromChampionInventoryEx, fromEntitiesInArea, fromEntitiesAround, fromEntitiesForward, 
			copyItem, moveFromFloorToContainer, moveItemsFromTileToAlcove, fromEntitiesInWorld
	o GrimQ: support for "auto" items - scripting entities containing an autoexec() method, autosecrets, etc.

21-Nov-2012: Version 1.01 
	o Changed all methods to be immutable and return new objects
	  instead of changing the original one.


20-Nov-2012: Version 1.0


