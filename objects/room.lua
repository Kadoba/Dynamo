require "locomotive/object"
require "locomotive/screen"

local Room = game.object.new("Room")
local deleted = {drawOrder = math.huge}

----------------------------------------------------------------------------------------------------
-- Create the room
function Room:onCreate()
	self.camera = object("Camera"):create()
    self.view = {
        x = 0, 
        y = 0, 
        width = game.screen.width, 
        height = game.screen.height, 
    }
    self.sequence = {}
    self.sequence.left = 1
    self.sequence.right = 0
    self.sequence.halt = nil
	self.objects = {}
	self.objects.dirty = true
	self.objects.size = 0
end

----------------------------------------------------------------------------------------------------
-- Adds an object to the room. Calls onEnter()
function Room:addObject(obj, ...)
	obj.room = self
	self.objects.size = self.objects.size+1
	self.objects[self.objects.size] = obj
	self.objects.dirty = true
    if obj.onEnter then obj:onEnter(...) end
    return obj
end

----------------------------------------------------------------------------------------------------
-- Remove an object and return it. Calls onExit() and adds a new sequence object if nessisary.
function Room:removeObject(obj, ...)
	for i = 1,#self.objects do
		if self.objects[i] == obj then
			self.objects[i] = removed
            break
		end
	end
	self.objects.dirty = true
    if obj.onExit then obj:onExit(...) end
    if obj == self.sequence.halt then
        if self.sequence.left <= self.sequence.right then
            local newObj = self.sequence[self.sequence.left]
            newObj = game.object(newObj[1]).create(unpack(newObj))
            self.sequence.halt = newObj
            self:addObject(newObj, ...)
            self.sequence[self.sequence.left] = nil
            self.sequence.left = self.sequence.left - 1
        else
            self.sequence.halt = nil
        end
    end
    return obj
end

----------------------------------------------------------------------------------------------------
-- Adds an object through sequence
function Room:addSequence(obj, ...)
    if not self.sequence.halt then 
        self.sequence.halt = obj
        self:addObject(game.object(obj):create(...))
    else
        self.sequence.right = self.sequence.right + 1
        self.sequence[self.sequence.right] = {obj, ...}
    end
end

----------------------------------------------------------------------------------------------------
-- Forward a callback. Sort the objects if needed.
function Room:callback(cb, ...)
    if objs.dirty then self:sortObjects() end
    if cb == "onDraw" then 
        love.graphics.push()
        love.graphics.translate(-self.view.x, -self.view.y)
    end
	for obj,_ in pairs(self.objects) do
		if obj[cb] then obj[cb](obj, ...) end
	end
end

----------------------------------------------------------------------------------------------------
-- Sort function for objects
local function objSort(a, b)
	return a.order < b.order
end

----------------------------------------------------------------------------------------------------
-- Sort the objects. Done automatically.
local objs
function Room:sortObjects()
	objs = self.objects
	table.sort(objs, drawSort)
	while objs[objs.size].order == math.huge then
		objs[objs.size] = nil
		objs.size = objs.size - 1
	end
end