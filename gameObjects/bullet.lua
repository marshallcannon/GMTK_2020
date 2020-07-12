local Class = require 'libraries/class'

local Bullet = Class {
  hitbox = {
    x = 0,
    y = 0,
    width = 10,
    height = 10
  }
}

function Bullet:init (scene, x, y, direction)

  self.scene = scene
  self.x = x
  self.y = y
  self.direction = direction
  self.speed = 200
  self.velocity = {
    x = self.speed * direction,
    y = 0
  }

end

function Bullet:update (dt)

  self.x = self.x + self.velocity.x * dt
  self.y = self.y + self.velocity.y * dt
  self.scene.bumpWorld:update(self, self.x, self.y)

  local colliders = self.scene.bumpWorld:queryRect(self.x, self.y, self.hitbox.width, self.hitbox.height)
  for i = 1, #colliders do
    if colliders[i].mortal then
      colliders[i].dead = true
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