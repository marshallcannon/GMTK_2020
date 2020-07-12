local Class = require 'libraries/class'

local TransitionScene = Class {}

function TransitionScene:init (duration)

  self.duration = duration or 1
  self.opacity = 0

  self:fadeIn(self.duration / 2)

end

function TransitionScene:update (dt)

end

function TransitionScene:draw ()

  love.graphics.setColor(0, 0, 0, self.opacity)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

end

function TransitionScene:fadeIn (duration)

  Timer.tween(duration, self, { opacity = 1 }, 'linear', function ()
    self:fadeOut(duration)
  end)

end

function TransitionScene:fadeOut (duration)

  Timer.tween(duration, self, { opacity = 0 }, 'linear', function ()
    SceneManager:remove(self)
  end)

end

return TransitionScene