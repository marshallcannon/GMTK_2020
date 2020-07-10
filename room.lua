local Class = require 'libraries/class'
local Bump = require 'libraries/bump'
local Marine = require 'gameObjects/marine'
local Block = require 'gameObjects/block'

local Room = Class {}

function Room:init (roomMap)

  self.roomMap = roomMap

  self.bumpWorld = Bump.newWorld()
  self.objects = {}

  self:buildRoom(self.roomMap)

end

function Room:update (dt)

  for i = #self.objects, 1, -1 do
    if self.objects[i].update then
      self.objects[i]:update(dt)
    end
    if self.objects[i].dead then
      self:removeObject(self.objects[i])
    end
  end

end

function Room:draw (x, y)

  love.graphics.translate(x, y)

  for i = 1, #self.objects do
    self.objects[i]:draw()
  end

  love.graphics.setColor(232/255, 232/255, 232/255, 1)
  -- love.graphics.setLineStyle()
  love.graphics.setLineWidth(2)
  love.graphics.rectangle('line', 0, 0, 320, 320)

  love.graphics.translate(-x, -y)

end

function Room:keypressed (key)

  self.marine:keypressed(key)

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
    if object.gid == 2 then
      local x = object.x - 32
      local y = object.y - 32
      local marine = Marine(self, x, y)
      self:addObject(marine)
      self.marine = marine
    end
  end

end

return Room