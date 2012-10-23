
require "locomotive/objects/room"

game.room = {}
game.room.current = game.object("Room"):new()

local cache = {}

function game.room.event(name, ...)
    
end

function game.room.new(name)
    cache[name] = game.object("Room"):create()
end

function game.room.goto(name)
    game.room.current = cache[name]
end