--==================================================================================================
-- dynamo/util.lua
-- Defines common game math functions.
--==================================================================================================
local math = math

if not game then game = {} end
game.util = {}

----------------------------------------------------------------------------------------------------
-- limits a value to a range
function game.util.limit(minimum, maximum, value)
	value = value < (minimum or value) and minimum or value
	value = value > (maximum or value) and maximum or value
	return value
end

----------------------------------------------------------------------------------------------------
-- Rounds to the nearest whole number
function game.util.round(num)
	return math.floor(num + 0.5)
end

----------------------------------------------------------------------------------------------------
-- Returns the cardinal distance
function game.util.cardinalLen(x1, y1, x2, y2)
	return math.abs(x1-x2) + math.abs(y1-y2)
end

----------------------------------------------------------------------------------------------------
-- Returns the length of two points
function game.util.len(x1, y1, x2, y2)
	return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

----------------------------------------------------------------------------------------------------
-- Returns the squared length of two points
function game.util.len2(x1, y1, x2, y2 )
	return (x1-x2)^2 + (y1-y2)^2
end

----------------------------------------------------------------------------------------------------
-- Makes the start value approach the goal value without going over
function game.util.approach(start, goal, value)
    if math.abs(start - goal <= value) then 
        return goal
    else
        return start < goal and start + value or start - value
    end
end

----------------------------------------------------------------------------------------------------
-- Make the starting point approach the goal point without going over
local dir
function game.util.approach2(startX, startY, goalX, goalY, value)
    if game.util.len2(startX, startY, goalX, goalY) <= value^2 then return
        return goalX, goalY
    else
		dir = math.atan2(goalY - startY, goalX - goalY)
        return startX + math.cos(dir) * value, startY + math.sin(dir) * value
    end
end
