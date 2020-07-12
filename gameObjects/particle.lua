local Class = require 'libraries/class'

local Particle = Class {}

function Particle:init (room, x, y, width, height, vx, vy, color, duration)

  self.room = room
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.vx = vx
  self.vy = vy
  self.color = color
  self.duration = duration

  self.opacity = 1
  self.gravity = 100

  Timer.after(duration, function ()
    self.dead = true
  end)
  Timer.tween(duration, self, { opacity = 0 })

  self.hitbox = {x = 0, y = 0, width = self.width, height = self.height}

end

function Particle:update (dt)

  self.vy = self.vy + self.gravity * dt

  local goalX, goalY = self.x + self.vx * dt, self.y + self.vy * dt
  local actualX, actualY = self.room.bumpWorld:move(self, goalX, goalY, self.shouldCollide)
  self.x = actualX
  self.y = actualY

end

function Particle:draw ()

  love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.opacity)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

end

function Particle.shouldCollide (item, other)

  if other.solid then
    return 'bounce'
  end

end

return Particle