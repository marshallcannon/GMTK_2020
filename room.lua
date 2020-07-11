local Class = require 'libraries/class'
local Bump = require 'libraries/bump'
local Timer = require 'libraries/timer'
local Timeline = require 'gameObjects/timeline'
local Marine = require 'gameObjects/marine'
local Block = require 'gameObjects/block'
local Battery = require 'gameObjects/battery'

local Room = Class {
  width = 320,
  height = 320
}

function Room:init (roomMap, x, y)

  self.roomMap = roomMap
  self.x = x
  self.y = y

  self.bumpWorld = Bump.newWorld()
  self.objects = {}

  self:buildRoom(self.roomMap)

  self.playingBack = false
  self.recording = false
  self.runningTime = 0
  self.maxTime = 8
  self.freezeRunTime = false

  self.timeline = Timeline(self.maxTime)

  self.pausedText = love.graphics.newText(love.graphics.getFont(), 'Complete prior room')
  self.textVisible = true

  -- waiting, active, complete
  self.status = 'waiting'

end

function Room:update (dt)

  Timer.update(dt)

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

  if not self.freezeRunTime then
    self.runningTime = self.runningTime + dt
    if self.runningTime >= self.maxTime then
      self:stopRecording()
      self:reset()
      self:startPlayback()
      return
    end
  end

  if love.keyboard.isDown('left') and love.keyboard.isDown('right') then
    self.marine:stopMoving()
    if self.timeline.currentMovement then
      self.timeline:recordMovementStop(self.runningTime)
    end
  elseif love.keyboard.isDown('left') then
    self.marine:moveLeft()
    if not self.timeline.currentMovement then
      self.timeline:recordMovementStart(self.runningTime, 'left')
    end
  elseif love.keyboard.isDown('right') then
    self.marine:moveRight()
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

  if not self.freezeRunTime then
    self.runningTime = self.runningTime + dt
    if self.runningTime >= self.maxTime then
      self:stopPlayback()
      self:reset()
      return
    end
  end

  -- Movement
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
      self.marine:moveLeft()
    elseif self.runningMovementAction.direction == 'right' then
      self.marine:moveRight()
    end
  end

  -- Jumping
  local jumpAction = self.timeline.jumping[self.playbackJumpIndex]
  if jumpAction then
    if self.runningTime >= jumpAction.time then
      if (self.marine:canJump()) then
        self.marine:jump()
      end
      self.playbackJumpIndex = self.playbackJumpIndex + 1
    end
  end

  -- Shooting
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

  if self.textVisible then
    love.graphics.setColor(1, 1, 1)
    local x = self.x + self.width / 2 - self.pausedText:getWidth() / 2
    local y = self.y + self.height / 2 - self.pausedText:getHeight() / 2
    love.graphics.draw(self.pausedText, x, y)
  end

end

function Room:keypressed (key)

  if not self.recording and not self.playingBack then
    if key == 'left' or key == 'right' or key == 'up' or key == 'space' then
      self:startRecording()
    end
  end

  if self.recording then
    
    if key == 'up' and self.marine:canJump() then
      self.marine:jump()
      self.timeline:recordJump(self.runningTime)
    end

    if key == 'space' and self.marine:canShoot() then
      self.marine:shoot()
      self.timeline:recordShot(self.runningTime)
    end

  end

end

function Room:keyreleased (key)

end

function Room:addObject (object)

  table.insert(self.objects, object)
  if object.hitbox then
    self.bumpWorld:add(object, object.x + object.hitbox.x, object.y + object.hitbox.y,
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
      local marine = Marine(self, x, y)
      self:addObject(marine)
      self.marine = marine
    elseif object.gid == 3 then
      -- alien
    elseif object.gid == 4 then
      local battery = Battery(self, x, y)
      self:addObject(battery)
    end
  end

end

function Room:startRecording ()

  self.recording = true
  self.runningTime = 0
  self.timeline:clear()
  self.freezeRunTime = false

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
  self.freezeRunTime = false

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

function Room:checkComplete ()

  for i = 1, #self.objects do
    local object = self.objects[i]
    if object.name == 'battery' then
      if not object.dead then
        return false
      end
    end
  end

  self.freezeRunTime = true

  Timer.after(0.25, function () self:stop() end)

end

function Room:stop ()

  print('stop')

  if self.recording then
    self:stopRecording()
  end

  if self.playingBack then
    self:stopPlayback()
  end

end

return Room