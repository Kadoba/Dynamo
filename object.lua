--==================================================================================================
-- Simple Object System
--==================================================================================================
local cache = {}				-- The class cache
local iterating = false			-- The class that SOS.iterate() is running on
local iterateCount = 0			-- Number of times iterated
local unnamed = 0				-- Total unnamed objects
local createQueue = {size=0}	-- Objects created during iteration are queued
local deleteQueue = {size=0}	-- Objects deleted during iteration are queued

--==================================================================================================
-- Base object
--==================================================================================================
local Object = {}
Object.__index = Object
Object._types = {Object=true}
Object._name = "Object"
Object._parents = {}
Object._children = {}
Object._instances = {}
Object._count = 0
Object._iterateCount = -1
Object._class = Object
cache["Object"] = Object

----------------------------------------------------------------------------------------------------
-- Creates an instance of an object
local classData
function Object:create(...)
	local obj = setmetatable({}, self)
	if iterating and self:typeOf(iterating) then
		createQueue.size = createQueue.size + 1
		createQueue[createQueue.size] = obj
	else
		self._instances[obj] = true
	end
	self._count = self._count + 1
	obj._alive = true
	if obj.onCreate then obj:onCreate(...) end
	return obj
end

----------------------------------------------------------------------------------------------------
-- Destroy an instance
function Object:destroy(...)
	if iterating and self:typeOf(iterating) then
		deleteQueue.size = deleteQueue.size + 1
		deleteQueue[deleteQueue.size] = self
	else
		self._instances[self] = nil
	end
	self._class._count = self._class._count - 1
	self._alive = false
	if self.onDestroy then self:onDestroy(...) end
end

----------------------------------------------------------------------------------------------------
-- Create a subclass of this object
function Object:subclass(className, ...)
	return SOS.new(className, self, ...)
end

----------------------------------------------------------------------------------------------------
-- Iterate over all instances
function Object:iterate(excludeChildren)
	return SOS.iterate(self._name, excludeChildren)
end

----------------------------------------------------------------------------------------------------
-- Tests to see if the object is of a certain type
function Object:typeOf(classType)
	return self._types[classType]
end

----------------------------------------------------------------------------------------------------
-- Returns the class name of an object
function Object:getClassName()
	return self._name
end

----------------------------------------------------------------------------------------------------
-- Returns true if the object has not been deleted
function Object:isAlive()
	return self._alive
end

----------------------------------------------------------------------------------------------------
-- Calls a function on an object's parents
local parent
function Object:super(funct, ...)
	for i = 1,#self._parents do 
		parent = self._parents[i]
		if parent[funct] then parent[funct](parent, ...) end
	end
end


--==================================================================================================
-- The interface
--==================================================================================================

local SOS = {}

----------------------------------------------------------------------------------------------------
-- Create a new class.
local tmp, obj, parents, parent
function SOS.new(className, ...)
	if not className then 
		unnamed = unnamed + 1
		className = "UnnamedObject" .. unnamed
	end
	className = tostring(className)
	if cache[className] then 
		error( "SOS.new() - A class named " .. className .. " already exists." ) 
	end
	obj = {}
	obj.__index = obj
	obj._name = className
	obj._parents = {}
	obj._children = {}
	obj._instances = {}
	obj._types = {[className]=true}
	obj._count = 0
	obj._iterateCount = -1
	obj._class = obj
	cache[className] = obj
	parents = {...}
	if #parents <= 0 then parents[1] = Object end
	for i = 1, #parents do
		parent = cache[parents[i]] or parents[i]
		for k, v in pairs(parent) do
			if not obj[k] then obj[k] = v end
		end
		for classType, _ in pairs(parent._types) do 
			obj._types[classType] = true
		end
		tmp = cache[className]._parents
		tmp[#tmp+1] = parent
		tmp = cache[parent._name]._children
		tmp[#tmp+1] = obj

	end
	return setmetatable(obj, self)
end

----------------------------------------------------------------------------------------------------
-- Iterate over all all instances of a certain type. Order is undefined. 
local c, returnValue
function SOS.iterate(class, excludeChildren)
	class = class or "Object"
	if type(class) ~= "string" then class = class._name end
	if iterating then error("SOS.iterate() - Can't perform nested iteration") end
	iterating = class
	iterateCount = iterateCount + 1
	c = cache[class]			-- class iterator
	c._i = next(c._instances)	-- instance iterator
	c._c = 1					-- children iterator
	c._up = nil					-- return parent
	return function()
		while true do
			if c._instances[c._i] and c._iterateCount ~= iterateCount then 
				returnValue = c._i
				c._i = next(c._instances, c._i)
				return returnValue
			end
			c._iterateCount = iterateCount
			if c._children[c._c] and not excludeChildren then
				c._children[c._c]._up = c
				c = c._children[c._c]
				c._up._c = c._up._c + 1
				c._i = next(c._instances)
				c._c = 1
			elseif c._up then
				c = c._up
			else
				if createQueue.size > 0 then
					for i = 1, createQueue.size do
						createQueue[i]._instances[createQueue[i]] = true
					end
					createQueue.size = 0
				end
				if deleteQueue.size > 0 then
					for i = 1, deleteQueue.size do
						deleteQueue[i]._instances[deleteQueue[i]] = nil
					end
					deleteQueue.size = 0
				end
				break
			end
		end
		iterating = false
		return nil
	end
end

----------------------------------------------------------------------------------------------------
-- Returns a defined class
function SOS.get(className)
	return cache[className]
end
SOS.__call = SOS.get
setmetatable(SOS, SOS)


--==================================================================================================
-- Debugging tools (Some of these are slow)
--==================================================================================================

----------------------------------------------------------------------------------------------------
-- Returns the children of a certain class
function SOS.children(class)
	class = cache[class] or class
	return { unpack(class.children) }
end

----------------------------------------------------------------------------------------------------
-- Returns the parents of a certain class
function SOS.parents(class)
	class = cache[class] or class
	return { unpack(class.parents) }
end

----------------------------------------------------------------------------------------------------
-- Returns all of the ancestors of a certain class
function SOS.ancestors(class)
	class = cache[class] or class
	local ancestors = {}
	for className,_ in pairs(class._types) do
		if className ~= class._name then
			ancestors[ #ancestors+1 ] = cache[className]
		end
	end
	return ancestors
end

----------------------------------------------------------------------------------------------------
-- Counts the number of a certain object, including children.
function SOS.count(obj)
	obj = obj or "Object"
	if type(obj) == "table" then obj = obj._name end
	local count = 0
	for _, classData in pairs(cache) do
		if classData._types[obj] then
			count = count + classData.count
		end
	end
	return count
end

----------------------------------------------------------------------------------------------------
-- Returns a string representing the class structure and object count
local encountered, count
function SOS.info()
	count = {}
	encountered = {}
	for _, class in pairs(cache) do
		for name, _ in pairs(class._types) do
			if not count[name] then count[name] = 0 end
			count[name] = count[name] + class._count
		end
	end
	return "Class (Instances:Children) \n" .. structure(cache.Object, "")
end

function structure(obj, indent)
	indent = indent .. ">"
	local txt = string.format("%s %s (%s:%s)\n", indent, obj._name, "%d", "%d")
	txt = string.format(txt, obj._count,  count[obj._name] - obj._count)
	local previous = {}
	for k,child in pairs(obj._children) do
		if not encountered[child] then
			encountered[child] = true
			txt = txt .. structure(child, indent)
		else
			child = child._name
			previous[ #previous+1 ] = string.format("%s(%d)", child, count[child])
		end
	end
	if #previous > 0 then
		txt = txt .. string.format("%s> MIXED: %s\n", indent, table.concat(previous, ", "))
	end
	return txt
end

----------------------------------------------------------------------------------------------------
return SOS