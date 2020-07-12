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

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.timelineBackground, self.x, self.y)

  if not self.room then
    return
  end

  -- Jumping
  local yOffset = 6
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.jumpIcon, self.x + 50, self.y + yOffset)
  if self.room.lockedJumping then
    love.graphics.draw(Images.lock, self.x, self.y + yOffset)
  end
  love.graphics.draw(Images.timelineTrack, self.x + 100, self.y + yOffset)
  for i = 1, #self.timeline.jumping do
    local percentageTime = self.timeline.jumping[i].time / self.timeline.maxTime
    local x = math.floor(self.x + 100 + percentageTime * 890)
    local y = self.y + yOffset
    local width = 10
    local height = 50
    love.graphics.setColor(Colors.SteelTeal_Dark)
    love.graphics.rectangle('fill', x, y, width, height, 4, 4)
    love.graphics.setColor(Colors.SteelTeal)
    love.graphics.rectangle('fill', x, y, width, height - 3, 4, 4)
  end

  -- Movements
  yOffset = 61
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.movementIcon, self.x + 50, self.y + yOffset)
  if self.room.lockedMovement then
    love.graphics.draw(Images.lock, self.x, self.y + yOffset)
  end
  love.graphics.draw(Images.timelineTrack, self.x + 100, self.y + yOffset)
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
    local x = math.floor(self.x + 100 + percentageStart * 890)
    local y = self.y + yOffset
    local width = percentageStop * 890 - percentageStart * 890
    local height = 50
    if self.timeline.movement[i].direction == 'left' then
      love.graphics.setColor(Colors.BlueMunsell_Dark)
    elseif self.timeline.movement[i].direction == 'right' then
      love.graphics.setColor(Colors.Tomato_Dark)
    end
    love.graphics.rectangle('fill', x, y, width, height, 4, 4)
    if self.timeline.movement[i].direction == 'left' then
      love.graphics.setColor(Colors.BlueMunsell)
    elseif self.timeline.movement[i].direction == 'right' then
      love.graphics.setColor(Colors.Tomato)
    end
    love.graphics.rectangle('fill', x, y, width, height - 3, 4, 4)
  end

  -- Shooting
  yOffset = 116
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Images.shootIcon, self.x + 50, self.y + yOffset)
  if self.room.lockedShooting then
    love.graphics.draw(Images.lock, self.x, self.y + yOffset)
  end
  love.graphics.draw(Images.timelineTrack, self.x + 100, self.y + yOffset)
  for i = 1, #self.timeline.shooting do
    local percentageTime = self.timeline.shooting[i].time / self.timeline.maxTime
    local x = self.x + 100 + percentageTime * 890
    local y = self.y + yOffset
    local width = 10
    local height = 50
    love.graphics.setColor(Colors.Auburn_Dark)
    love.graphics.rectangle('fill', x, y, width, height, 4, 4)
    love.graphics.setColor(Colors.Auburn)
    love.graphics.rectangle('fill', x, y, width, height - 3, 4, 4)
  end

  -- Playback marker
  if self.room and (self.room.playingBack or self.room.recording) then
    local percentageTime = self.room.runningTime / self.room.maxTime
    love.graphics.setColor(Colors.Platinum_Dark)
    love.graphics.rectangle('fill', self.x + 100 + 890 * percentageTime - 4, self.y - 3, 8, 170, 4, 4)
    love.graphics.setColor(Colors.Platinum)
    love.graphics.rectangle('fill', self.x + 100 + 890 * percentageTime - 4, self.y - 3, 8, 167, 4, 4)
  end

end

function TimelineDisplay:setRoom (room)

  self.room = room
  self.timeline = room.timeline

end

return TimelineDisplay
