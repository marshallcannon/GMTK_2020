local Class = require 'libraries/class'
local Camera = require 'libraries/camera'
local Room = require 'room'
local TimelineDisplay = require 'gameObjects/timelineDisplay'
local LevelOrder = require 'levels/levelOrder'

local GameScene = Class {
  roomWidth = 320,
  roomHeight = 320
}

function GameScene:init (folderName)

  self.levelLayout = require('levels/' .. folderName .. '/layout')
  self.roomMaps = self:loadRoomMaps(folderName, self.levelLayout)
  print('#roomMaps: ' .. #self.roomMaps)
  self.rooms, self.roomOrder = self:createRooms(self.levelLayout, self.roomMaps)
  for y = 1, #self.rooms do
    for x = 1, #self.rooms[y] do
      print(self.rooms[y][x])
    end
  end
  print(#self.roomOrder)

  self.selectedRoomRow = 1
  self.selectedRoomColumn = 1
  self.selectedRoom = self.roomOrder[1]

  self.timelineDisplay = TimelineDisplay(love.graphics.getWidth() / 2 - 500, love.graphics.getHeight() - 190)

  self.camera = Camera.new(0, 0)
  self:zoomToRoom(self.selectedRoom)
  self:setTimeline(self.selectedRoom)
  self.selectedRoom:unlockRoom()

  self.backgroundX = 0
  self.backgroundY = 0

end

function GameScene:update (dt)

  if self.finalPlayback then
    for i = 1, #self.roomOrder do
      self.roomOrder[i]:update(dt)
    end
  else
    if self.activeRoom then
      self.activeRoom:update(dt)
    else
      if love.keyboard.isDown('r') then
        if self.selectedRoom.status == 'complete' then
          self.selectedRoom.resetTimer = self.selectedRoom.resetTimer + dt
          -- Reset after completion
          if self.selectedRoom.resetTimer >= self.selectedRoom.resetMax then
            self:resetToRoom(self.selectedRoom)
          end
        end
      end
    end
  end

  -- Background scroll
  self.backgroundX = self.backgroundX - dt * 10
  self.backgroundY = self.backgroundY - dt * 10
  if self.backgroundX <= -32 then self.backgroundX = self.backgroundX + 32 end
  if self.backgroundY <= -32 then self.backgroundY = self.backgroundY + 32 end

end

function GameScene:draw ()

  self:drawBackground()

  local xOffset = (love.graphics.getWidth() - self.roomWidth * 3) / 2
  local yOffset = (love.graphics.getHeight() - self.roomHeight * 3) / 2

  self.camera:attach()

  for i = 1, #self.roomOrder do
    local room = self.roomOrder[i]
    love.graphics.translate(room.x, room.y)
    room:draw()
    love.graphics.translate(-room.x, -room.y)
  end
  -- for y = 1, #self.rooms do
  --   for x = 1, #self.rooms[y] do
  --     local roomX = (x - 1) * self.roomWidth
  --     local roomY = (y - 1) * self.roomHeight
  --     love.graphics.translate(roomX, roomY)
  --     self.rooms[y][x]:draw()
  --     love.graphics.translate(-roomX, -roomY)
  --   end
  -- end

  -- self:drawLockArrows()

  self.camera:detach()


  self.timelineDisplay:draw()

  if self.replayButton then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.replayButton.image, self.replayButton.x, self.replayButton.y)
  end

  if self.nextLevelButton then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.nextLevelButton.image, self.nextLevelButton.x, self.nextLevelButton.y)
  end

end

function GameScene:keypressed (key)

  if self.activeRoom then
    self.activeRoom:keypressed(key)
  else
    if key == 'left' or key == 'right' or
    key == 'up' or key == 'down' then
      if not love.keyboard.isDown('r') and not self.finalPlayback then
        self:scrollRooms (key)
      end
    end
    if key == 'tab' then
      self:zoomOut(0.5)
    end
    if key == 'space' then
      if self.nextLevelButton then
        self:goToNextLevel()
      else
        if self.selectedRoom.status == 'unlocked' then
          self:zoomToRoom(self.selectedRoom)
          self.activeRoom = self.selectedRoom
          self.activeRoom:startCountdown()
        end
      end
    end
  end

end

function GameScene:keyreleased (key)

  if self.activeRoom then
    self.activeRoom:keyreleased(key)
  else
    if key == 'r' then
      self.selectedRoom.resetTimer = 0
    end
  end

end

function GameScene:mousepressed (x, y, button)

  if self.replayButton then
    if x >= self.replayButton.x and x <= self.replayButton.x + self.replayButton.image:getWidth() and
      y >= self.replayButton.y and y <= self.replayButton.y + self.replayButton.image:getHeight() then
      self:playAllRooms()
    end
  end

  if self.nextLevelButton then
    if x >= self.nextLevelButton.x and x <= self.nextLevelButton.x + self.nextLevelButton.image:getWidth() and
      y >= self.nextLevelButton.y and y <= self.nextLevelButton.y + self.nextLevelButton.image:getHeight() then
      self:goToNextLevel()
    end
  end

end

function GameScene:loadRoomMaps (folderName, layout)

  local roomMaps = {}

  local folderPath = 'levels/' .. folderName .. '/'
  for y = 1, #layout.rooms do
    for x = 1, #layout.rooms[y] do
      if type(layout.rooms[y][x]) == 'string' then
        local map = require(folderPath .. layout.rooms[y][x])
        table.insert(roomMaps, map)
      end
    end
  end

  return roomMaps

end

function GameScene:createRooms (layout, roomMaps)

  local rooms = {}

  -- Order the rooms are played in
  local sortedRooms = {}

  -- Create rooms
  local roomCount = 1
  for row = 1, #layout.rooms do
    rooms[row] = {}
    for column = 1, #layout.rooms[row] do
      if type(layout.rooms[row][column]) == 'string' then
        print('Room exists')
        print(column, row)
        local newRoom = Room(self, roomMaps[roomCount], (column - 1) * self.roomWidth, (row - 1) * self.roomHeight, column, row)
        rooms[row][column] = newRoom
        sortedRooms[roomCount] = newRoom
        roomCount = roomCount + 1
        -- Custom backgrounds
        if layout.backgrounds and layout.backgrounds[row] and layout.backgrounds[row][column] then
          newRoom:setBackground(Images[layout.backgrounds[row][column]])
        end
      else
        print('Room does not exist')
        print(column, row)
      end
    end
  end

  print('Made ' .. roomCount - 1 .. ' rooms')

  assert(#sortedRooms == roomCount - 1, 'The room order got fucked up')

  -- Assign room order
  for y = 1, #layout.order do
    for x = 1, #layout.order[y] do
      if type(layout.order[y][x]) == 'number' then
        rooms[y][x].roomIndex = layout.order[y][x]
        print('Room index: ' .. rooms[y][x].roomIndex)
      end
    end
  end

  -- Link rooms in order
  for i = 1, #sortedRooms do
    local room = sortedRooms[i]
    if room.roomIndex > 1 then
      print('Assigning prior room for room index ' .. room.roomIndex)
      local priorRoom = self:getRoomAtOrder(sortedRooms, room.roomIndex - 1)
      assert(priorRoom, 'No prior room!')
      room:setPriorRoom(priorRoom)
    end
    local nextRoom = self:getRoomAtOrder(sortedRooms, room.roomIndex + 1)
    if nextRoom then
      room:setNextRoom(nextRoom)
    end
  end

  -- Lock timelines
  for row = 1, #rooms do
    for column = 1, #rooms[row] do
      local room = rooms[row][column]
      local lockedTimeline = layout.locks[row][column]
      if room and lockedTimeline then
        room:lockTimeline(lockedTimeline)
      end
    end
  end

  return rooms, sortedRooms

end

function GameScene:zoomToRoom (room, time)

  local x, y = self:getRoomCenter(room)
  self:zoomToCoordinates(x, y, 2, time)

end

function GameScene:zoomToCoordinates (x, y, zoom, time)

  zoom = zoom or 1
  time = time or 1

  if self.cameraTween then
    Timer.cancel(self.cameraTween)
  end
  self.cameraTween = Timer.tween(time, self.camera, { scale = zoom, x = x, y = y }, 'in-out-quad', function ()
    self.cameraTween = nil
  end)

end

function GameScene:zoomOut (time)

  time = time or 1

  local roomsHeight = #self.rooms
  local roomsWidth = 0
  for i = 1, #self.rooms do
    roomsWidth = math.max(roomsWidth, #self.rooms[i])
  end

  self:zoomToCoordinates(roomsWidth * self.roomWidth / 2, roomsHeight * self.roomHeight / 2, 1, time)

end

function GameScene:getRoomCenter (room)

  return room.x + self.roomWidth / 2, room.y + self.roomHeight / 2

end

function GameScene:setTimeline (room)

  self.timelineDisplay:setRoom(room)

end

function GameScene:scrollRooms (direction)

  local room = self:getAdjacentRoom(direction)
  if room then
    self:scrollToRoom(room)
  end

end

function GameScene:scrollToRoom (room)

  self:zoomToRoom(room, 0.5)
  self.selectedRoom = room
  self.selectedRoomRow = room.gridY
  self.selectedRoomColumn = room.gridX
  self.timelineDisplay:setRoom(self.selectedRoom)

end

function GameScene:getAdjacentRoom (direction)

  local room
  if direction == 'left' then
    room = self.rooms[self.selectedRoomRow][self.selectedRoomColumn - 1]
  elseif direction == 'right' then
    room = self.rooms[self.selectedRoomRow][self.selectedRoomColumn + 1]
  elseif direction == 'up' then
    if self.rooms[self.selectedRoomRow - 1] then
      room = self.rooms[self.selectedRoomRow - 1][self.selectedRoomColumn]
    end
  elseif direction == 'down' then
    if self.rooms[self.selectedRoomRow + 1] then
      room = self.rooms[self.selectedRoomRow + 1][self.selectedRoomColumn]
    end
  end

  return room

end

function GameScene:roomComplete ()

  if self.activeRoom.nextRoom then
    self.activeRoom.nextRoom:unlockRoom()
    self:scrollToRoom(self.activeRoom.nextRoom)
  else
    -- All levels complete
    self:hideTimeline()
    self:zoomOut()
    self:playAllRooms()

    local maxRuntime = self:getLongestCompletionTime()
    Timer.after(maxRuntime + 0.5, function ()
      self:showEndButtons()
    end)
  end
  self.activeRoom = nil

end

function GameScene:roomFailed ()

  self.activeRoom = nil

end

function GameScene:resetToRoom (resetRoom)

  for i = #self.roomOrder, 1, -1 do
    local room = self.roomOrder[i]
    room:stop()
    room:reset()
    room:resetCompletionTime()
    if room == resetRoom then
      room:softClearTimeline()
      room:unlockRoom()
      break
    else
      room:hardClearTimeline()
      room:lockRoom()
    end
  end

  resetRoom.resetTimer = 0

end

function GameScene:playAllRooms ()

  for i = 1, #self.roomOrder do
    self.roomOrder[i]:reset()
    self.roomOrder[i]:startPlayback()
  end
  self.finalPlayback = true

end

function GameScene:getLongestCompletionTime ()

  local time = 0
  for i = 1, #self.roomOrder do
    time = math.max(time, self.roomOrder[i].completionTime)
  end
  return time

end

function GameScene:showEndButtons ()

  self.replayButton = {
    image = Images.replayAllButton,
    x = love.graphics.getWidth() / 2 - Images.replayAllButton:getWidth() - 25,
    y = love.graphics.getHeight(),
  }
  Timer.tween(0.5, self.replayButton, { y = love.graphics.getHeight() - Images.replayAllButton:getHeight() - 50 }, 'out-quad')

  self.nextLevelButton = {
    image = Images.nextLevelButton,
    x = love.graphics.getWidth() / 2 + 25,
    y = love.graphics.getHeight()
  }
  Timer.tween(0.5, self.nextLevelButton, { y = love.graphics.getHeight() - Images.nextLevelButton:getHeight() - 50 }, 'out-quad')

end

function GameScene:hideTimeline ()

  Timer.tween(0.5, self.timelineDisplay, { y = love.graphics.getHeight() + 10 }, 'out-quad')

end

function GameScene:goToNextLevel ()

  Game.levelIndex = Game.levelIndex + 1
  SceneManager:add(GameScenes.Transition(1))

  Timer.after(0.5, function ()
    SceneManager:remove(self)
    SceneManager:add(GameScenes.Game(LevelOrder[Game.levelIndex]), 1)
  end)

end

function GameScene:drawBackground ()

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

-- Unfinished
function GameScene:drawLockArrows ()

  love.graphics.setColor(1, 1, 1, 0.5)
  for i = 2, #self.roomOrder do
    local room = self.roomOrder[i]
    local priorRoom = room.priorRoom
    local icons = room:getLockedIcons()
    local arrowSide = self:getRoomDirection (priorRoom, room)
    if arrowSide == 'left' then
      local centerX = room.x + room.width
      local centerY = room.y + room.height / 2
      for i = 1, #icons do
        love.graphics.draw(Images.lockArrowLeft, centerX, centerY, 0, 1, 1, 41)
        love.graphics.draw(icons[1], centerX, centerY, 0, 0.5, 0.5, 41)
      end
    elseif arrowSide == 'right' then
      local centerX = room.x
      local centerY = room.y + room.height / 2
      for i = 1, #icons do
        love.graphics.draw(Images.lockArrowRight, centerX, centerY, 0, 1, 1, 26, 26)
        love.graphics.draw(icons[1], centerX, centerY, 0, 1, 1, 26, 26)
      end
    elseif arrowSide == 'up' then

    elseif arrowSide == 'down' then

    end
  end

end

function GameScene:getRoomDirection (room1, room2)

  if room2.x < room1.x then
    return 'left'
  elseif room2.x > room1.x then
    return 'right'
  elseif room2.y < room1.y then
    return 'up'
  elseif room2.y > room1.y then
    return 'down'
  end

end

function GameScene:getRoomAtOrder (rooms, index)

  for i = 1, #rooms do
    if rooms[i].roomIndex == index then return rooms[i] end
  end

end

return GameScene