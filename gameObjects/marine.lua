local Class = require 'libraries/class'
local Bullet = require 'gameObjects/bullet'
local Particle = require 'gameObjects/particle'

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

  self.onGround = true
  self.gravity = 800
  self.jumpPower = 400
  self.acceleration = 900
  self.friction = 600
  self.airMultiplier = 0.5
  self.maxSpeed = 120
  self.directionFacing = 'right'
  self.bullets = 3

  -- Programmatic animations
  self.vCompress = 1
  self.hCompress = 1

  self.bulletOpacity = 0

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
      Sounds.death:play()
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
  love.graphics.draw(Images.marine, self.x - self.hitbox.x, self.y - self.hitbox.y, 0, scaleX * self.hCompress,
    self.vCompress, offsetX, -(Images.marine:getHeight() - Images.marine:getHeight() * self.vCompress))

  love.graphics.setColor(1, 1, 1, self.bulletOpacity)
  love.graphics.setLineWidth(1)
  for i = 1, 3 do
    local style
    if i > self.bullets then style = 'line'
    else style = 'fill' end
    local x = self.x + (self.hitbox.width / 2) + ((i - 2) * 12)
    love.graphics.circle(style, x, self.y - 10, 4)
  end

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
    Sounds.jump:play()

    -- Animation
    self.vCompress = 0.8
    self.hCompress = 1.2
    Timer.tween(0.15, self, { vCompress = 1.2, hCompress = 0.8 }, 'linear', function ()
      Timer.tween(0.25, self, {vCompress = 1, hCompress = 1 }, 'linear')
    end)

    -- Particles
    for i = 1, 10 do
      local vx = math.random() * 40 - 20
      local vy = math.random() * -25
      local particle = Particle(self.room, self.x + self.hitbox.width / 2, self.y + self.hitbox.height - 5, 2, 2, vx, vy, Colors.Shadow, 0.5)
      self.room:addObject(particle)
    end

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
  self.room:addObject(bullet)

  self.bullets = self.bullets - 1
  self.bulletOpacity = 1
  Timer.tween(0.5, self, { bulletOpacity = 0 })
  Sounds.shoot:play()

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

  -- Animation
  Timer.tween(0.05, self, { vCompress = 0.9, hCompress = 1.1 }, 'linear', function ()
    Timer.tween(0.05, self, { vCompress = 1, hCompress = 1 })
  end)

  -- Particles
  for i = 1, 10 do
    local vx = math.random() * 40 - 20
    local vy = math.random() * -25
    local particle = Particle(self.room, self.x + self.hitbox.width / 2, self.y + self.hitbox.height - 5, 2, 2, vx, vy, Colors.Shadow, 0.5)
    self.room:addObject(particle)
  end

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
  Sounds.grab:play()

end

return Marine