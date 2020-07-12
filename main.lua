Colors = require 'colors'
Timer = require 'libraries/timer'

function love.load ()

  love.window.setMode(0, 0, {vsync=false})
  love.graphics.setDefaultFilter('nearest', 'nearest')

  SceneManager = require 'scenes/sceneManager'

  GameScenes = {}
  GameScenes.Load = require 'scenes/loadScene'
  GameScenes.Game = require 'scenes/gameScene'
  GameScenes.Transition = require 'scenes/transitionScene'

  local load = GameScenes.Load()
  SceneManager:add(load)
  load:loadAll()

end

function love.update (dt)
  Timer.update(dt)
  SceneManager:update(dt)
end

function love.draw ()
  SceneManager:draw()
end

function love.keypressed (key)
  SceneManager:keypressed(key)
end

function love.keyreleased (key)
  SceneManager:keyreleased(key)
end

function love.mousepressed (x, y, button)
  SceneManager:mousepressed(x, y, button)
end