local Class = require 'libraries/class'

local Credits = Class {}

function Credits:init ()

  self.backgroundX = 0
  self.backgroundY = 0

  self.textObjects = {}

  Timer.after(1, function ()
    table.insert(self.textObjects, {
      text = love.graphics.newText(Fonts.verminVibesBig, 'Time Lock'),
      x = love.graphics.getWidth() / 2,
      y = love.graphics.getHeight() / 2 - 200
    })
  end)
  Timer.after(2, function ()
    table.insert(self.textObjects, {
      text = love.graphics.newText(Fonts.verminVibesMedium, 'A game by Marshall Cannon'),
      x = love.graphics.getWidth() / 2,
      y = love.graphics.getHeight() / 2 - 100
    })
  end)
  Timer.after(3, function ()
    table.insert(self.textObjects, {
      text = love.graphics.newText(Fonts.verminVibesMedium, '@marshall_cannon'),
      x = love.graphics.getWidth() / 2,
      y = love.graphics.getHeight() / 2 - 50
    })
  end)
  Timer.after(4, function ()
    table.insert(self.textObjects, {
      text = love.graphics.newText(Fonts.verminVibesMedium, 'runnerupstudios.com'),
      x = love.graphics.getWidth() / 2,
      y = love.graphics.getHeight() / 2
    })
  end)
  Timer.after(5, function ()
    table.insert(self.textObjects, {
      text = love.graphics.newText(Fonts.verminVibesMedium, 'Press escape to quit'),
      x = love.graphics.getWidth() / 2,
      y = love.graphics.getHeight() / 2 + 50
    })
  end)

end

function Credits:update (dt)

  -- Background scroll
  self.backgroundX = self.backgroundX - dt * 10
  self.backgroundY = self.backgroundY - dt * 10
  if self.backgroundX <= -32 then self.backgroundX = self.backgroundX + 32 end
  if self.backgroundY <= -32 then self.backgroundY = self.backgroundY + 32 end

end

function Credits:draw ()

  self:drawBackground()

  for i = 1, #self.textObjects do
    local text = self.textObjects[i]
    love.graphics.draw(text.text, text.x, text.y, 0, 1, 1, text.text:getWidth() / 2, text.text:getHeight() / 2)
  end

end

function Credits:keypressed (key)

  if key == 'escape' then
    love.event.quit()
  end

end

function Credits:drawBackground ()

  love.graphics.setColor(1, 1, 1)
  local x, y = self.backgroundX, self.backgroundY
  while y < love.graphics.getHeight() do
    x = 0
    while x < love.graphics.getWidth() do
      love.graphics.draw(Images.tiledBackground, x, y)
      x = x + 32
    end
    y = y + 32
  end

end

return Credits