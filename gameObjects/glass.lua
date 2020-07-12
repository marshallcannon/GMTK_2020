local Class = require 'libraries/class'

local Glass = Class {
  hitbox = {
    x = 0, y = 0,
    width = 32,
    height = 32
  },
  solid = true,
  blocksVision = false,
  name = 'glass'
}

function Glass:init (x, y)

  self.x = x
  self.y = y

end

function Glass:draw ()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.glass, self.x, self.y)

end

return Glass