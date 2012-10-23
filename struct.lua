
local struct = require "lib.love-struct"

game.struct = {}
function game.struct.grid() return struct.grid:new() end
function game.struct.stack() return struct.stack:new() end
function game.struct.queue() return struct.queue:new() end