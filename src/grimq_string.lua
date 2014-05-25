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

