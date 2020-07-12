local Class = require 'libraries/class'

local SpikesTop = Class {
  hitbox = {
    x = 4, y = 0,
    width = 24,
    height = 8
  },
  solid = false,
  hostile = true,
  mortal = false,
  name = 'spikesTop'
}

function SpikesTop:init (room, x, y)

  self.room = room
  self.x = x
  self.y = y

end

function SpikesTop:draw ()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.spikesTop, self.x - self.hitbox.x, self.y - self.hitbox.y)

end

return SpikesTop