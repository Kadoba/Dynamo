
local Sprite = game.object.new("Sprite")
local anim, frame

----------------------------------------------------------------------------------------------------
-- Creation script
function Sprite:onCreate(master, image)
    self.master = master
    self.image = image
    self.animations = {}
    self.animation = "default"
    self.frame = 1
    self.offsetX = 0
    self.offsetY = 0
    self.time = 0
    self.direction = 1
    self.mode = "loop"
    self.active = true
    self.callbacks = {}
end

----------------------------------------------------------------------------------------------------
-- Sets a specific animation. If a frame is not specified then the old one is kept
function Sprite:setAnimation(name, frame)
    self.animation = name
    if not frame then
        if frame > #self.animations[self.animation] then
            frame =  #self.animations[self.animation]
        elseif frame < 1 then 
            frame = 1
        end
    else
        self.frame = frame
        self.time = 0
    end
end

----------------------------------------------------------------------------------------------------
-- Update the sprite animation
function Sprite:update(dt)
    if not self.active then return end
    self.time = self.time + dt
    anim = self.animations[self.animation]
    while self.time > anim[self.frame].delay then
        self.time = self.time - anim[self.frame].delay
        self.frame = self.frame + self.direction
        if self.frame < 1 or self.frame > #anim then
            self.frame = self.frame < 1 and 1 or #anim
            for i = 1,#self.callbacks do
                self.callbacks[i][2](self.callbacks[i][1], self, self.master)
            end
            if self.mode == "once" then
                self.active = false
            elseif self.mode == "loop" then
                self.frame = self.frame == 1 and #anim or 1
            elseif self.mode == "bounce" then
                self.direction = self.direction * -1
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- Adds a frame to the end of the current animation
function Sprite:addFrame(d,x,y,w,h,rot,sx,sy,ox,oy)
    if not self.animation[self.animation] then self.animations[self.animation] = {} end
    anim = self.animation[self.animation]
    anim[#anim+1] = {q=game.quad(self.image,x,y,w,h),delay=d,rot=rot,sx=sx,sy=sy,ox=ox,oy=oy}
end

----------------------------------------------------------------------------------------------------
-- Adds a callback. Callbacks are fired when any animation ends.
function Sprite:addCallback(obj, funct)
    self.callbacks[#self.callbacks + 1] = {obj, funct}
end

----------------------------------------------------------------------------------------------------
-- Draws a sprite
function Sprite:draw(x,y)
    frame = self.animations[self.animation][self.frame]
    love.graphics.drawq(self.image, frame.q, frame.x, frame.y, frame.rot, frame.sx, frame.sy, 
                        frame.ox + self.offsetX, frame.oy + self.offsetY)
end


