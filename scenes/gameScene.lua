local Class = require 'libraries/class'
local Timer = require 'libraries/timer'
local Camera = require 'libraries/camera'
local Room = require 'room'
local TimelineDisplay = require 'gameObjects/timelineDisplay'

local GameScene = Class {
  roomWidth = 320,
  roomHeight = 320
}

function GameScene:init (folderName)

  self.levelLayout = require('levels/' .. folderName .. '/layout')
  self.roomMaps = self:loadRoomMaps(folderName, self.levelLayout)
  self.rooms = self:createRooms(self.levelLayout, self.roomMaps)

  self.activeRoom = self.rooms[1][1]

  self.timelineDisplay = TimelineDisplay(love.graphics.getWidth() / 2 - 500, love.graphics.getHeight() - 190)
  self.timelineDisplay:setRoom(self.rooms[1][1])

  self.camera = Camera.new(0, 0)
  self:zoomToRoom(self.rooms[1][1])

end

function GameScene:update (dt)

  self.activeRoom:update(dt)

  Timer.update(dt)

end

function GameScene:draw ()

  local xOffset = (love.graphics.getWidth() - self.roomWidth * 3) / 2
  local yOffset = (love.graphics.getHeight() - self.roomHeight * 3) / 2

  self.camera:attach()

  for y = 1, #self.rooms do
    for x = 1, #self.rooms[y] do
      local roomX = (x - 1) * self.roomWidth
      local roomY = (y - 1) * self.roomHeight
      love.graphics.translate(roomX, roomY)
      self.rooms[y][x]:draw()
      love.graphics.translate(-roomX, -roomY)
    end
  end

  self.camera:detach()

  self.timelineDisplay:draw()

end

function GameScene:keypressed (key)

  self.activeRoom:keypressed(key)

  if key == 'f' then
    self:zoomOut()
  end

end

function GameScene:keyreleased (key)

  self.activeRoom:keyreleased(key)

end

function GameScene:loadRoomMaps (folderName, layout)

  local roomMaps = {}

  local folderPath = 'levels/' .. folderName .. '/'
  for y = 1, #layout.rooms do
    for x = 1, #layout.rooms[y] do
      local map = require(folderPath .. layout.rooms[y][x])
      table.insert(roomMaps, map)
    end
  end

  return roomMaps

end

function GameScene:createRooms (layout, roomMaps)

  local rooms = {}

  local roomCount = 1
  for row = 1, #layout.rooms do
    rooms[row] = {}
    for column = 1, #layout.rooms[row] do
      rooms[row][column] = Room(roomMaps[roomCount], (row - 1) * self.roomWidth, (column - 1) * self.roomHeight)
      roomCount = roomCount + 1
    end
  end

  return rooms

end

function GameScene:zoomToRoom (room, time)

  local x, y = self:getRoomCenter(room)
  self:zoomToCoordinates(x, y, 2, time)

end

function GameScene:zoomToCoordinates (x, y, zoom, time)

  zoom = zoom or 1
  time = time or 1

  Timer.tween(time, self.camera, { scale = 2, x = x, y = y }, 'in-out-quad')

end

function GameScene:zoomOut (time)

  time = time or 1

  local roomsHeight = #self.rooms
  local roomsWidth = 0
  for i = 1, #self.rooms do
    roomsWidth = math.max(roomsWidth, #self.rooms[i])
  end

  self:zoomToCoordinates(roomsWidth * self.roomWidth / 2, roomsHeight * self.roomHeight / 2, 1)

end

function GameScene:getRoomCenter (room)

  return room.x + self.roomWidth / 2, room.y + self.roomHeight / 2

end

return GameScene