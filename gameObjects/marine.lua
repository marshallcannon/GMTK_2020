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

  self.scene = scene
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
  self.directionFacing = 'left'
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
  local actualX, actualY, collisions = self.scene.bumpWorld:move(self, goalX, goalY)
  self.x = actualX
  self.y = actualY

  -- Ground detection
  local itemsBelow = self.scene.bumpWorld:queryRect(self.x, self.y + self.hitbox.height, self.hitbox.width, 1)
  if #itemsBelow > 0 then
    if not self.onGround then
      self:hitGround()
    end
  else
    self.onGround = false
  end

  -- Ceiling detection
  local itemsAbove = self.scene.bumpWorld:queryRect(self.x, self.y - 3, self.hitbox.width, 3)
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
  local x, y, w, h = self.scene.bumpWorld:getRect(self)
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

  local bullet = Bullet(self.scene, x, y, direction)
  self.scene:addObject(bullet)

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

return Marine