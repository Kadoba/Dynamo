local imageCache = setmetatable({}, {__mode = "v"})
local quadCache = setmetatable({}, {__mode = "v"})

local image, iw, ih, index

----------------------------------------------------------------------------------------------------
-- Caches and returns a quad
function game.quad(x, y, w, h, iw, ih)
	-- Get a unique index by combining all of the parameters
	index = string.format("%d:%d:%d:%d:%d:%d", x, y, w, h, iw, ih)
	-- If the quad is not created yet then cache it
	if not quadCache[index] then 
		quadCache[index] = love.graphics.newQuad(x, y, w, h, iw, ih)
	end
	-- Return the quad
	return quadCache[index]
end

----------------------------------------------------------------------------------------------------
-- Caches and returns an image and quad if specified.
function game.image(path, x, y, w, h)
	-- If path is not a string then it is considered to already be an image
	if type(path) ~= "string" then 
		image = path
	else
		-- If path is a string but not in the image cache then cache it
		if not imageCache[path] then
			imageCache[path] = love.graphics.newImage(path)
		end
		image = imageCache[path]
	end
	-- If a quad is specified then return the image and quad
	if x then
		iw, ih = image:getWidth(), image:getHeight()
		return image, game.quad(x, y, w, h, iw, ih)
	-- Otherwise just return the image
	else
		return image
	end
end