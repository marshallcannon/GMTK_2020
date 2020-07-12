local Class = require 'libraries/class'

local Battery = Class {
  hitbox = {
    x = 4, y = 3,
    width = 25,
    height = 25
  },
  solid = false,
  name = 'battery',
  collectible = true
}

function Battery:init (room, x, y)

  self.room = room
  self.x = x
  self.y = y

  self.floatOffset = 0
  self:floatUp()

end

function Battery:draw ()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.battery, self.x - self.hitbox.x, self.y - self.hitbox.y, 0, 1, 1, 0, self.floatOffset)

end

function Battery:floatDown()

  self.floatTween = Timer.tween(1.5, self, { floatOffset = 0 }, 'in-out-quad', function ()
    self:floatUp()
  end)

end

function Battery:floatUp ()

  self.floatTween = Timer.tween(1.5, self, { floatOffset = 3 }, 'in-out-quad', function ()
    self:floatDown()
  end)

end

function Battery:kill ()

  self.dead = true
  Timer.cancel(self.floatTween)

end

return Battery