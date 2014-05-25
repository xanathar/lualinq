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

fw_addModule('grimq',[===[

---------------------------------------------------------------------------
-- CONFIGURATION OPTIONS                                                 --
---------------------------------------------------------------------------

-- change this if you don't want all secrets to be "auto"
AUTO_ALL_SECRETS = true

-- how much log information is printed: 3 => verbose, 2 => info, 1 => only warning and errors, 0 => only errors, -1 => silent
LOG_LEVEL = 0

-- prefix for the printed logs
LOG_PREFIX = "GrimQ: "

-- set this to false when the allEntities bug gets fixed for faster iterations
PATCH_ALLENTITIES_BUG = true


---------------------------------------------------------------------------
-- IMPLEMENTATION BELOW, DO NOT CHANGE
---------------------------------------------------------------------------

VERSION_SUFFIX = ""
MAXLEVEL = 1
CONTAINERITEM_MAXSLOTS = 10
