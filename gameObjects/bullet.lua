local Class = require 'libraries/class'
local Particle = require 'gameObjects/particle'

local Bullet = Class {
  hitbox = {
    x = 0,
    y = 0,
    width = 10,
    height = 10
  }
}

function Bullet:init (room, x, y, direction)

  self.room = room
  self.x = x
  self.y = y
  self.direction = direction
  self.speed = 400
  self.velocity = {
    x = self.speed * direction,
    y = 0
  }

end

function Bullet:update (dt)

  self.x = self.x + self.velocity.x * dt
  self.y = self.y + self.velocity.y * dt
  self.room.bumpWorld:update(self, self.x, self.y)

  local colliders = self.room.bumpWorld:queryRect(self.x, self.y, self.hitbox.width, self.hitbox.height)
  for i = 1, #colliders do
    if colliders[i].mortal then
      colliders[i]:kill()
      -- Particles
      for j = 1, 10 do
        local vx = self.velocity.x / math.abs(self.velocity.x) * (math.random() * 100 + 50)
        local vy = math.random() * -25
        local particle = Particle(self.room, colliders[i].x + colliders[i].hitbox.width / 2,
          colliders[i].y + colliders[i].hitbox.height / 2, 2, 2, vx, vy, Colors.Auburn, 1)
        self.room:addObject(particle)
      end
    end
  end
  if #colliders > 1 then
    self.dead = true
  end

end

function Bullet:draw ()

  love.graphics.draw(Images.bullet, self.x, self.y)

end

return Bullet