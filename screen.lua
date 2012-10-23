game.screen = {}
game.screen.width = 800
game.screen.height = 600
game.screen.appWidth = 800
game.screen.appHeight = 600
game.screen.ratio = game.screen.width / game.screen.height
game.screen.offsetX = 0
game.screen.offsetY = 0
game.screen.scale = 1
game.screen.fullscreen = false
game.screen.vsync = tre
game.screen.fsaa = 4

game.screen.canvasSupported = love.graphics.isSupported("canvas")
game.screen.shaderSupported = love.graphics.isSupported("pixeleffect")

----------------------------------------------------------------------------------------------------
-- Applies all of the screen settings
function game.screen.apply()
    local width, height = game.screen.width, game.screen.height
	local lowestDimension = width/height < game.screen.ratio and "width" or "height"
	local newWidth, newHeight
	if lowestDimension == "width" then
		newWidth = width
		newHeight = math.floor(newWidth / game.screen.ratio + 0.5)
		game.screen.scale = newWidth / game.screen.width
		game.screen.offsetY = (height - newHeight)/2
	else
		newHeight = height
		newWidth = math.floor(newHeight * game.screen.ratio + 0.5)
		game.screen.scale = newHeight / game.screen.height
		game.screen.offsetX = (width - newWidth)/2
	end
	game.screen.appWidth = width
	game.screen.appHeight = height
	local fullscreen, vsync, fsaa = game.screen.fullscreen, game.screen.vsync, game.screen.fsaa
	love.graphics.setMode(width, height, fullscreen, vsync, fsaa)
end