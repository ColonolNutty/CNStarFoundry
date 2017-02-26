function init(v)
  energy.init()

  if storage.active == nil then storage.active = false end

  self.flipStr = ""
  if object.direction() == -1 then
    self.flipStr = "flip"
  end
  animator.setParticleEmitterActive("fanwind", false)
  animator.setParticleEmitterActive("fanwindflip", false)

  setActive(storage.active)
  self.affectWidth = config.getParameter("affectWidth")
  self.blowSound = config.getParameter("blowSound")
  self.fanPower = config.getParameter("fanPower")
  self.timer = 0
  self.st = 0
  onNodeConnectionChange(nil)
end

function die()
  energy.die()
end

function onNodeConnectionChange(args)
  if object.isInputNodeConnected(0) then
    object.setInteractive(false)
  else
    object.setInteractive(true)
  end
  onInputNodeChange(args)
end

function onInputNodeChange(args)
  if object.isInputNodeConnected(0) then
    setActive(object.getInputNodeLevel(0))
  end
end

function onInteraction(args)
  setActive(not storage.active)
end

function setActive(flag, dt)
  if not flag or energy.consumeEnergy(nil, true, dt or 0) then
    animator.setParticleEmitterActive("fanwind" .. self.flipStr, flag)
    if flag then
      animator.setAnimationState("fanState", "work")
    elseif storage.active then
      animator.setAnimationState("fanState", "slow")
      self.timer = 20
    else
      animator.setAnimationState("fanState", "idle")
    end
    storage.active = flag
  end
end


function update(dt)
  energy.update(dt)
  if storage.active then
    if not energy.consumeEnergy(nil, nil, dt) then
      setActive(false, dt)
      return
    end
    self.st = self.st + 1
    if self.st > 6 then 
      self.st = 0
    elseif self.st == 3 then 
      object.playImmediateSound(self.blowSound)
    end
    local d = object.direction();
    local p = object.position();
    local region;
    if d == 1 then
      region = { p[1], p[2] - 1, p[1] + d * self.affectWidth, p[2] + 1 }
    else
      region = { p[1] + d * self.affectWidth, p[2] - 1, p[1], p[2] + 1 }
    end
    object.setForceRegion(region, { self.fanPower * d, 0 })
  elseif self.timer > 0 then
    if self.timer % 12 == 4 then 
      object.playImmediateSound(self.blowSound) 
    end
    self.timer = self.timer - 1
    if self.timer == 1 then 
      animator.setAnimationState("fanState", "idle") 
    end
  end
  
end
