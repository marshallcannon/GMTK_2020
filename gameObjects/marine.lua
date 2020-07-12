local Class = require 'libraries/class'
local Bullet = require 'gameObjects/bullet'

local Marine = Class {
  hitbox = {
    x = 10,
    y = 6,
    width = 12,
    height = 23
  }
}

function Marine:init (room, x, y)

  self.room = room
  self.x = x
  self.y = y
  self.velocity = {
    x = 0,
    y = 0
  }

  self.onGround = false
  self.gravity = 800
  self.jumpPower = 400
  self.acceleration = 900
  self.friction = 600
  self.airMultiplier = 0.5
  self.maxSpeed = 120
  self.directionFacing = 'right'
  self.bullets = 3

end

function Marine:update (dt)

  -- Gravity
  if not self.onGround then
    self.velocity.y = self.velocity.y + self.gravity * dt
  end

  -- Friction
  if self.onGround then
    if self.velocity.x > 0 then
      self.velocity.x = self.velocity.x - self.friction * dt
    elseif self.velocity.x < 0 then
      self.velocity.x = self.velocity.x + self.friction * dt
    end
  end

  -- Cap movement speed
  if math.abs(self.velocity.x) > self.maxSpeed then
    if self.velocity.x > 0 then self.velocity.x = self.maxSpeed end
    if self.velocity.x < 0 then self.velocity.x = -self.maxSpeed end
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
    if collisions[i].other.hostile then
      self.dead = true
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

  love.graphics.setColor(1, 1, 1)
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
  -- local x, y, w, h = self.room.bumpWorld:getRect(self)
  -- love.graphics.setColor(1, 1, 1)
  -- love.graphics.setLineWidth(1)
  -- love.graphics.rectangle('line', x, y, w, h)

  -- love.graphics.setColor(0, 1, 0)
  -- love.graphics.rectangle('line', self.x - self.hitbox.x, self.y - self.hitbox.y, Images.marine:getWidth(), Images.marine:getHeight())

end

function Marine:jump ()

  if self.onGround then
    self.velocity.y = -self.jumpPower
  end

end

function Marine:shoot ()

  local x, direction
  if self.directionFacing == 'left' then
    x = self.x - Bullet.hitbox.width - 5
    direction = -1
  elseif self.directionFacing == 'right' then
    x = self.x + self.hitbox.width + 5
    direction = 1
  end
  local y = self.y + self.hitbox.height / 2 - Bullet.hitbox.height

  local bullet = Bullet(self.room, x, y, direction)
  self.room:addObject(bullet, false)

  self.bullets = self.bullets - 1

end

function Marine:moveLeft (dt)

  local acceleration
  if self.onGround then
    acceleration = self.acceleration * dt
  else
    acceleration = self.acceleration * self.airMultiplier * dt
  end
  self.velocity.x = self.velocity.x - acceleration
  self.directionFacing = 'left'

end

function Marine:moveRight (dt)

  local acceleration
  if self.onGround then
    acceleration = self.acceleration * dt
  else
    acceleration = self.acceleration * self.airMultiplier * dt
  end
  self.velocity.x = self.velocity.x + acceleration
  self.directionFacing = 'right'

end

function Marine:stopMoving ()

  -- self.velocity.x = 0

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
  elseif other.collectible or other.hostile then
    return 'cross'
  end

end

function Marine.shouldCollideQuery (item)

  return item.solid

end

function Marine:grabBattery (battery)

  battery:kill()
  self.room:checkRunOver()

end

return Marine