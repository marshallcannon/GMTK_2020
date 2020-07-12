local Class = require 'libraries/class'

local Battery = Class {
  hitbox = {
    x = 6, y = 6,
    width = 22,
    height = 21
  },
  solid = false,
  name = 'battery',
  collectible = true
}

function Battery:init (room, x, y)

  self.room = room
  self.x = x
  self.y = y

end

function Battery:draw ()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.battery, self.x, self.y)

end

return Battery