local Class = require 'libraries/class'
local Bullet = require 'gameObjects/bullet'

local Marine = Class {
  hitbox = {
    x = 9,
    y = 2,
    width = 14,
    height = 30
  }
}

function Marine:init (scene, x, y)

  self.room = scene
  self.x = x
  self.y = y
  self.velocity = {
    x = 0,
    y = 0
  }

  self.onGround = false
  self.gravity = 500
  self.jumpPower = 300
  self.speed = 80
  self.directionFacing = 'right'
  self.bullets = 3

end

function Marine:update (dt)

  -- Gravity
  if not self.onGround then
    self.velocity.y = self.velocity.y + self.gravity * dt
  end

  -- Movement
  local goalX = self.x + self.velocity.x * dt
  local goalY = self.y + self.velocity.y * dt
  local actualX, actualY, collisions = self.room.bumpWorld:move(self, goalX, goalY, self.shouldCollide)
  self.x = actualX
  self.y = actualY

  -- Check for collectibles
  for i = 1, #collisions do
    if collisions[i].other.name == 'battery' then
      self:grabBattery(collisions[i].other)
    end
  end

  -- Ground detection
  local itemsBelow = self.room.bumpWorld:queryRect(self.x, self.y + self.hitbox.height, self.hitbox.width, 1, self.shouldCollideQuery)
  if #itemsBelow > 0 then
    if not self.onGround then
      self:hitGround()
    end
  else
    self.onGround = false
  end

  -- Ceiling detection
  local itemsAbove = self.room.bumpWorld:queryRect(self.x, self.y - 3, self.hitbox.width, 3, self.shouldCollideQuery)
  if #itemsAbove > 0 then
    self:hitCeiling()
  end

end

function Marine:draw ()

  if self.onGround then
    love.graphics.setColor(1, 1, 1)
  else
    love.graphics.setColor(1, 0, 0)
  end
  local scaleX, offsetX
  if self.directionFacing == 'left' then
    scaleX = 1
    offsetX = 0
  elseif self.directionFacing == 'right' then
    scaleX = -1
    offsetX = 32
  end
  love.graphics.draw(Images.marine, self.x - self.hitbox.x, self.y - self.hitbox.y, 0, scaleX, 1, offsetX)

  -- Debugging
  local x, y, w, h = self.room.bumpWorld:getRect(self)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle('line', x, y, w, h)

end

function Marine:jump ()

  if self.onGround then
    self.velocity.y = -self.jumpPower
  end

end

function Marine:shoot ()

  local x, direction
  if self.directionFacing == 'left' then
    x = self.x - 25
    direction = -1
  elseif self.directionFacing == 'right' then
    x = self.x + self.hitbox.width + 5 + 15
    direction = 1
  end
  local y = self.y + self.hitbox.height / 2 - 10

  local bullet = Bullet(self.room, x, y, direction)
  self.room:addObject(bullet)

  self.bullets = self.bullets - 1

end

function Marine:moveLeft ()

  self.velocity.x = -self.speed
  self.directionFacing = 'left'

end

function Marine:moveRight ()

  self.velocity.x = self.speed
  self.directionFacing = 'right'

end

function Marine:stopMoving ()

  self.velocity.x = 0

end

function Marine:hitGround ()

  if self.velocity.y > 0 then
    self.velocity.y = 0
  end
  self.onGround = true

end

function Marine:hitCeiling ()

  if self.velocity.y < 0 then
    self.velocity.y = 0
  end

end

function Marine:canJump ()

  return self.onGround

end

function Marine:canShoot ()

  return self.bullets > 0

end

-- Collision filter function
function Marine.shouldCollide (item, other)

  if other.solid then
    return 'slide'
  elseif other.collectible then
    return 'cross'
  end

end

function Marine.shouldCollideQuery (item)

  return item.solid

end

function Marine:grabBattery (battery)

  battery.dead = true
  self.room:checkComplete()

end

return Marine