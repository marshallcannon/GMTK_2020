local Class = require 'libraries/class'
local LevelOrder = require 'levels/levelOrder'

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
  Images.movementIcon = love.graphics.newImage('assets/images/movementIcon.png')
  Images.jumpIcon = love.graphics.newImage('assets/images/jumpIcon.png')
  Images.shootIcon = love.graphics.newImage('assets/images/gunIcon.png')
  Images.lock = love.graphics.newImage('assets/images/lock.png')
  Images.roomComplete = love.graphics.newImage('assets/images/roomComplete.png')
  Images.replayAllButton = love.graphics.newImage('assets/images/replayAllButton.png')
  Images.nextLevelButton = love.graphics.newImage('assets/images/nextLevelButton.png')
  Images.tiledBackground = love.graphics.newImage('assets/images/tiledBackground.png')
  Images.timelineBackground = love.graphics.newImage('assets/images/timelineBackground.png')
  Images.timelineTrack = love.graphics.newImage('assets/images/timelineTrack.png')
  Images.timelineTrackLock = love.graphics.newImage('assets/images/timelineTrackLock.png')
  Images.lockArrowLeft = love.graphics.newImage('assets/images/lockArrowLeft.png')
  Images.lockArrowRight = love.graphics.newImage('assets/images/lockArrowRight.png')
  Images.lockArrowUp = love.graphics.newImage('assets/images/lockArrowUp.png')
  Images.lockArrowDown = love.graphics.newImage('assets/images/lockArrowDown.png')

  Fonts = {}

  Fonts.extrude = love.graphics.newFont('assets/fonts/Extrude.ttf', 16, 'mono')
  Fonts.eightBit = love.graphics.newFont('assets/fonts/8-bit-hud.ttf', 12, 'mono')
  Fonts.verminVibes = love.graphics.newFont('assets/fonts/Vermin_Vibes_1989.ttf', 16, 'mono')

  self:loadingDone()

end

function LoadScene:loadingDone ()

  Game = {}
  Game.levelIndex = 2

  SceneManager:remove(self)
  SceneManager:add(GameScenes.Game(LevelOrder[Game.levelIndex]))

end

return LoadScene