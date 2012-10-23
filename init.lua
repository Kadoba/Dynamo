-- game/init.lua
-- Loads all of the files in the game folder
do
game = {}
local path = ({...})[1]:gsub("%.init", "")
local filename
for k,v in ipairs( love.filesystem.enumerate(path) ) do
	filename = path .. '.' .. v:gsub("%.lua", "")
	if v ~= "init.lua" then require(filename) end
end
end
