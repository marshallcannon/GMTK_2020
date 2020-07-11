local Class = require 'libraries/class'

local LoadScene = Class {}

function LoadScene:init ()

end

function LoadScene:loadAll ()

  Images = {}

  Images.marine = love.graphics.newImage('assets/images/marine.png')
  Images.block = love.graphics.newImage('assets/images/block.png')
  Images.bullet = love.graphics.newImage('assets/images/bullet.png')
  Images.battery = love.graphics.newImage('assets/images/battery.png')
  Images.alien = love.graphics.newImage('assets/images/alien.png')

  self:loadingDone()

end

function LoadScene:loadingDone ()

  SceneManager:remove(self)
  SceneManager:add(GameScenes.Game('level_1'))

end

return LoadScene