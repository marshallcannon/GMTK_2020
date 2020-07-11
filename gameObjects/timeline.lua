local Class = require 'libraries/class'

local Timeline = Class {}

function Timeline:init (maxTime)

  self.maxTime = maxTime

  self.movement = {}
  self.jumping = {}
  self.shooting = {}

  self.currentMovement = nil

end

function Timeline:recordMovementStart (time, direction)

  local movement = {
    time = time,
    direction = direction,
    type = 'start'
  }
  table.insert(self.movement, movement)
  self.currentMovement = direction

end

function Timeline:recordMovementStop (time)

  local movementStop = {
    time = time,
    type = 'stop'
  }
  table.insert(self.movement, movementStop)
  self.currentMovement = nil

end

function Timeline:recordJump (time)

  local jump = {
    time = time
  }
  table.insert(self.jumping, jump)

end

function Timeline:recordShot (time)

  local shot = {
    time = time
  }
  table.insert(self.shooting, shot)

end

function Timeline:clear ()

  self:clearMovement()
  self:clearJumping()
  self:clearShooting()

end

function Timeline:clearMovement ()

  self.movement = {}

end

function Timeline:clearJumping ()

  self.jumping = {}

end

function Timeline:clearShooting ()

  self.shooting = {}

end

return Timeline