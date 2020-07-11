local Class = require 'libraries/class'

local Block = Class {
  hitbox = {
    x = 0, y = 0,
    width = 32,
    height = 32
  },
  solid = true
}

function Block:init (x, y)

  self.x = x
  self.y = y

end

function Block:draw ()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.block, self.x, self.y)

end

return Block