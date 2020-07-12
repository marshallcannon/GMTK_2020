local Class = require 'libraries/class'
local Bump = require 'libraries/bump'
local Timer = require 'libraries/timer'
local Timeline = require 'gameObjects/timeline'
local Marine = require 'gameObjects/marine'
local Block = require 'gameObjects/block'
local Battery = require 'gameObjects/battery'
local Alien = require 'gameObjects/alien'

local Room = Class {
  width = 320,
  height = 320
}

function Room:init (scene, roomMap, x, y, gridX, gridY)

  self.scene = scene
  self.roomMap = roomMap
  self.x = x
  self.y = y
  self.gridX = gridX
  self.gridY = gridY

  self.bumpWorld = Bump.newWorld()
  self.objects = {}

  self:buildRoom(self.roomMap)

  self.playingBack = false
  self.recording = false
  self.runningTime = 0
  self.maxTime = 8

  self.timeline = Timeline(self.maxTime)

  -- locked, unlocked, complete
  self.status = 'locked'
  self.overlayText = love.graphics.newText(Fonts.verminVibes, '')
  self:lockRoom()

  self.lockedMovement = false
  self.lockedJumping = false
  self.lockedShooting = false

  -- Resetting the level
  self.resetTimer = 0
  self.resetMax = 1

  self.canvas = love.graphics.newCanvas(self.width, self.height)

end

function Room:update (dt)

  if self.recording or self.playingBack then

    for i = 1, #self.objects do
      if self.objects[i].update then
        self.objects[i]:update(dt)
      end
    end

  end

  if self.recording then
    self:recordUpdate(dt)
  end

  if self.playingBack then
    self:playbackUpdate(dt)
  end

  -- Clear dead objects
  for i = #self.objects, 1, -1 do
    if self.objects[i].dead then
      self:removeObject(self.objects[i])
    end
  end

end

function Room:recordUpdate (dt)

  self.runningTime = self.runningTime + dt
  if self.runningTime >= self.maxTime then
    if self:checkComplete() then
      self.completionTime = self.maxTime
      self:runComplete()
    else
      self:runFailed()
    end
    return
  end

  if self.lockedMovement then
    self:playbackMovement(dt)
  else
    self:recordMovement(dt)
  end

  if self.lockedJumping then
    self:playbackJumping()
  end

  if self.lockedShooting then
    self:playbackShooting()
  end

end

function Room:recordMovement (dt)

  if love.keyboard.isDown('left') and love.keyboard.isDown('right') then
    self.marine:stopMoving()
    if self.timeline.currentMovement then
      self.timeline:recordMovementStop(self.runningTime)
    end
  elseif love.keyboard.isDown('left') then
    self.marine:moveLeft(dt)
    if not self.timeline.currentMovement then
      self.timeline:recordMovementStart(self.runningTime, 'left')
    end
  elseif love.keyboard.isDown('right') then
    self.marine:moveRight(dt)
    if not self.timeline.currentMovement then
      self.timeline:recordMovementStart(self.runningTime, 'right')
    end
  else
    self.marine:stopMoving()
    if self.timeline.currentMovement then
      self.timeline:recordMovementStop(self.runningTime)
    end
  end

end

function Room:playbackUpdate (dt)

  self.runningTime = self.runningTime + dt
  if self.runningTime >= self.maxTime then
    self:stopPlayback()
    self:reset()
    return
  end

  -- Movement
  self:playbackMovement(dt)

  -- Jumping
  self:playbackJumping()

  -- Shooting
  self:playbackShooting()

end

function Room:playbackMovement (dt)

  local moveAction = self.timeline.movement[self.playbackMovementIndex]
  if moveAction then
    if self.runningTime >= moveAction.time then
      if moveAction.type == 'start' then
        self.runningMovementAction = moveAction
      elseif moveAction.type == 'stop' then
        if self.runningMovementAction then
          self.marine:stopMoving()
          self.runningMovementAction = nil
        end
      end
      self.playbackMovementIndex = self.playbackMovementIndex + 1
    end

  end
  if self.runningMovementAction then
    if self.runningMovementAction.direction == 'left' then
      self.marine:moveLeft(dt)
    elseif self.runningMovementAction.direction == 'right' then
      self.marine:moveRight(dt)
    end
  end

end

function Room:playbackJumping ()

  local jumpAction = self.timeline.jumping[self.playbackJumpIndex]
  if jumpAction then
    if self.runningTime >= jumpAction.time then
      if (self.marine:canJump()) then
        self.marine:jump()
      end
      self.playbackJumpIndex = self.playbackJumpIndex + 1
    end
  end

end

function Room:playbackShooting ()

  local shootAction = self.timeline.shooting[self.playbackShootIndex]
  if shootAction then
    if self.runningTime >= shootAction.time then
      if (self.marine:canShoot()) then
        self.marine:shoot()
      end
      self.playbackShootIndex = self.playbackShootIndex + 1
    end
  end

end

function Room:draw (x, y)

  for i = 1, #self.objects do
    self.objects[i]:draw()
  end

  love.graphics.setColor(232/255, 232/255, 232/255)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle('line', 0, 0, 320, 320)

  if not self.recording and not self.playingBack then
    if self.countdownText then
      love.graphics.setColor(1, 1, 1)
      local x = self.width / 2 - self.countdownText:getWidth() / 2
      local y = self.height / 2 - self.countdownText:getHeight() / 2
      love.graphics.draw(self.countdownText, x, y)
    else
      if self.status == 'complete' then
        -- Dark overlay
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', 0, 0, self.width, self.height)
        -- Checkmark
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Images.roomComplete, self.width / 2, self.height / 2, 0, 1, 1,
          Images.roomComplete:getWidth() / 2, Images.roomComplete:getHeight() / 2)
        -- Reset timer indicator
        if self.resetTimer == 0 then
          love.graphics.setFont(Fonts.verminVibes)
          love.graphics.print('\'r\' to reset', self.width / 2 - Fonts.verminVibes:getWidth('\'r\' to reset') / 2, self.height / 2 + 35)
        else
          local resetPercentage = self.resetTimer / self.resetMax
          love.graphics.arc('fill', self.width / 2, self.height / 2 + 40, 15, -math.pi / 2, -math.pi / 2 + math.pi * 2 * resetPercentage)
        end
      else
        if self.status == 'locked' then
          -- Dark overlay
          love.graphics.setColor(0, 0, 0, 0.5)
          love.graphics.rectangle('fill', 0, 0, self.width, self.height)
        end
        -- Locked timeline indication
        local lockedIcons = self:getLockedIcons()
        love.graphics.setColor(1, 1, 1)
        for i = 1, #lockedIcons do
          local x = self.width / 2
          if #lockedIcons == 1 or #lockedIcons == 3 then
            x = x
          elseif #lockedIcons == 2 then
            x = x - 75 + i * 50
          elseif #lockedIcons == 3 then
            x = x - 100 + i * 50
          end
          local y = self.height / 2 - lockedIcons[i]:getHeight() / 2
          love.graphics.draw(Images.lock, x, y, 0, 1, 1, 25)
          love.graphics.draw(lockedIcons[i], x, y, 0, 0.5, 0.5, 25, -25)
        end
        -- Overlay text
        love.graphics.setColor(1, 1, 1)
        local x = self.width / 2 - self.overlayText:getWidth() / 2
        local y = self.height / 2 - self.overlayText:getHeight() / 2 + 35
        love.graphics.draw(self.overlayText, x, y)
      end
    end
  end

end

function Room:keypressed (key)

  if self.recording then
    
    if not self.lockedJumping then
      if key == 'up' and self.marine:canJump() then
        self.marine:jump()
        self.timeline:recordJump(self.runningTime)
      end
    end

    if not self.lockedShooting then
      if key == 'space' and self.marine:canShoot() then
        self.marine:shoot()
        self.timeline:recordShot(self.runningTime)
      end
    end

    if key == 'r' then
      self:runFailed()
      self.scene.activeRoom = self
      self:startCountdown()
    end

    if key == 'escape' then
      self:runFailed()
    end

  end

end

function Room:keyreleased (key)

end

function Room:addObject (object, adjustPosition)

  if adjustPosition == nil then
    adjustPosition = true
  end

  table.insert(self.objects, object)
  if object.hitbox then
    if adjustPosition then
      -- Snap to ground
      object.y = object.y + object.hitbox.y + (32 - (object.hitbox.y +  object.hitbox.height))
      -- Put in center
      object.x = object.x + object.hitbox.x
    end
    -- Add to collisions
    self.bumpWorld:add(object, object.x, object.y,
      object.hitbox.width, object.hitbox.height)
  end

end

function Room:removeObject (object)

  if self.bumpWorld:hasItem(object) then
    self.bumpWorld:remove(object)
  end

  for i = 1, #self.objects do
    if (self.objects[i] == object) then
      table.remove(self.objects, i)
      break
    end
  end

end

function Room:buildRoom (roomMap)

  local tileLayer = roomMap.layers[1]
  local objectLayer = roomMap.layers[2]

  -- Tile layer
  for i = 1, #tileLayer.data do
    if tileLayer.data[i] == 1 then
      local x = ((i - 1) % 10) * 32
      local y = math.floor((i - 1) / 10) * 32
      local block = Block(x, y)
      self:addObject(block)
    end
  end

  -- Object layer
  for i = 1, #objectLayer.objects do
    local object = objectLayer.objects[i]
    local x = object.x
    local y = object.y - 32
    if object.gid == 2 then
      -- The marine needs to start in the center of its tile
      local marine = Marine(self, x, y)
      self:addObject(marine)
      self.marine = marine
    elseif object.gid == 3 then
      local alien = Alien(self, x, y)
      self:addObject(alien)
    elseif object.gid == 4 then
      local battery = Battery(self, x, y)
      self:addObject(battery)
    end
  end

end

function Room:startRecording ()

  self.recording = true
  self.runningTime = 0
  self.runningMovementAction = nil

  self:softClearTimeline()

  self.playbackJumpIndex = 1
  self.playbackShootIndex = 1
  self.playbackMovementIndex = 1

end

function Room:softClearTimeline ()

  if not self.lockedMovement then
    self.timeline:clearMovement()
  end
  if not self.lockedJumping then
    self.timeline:clearJumping()
  end
  if not self.lockedShooting then
    self.timeline:clearShooting()
  end

end

function Room:hardClearTimeline ()

  self.timeline:clear()

end

function Room:stopRecording ()

  self.recording = false
  if self.timeline.currentMovement then
    self.timeline:recordMovementStop(self.runningTime)
  end

end

function Room:startPlayback ()

  self.playingBack = true
  self.runningTime = 0
  self.playbackJumpIndex = 1
  self.playbackShootIndex = 1
  self.playbackMovementIndex = 1
  self.runningMovementAction = nil

end

function Room:stopPlayback ()

  self.playingBack = false

end

function Room:reset ()

  self.bumpWorld = Bump.newWorld()
  self.objects = {}
  self:buildRoom(self.roomMap)

end

function Room:setPriorRoom (room)

  self.priorRoom = room

end

function Room:setNextRoom (room)

  self.nextRoom = room

end

function Room:runComplete ()

  self:stop()
  self:reset()
  self:markComplete()
  self:updateNextRoomTimeline()
  self.scene:roomComplete()

end

function Room:runFailed ()

  self:stop()
  self:reset()
  self.scene:roomFailed()

end

function Room:checkRunOver ()

  if self:checkComplete() then

    self.completionTime = self.runningTime

    Timer.after(0.5, function ()
      if self.status ~= 'complete' then 
        self:runComplete()
      end
    end)

  end

end

function Room:checkComplete ()

  for i = 1, #self.objects do
    local object = self.objects[i]
    if object.name == 'battery' then
      if not object.dead then
        return false
      end
    end
  end

  return true

end

function Room:stop ()

  if self.recording then
    self:stopRecording()
  end

  if self.playingBack then
    self:stopPlayback()
  end

end

function Room:lockRoom ()

  self.status = 'locked'
  self.overlayText:set('')

end

function Room:unlockRoom ()

  self.status = 'unlocked'
  self.overlayText:set('Press Space to Start')

end

function Room:markComplete ()

  self.status = 'complete'

end

function Room:updateNextRoomTimeline ()

  if self.nextRoom then
    self.nextRoom:updateTimeline(self.timeline)
  end

end

function Room:updateTimeline (timeline)

  if self.lockedMovement then
    self.timeline.movement = timeline.movement
  end
  if self.lockedJumping then
    self.timeline.jumping = timeline.jumping
  end
  if self.lockedShooting then
    self.timeline.shooting = timeline.shooting
  end

end

function Room:lockTimeline (lock)

  if lock == 'move' then
    self.lockedMovement = true
  elseif lock == 'jump' then
    self.lockedJumping = true
  elseif lock == 'shoot' then
    self.lockedShooting = true
  end

end

function Room:startCountdown ()

  -- Countdown
  self.countdownText = love.graphics.newText(Fonts.verminVibes, '3')
  Timer.after(0.33, function ()
    self.countdownText:set('2')
  end)
  Timer.after(0.66, function ()
    self.countdownText:set('1')
  end)

  -- Start recording
  Timer.after(1, function ()
    self.countdownText = nil
    self:startRecording()
  end)

end

function Room:getLockedIcons ()

  local icons = {}
  if self.lockedJumping then
    table.insert(icons, Images.jumpIcon)
  end
  if self.lockedMovement then
    table.insert(icons, Images.movementIcon)
  end
  if self.lockedShooting then
    table.insert(icons, Images.shootIcon)
  end

  return icons

end

function Room:resetCompletionTime ()

  self.completionTime = nil

end

return Room