local Class = require 'libraries/class'

local SpikesBottom = Class {
  hitbox = {
    x = 4, y = 24,
    width = 24,
    height = 8
  },
  solid = false,
  hostile = true,
  mortal = false,
  name = 'spikesBottom'
}

function SpikesBottom:init (room, x, y)

  self.room = room
  self.x = x
  self.y = y

end

function SpikesBottom:draw ()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.spikesBottom, self.x - self.hitbox.x, self.y - self.hitbox.y)

end

return SpikesBottom