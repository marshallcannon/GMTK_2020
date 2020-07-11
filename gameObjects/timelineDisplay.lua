local Class = require 'libraries/class'

local TimelineDisplay = Class {}

function TimelineDisplay:init (x, y)

  self.x = x
  self.y = y
  self.width = 1000
  self.height = 180
  self.timeline = nil

end

function TimelineDisplay:draw ()

  love.graphics.setColor(Colors.Gray)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

  -- Jumping
  love.graphics.setColor(Colors.Shadow)
  love.graphics.circle('fill', self.x + 30, self.y + 30, 20)
  love.graphics.rectangle('fill', self.x + 100, self.y + 10, 890, 50)
  for i = 1, #self.timeline.jumping do
    local percentageTime = self.timeline.jumping[i].time / self.timeline.maxTime
    love.graphics.setColor(Colors.SpaceCadet)
    love.graphics.rectangle('fill', self.x + 100 + percentageTime * 890, self.y + 10, 10, 50)
  end

  -- Movements
  love.graphics.setColor(Colors.Shadow)
  love.graphics.circle('fill', self.x + 30, self.y + 90, 20)
  love.graphics.rectangle('fill', self.x + 100, self.y + 65, 890, 50)
  for i = 1, #self.timeline.movement, 2 do
    assert(self.timeline.movement[i].type == 'start', 'Should be a start')
    if self.timeline.movement[i + 1] then
      assert(self.timeline.movement[i + 1].type == 'stop', 'Should be a stop')
    end

    local percentageStart = self.timeline.movement[i].time / self.timeline.maxTime
    local percentageStop
    if self.timeline.movement[i + 1] then
      percentageStop = self.timeline.movement[i + 1].time / self.timeline.maxTime
    else
      percentageStop = self.room.runningTime / self.room.maxTime
    end
    if self.timeline.movement[i].direction == 'left' then
      love.graphics.setColor(Colors.Eminence)
    elseif self.timeline.movement[i].direction == 'right' then
      love.graphics.setColor(Colors.SpaceCadet)
    end
    love.graphics.rectangle('fill', self.x + 100 + percentageStart * 890, self.y + 65, percentageStop * 890 - percentageStart * 890, 50)
  end

  -- Shooting
  love.graphics.setColor(Colors.Shadow)
  love.graphics.circle('fill', self.x + 30, self.y + 150, 20)
  love.graphics.rectangle('fill', self.x + 100, self.y + 120, 890, 50)
  for i = 1, #self.timeline.shooting do
    local percentageTime = self.timeline.shooting[i].time / self.timeline.maxTime
    love.graphics.setColor(Colors.Auburn)
    love.graphics.rectangle('fill', self.x + 100 + percentageTime * 890, self.y + 120, 10, 50)
  end

  -- Playback marker
  if self.room and (self.room.playingBack or self.room.recording) then
    local percentageTime = self.room.runningTime / self.room.maxTime
    love.graphics.setColor(Colors.Eminence)
    love.graphics.rectangle('fill', self.x + 100 + 890 * percentageTime, self.y + 5, 10, 170)
  end

end

function TimelineDisplay:setRoom (room)

  self.room = room
  self.timeline = room.timeline

end

return TimelineDisplay
