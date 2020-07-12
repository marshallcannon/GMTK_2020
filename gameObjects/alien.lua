local Class = require 'libraries/class'

local Alien = Class {
  hitbox = {
    x = 5, y = 3,
    width = 22,
    height = 29
  },
  solid = false,
  hostile = true,
  mortal = true,
  name = 'alien'
}

function Alien:init (room, x, y)

  self.room = room
  self.x = x
  self.y = y
  self.velocity = {
    x = 0,
    y = 0
  }
  
  self.gravity = 100
  self.acceleration = 200
  self.maxSpeed = 100
  self.onGround = true

  self.floatOffset = 0
  self:floatUp()

end

function Alien:update (dt)

  -- Gravity
  if not self.onGround then
    self.velocity.y = self.velocity.y + self.gravity * dt
  end

  -- Check line of sight
  local selfX, selfY = self.x + self.hitbox.width / 2, self.y + self.hitbox.height / 2
  local marine = self.room.marine
  local marineX, marineY = marine.x + marine.hitbox.width / 2, marine.y + marine.hitbox.height / 2
  local items = self.room.bumpWorld:querySegment(selfX, selfY, marineX, marineY, function (item) return item.blocksVision end)
  -- Can see player
  if #items == 0 then
    if selfX > marineX then
      self.velocity.x = self.velocity.x - self.acceleration * dt
    elseif selfX < marineX then
      self.velocity.x = self.velocity.x + self.acceleration * dt
    end
  end

  -- Cap speed
  if math.abs(self.velocity.x) > self.maxSpeed then
    if self.velocity.x > 0 then
      self.velocity.x = self.maxSpeed
    elseif self.velocity.x < 0 then
      self.velocity.x = -self.maxSpeed
    end
  end

  -- Ground detection
  local itemsBelow = self.room.bumpWorld:queryRect(self.x, self.y + self.hitbox.height, self.hitbox.width, 1, function (item) return item.solid end)
  if #itemsBelow > 0 then
    if not self.onGround then
      self:hitGround()
    end
  else
    self.onGround = false
  end

  -- Movement
  local goalX = self.x + self.velocity.x * dt
  local goalY = self.y + self.velocity.y * dt
  local actualX, actualY, items = self.room.bumpWorld:move(self, goalX, goalY, function (item, other)
    if other.solid or other.name == 'alien' then
      return 'slide'
    elseif other.name == 'spikesTop' or other.name == 'spikesBottom' then
      return 'cross'
    end
  end)
  self.x = actualX
  self.y = actualY

  for i = 1, #items do
    if items[i].other.name == 'spikesTop' or items[i].other.name == 'spikesBottom' then
      self:kill()
    end
  end

end

function Alien:draw ()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.alien, self.x - self.hitbox.x, self.y - self.hitbox.y, 0, 1, 1, 0, self.floatOffset)

end

function Alien:hitGround ()

  if self.velocity.y > 0 then
    self.velocity.y = 0
  end
  self.onGround = true

end

function Alien:kill ()

  Timer.cancel(self.floatTween)
  self.dead = true
  self.room:checkRunOver()
  Sounds.explosion:play()

end

function Alien:floatDown()

  self.floatTween = Timer.tween(1, self, { floatOffset = 0 }, 'in-out-quad', function ()
    self:floatUp()
  end)

end

function Alien:floatUp ()

  self.floatTween = Timer.tween(1, self, { floatOffset = 4 }, 'in-out-quad', function ()
    self:floatDown()
  end)

end

return Alien