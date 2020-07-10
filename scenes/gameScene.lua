local Class = require 'libraries/class'
local Room = require 'room'

local GameScene = Class {
  roomWidth = 320,
  roomHeight = 320
}

function GameScene:init (folderName)

  self.levelLayout = require('levels/' .. folderName .. '/layout')
  self.roomMaps = self:loadRoomMaps(folderName, self.levelLayout)

  self.rooms = {
    {Room(self.roomMaps[1]), Room(self.roomMaps[2]), Room(self.roomMaps[3])},
    {Room(self.roomMaps[4]), Room(self.roomMaps[5]), Room(self.roomMaps[6])},
    {Room(self.roomMaps[7]), Room(self.roomMaps[8]), Room(self.roomMaps[9])}
  }

  self.activeRoom = self.rooms[1][1]

end

function GameScene:update (dt)

  self.activeRoom:update(dt)

end

function GameScene:draw ()

  local xOffset = (love.graphics.getWidth() - self.roomWidth * 3) / 2
  local yOffset = (love.graphics.getHeight() - self.roomHeight * 3) / 2

  love.graphics.translate(xOffset, yOffset)
  for y = 1, #self.rooms do
    for x = 1, #self.rooms[y] do
      self.rooms[y][x]:draw((x - 1) * self.roomWidth, (y - 1) * self.roomHeight)
      love.graphics.setColor(math.random(), math.random(), math.random())
    end
  end

end

function GameScene:keypressed (key)

  self.activeRoom:keypressed(key)

end

function GameScene:loadRoomMaps (folderName, layout)

  local roomMaps = {}

  local folderPath = 'levels/' .. folderName .. '/'
  for y = 1, #layout do
    for x = 1, #layout[y] do
      local map = require(folderPath .. layout[y][x])
      table.insert(roomMaps, map)
    end
  end

  return roomMaps

end

return GameScene