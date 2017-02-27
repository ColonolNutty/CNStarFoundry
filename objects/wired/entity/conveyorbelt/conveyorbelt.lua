function init(v)
  energy.init()
  if storage.active == nil then storage.active = false end
  setActive(storage.active)
  self.workSound = config.getParameter("workSound")
  self.moveSpeed = config.getParameter("moveSpeed")
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

function setActive(flag)
  if not flag or energy.consumeEnergy(nil, true) then
    storage.active = flag
    if flag then animator.setAnimationState("workState", "work")
    else animator.setAnimationState("workState", "idle") end
  end
end

function update(dt)
  energy.update()
  if storage.active then
    if not energy.consumeEnergy() then
      setActive(false)
      return
    end

    self.st = self.st + 1
    if self.st > 7 then 
      self.st = 0
    elseif self.st == 3 then
      animator.playImmediateSound(self.workSound)
    end
    local p = object.toAbsolutePosition({ -1.8, 1 })
    object.setForceRegion({ p[1], p[2], p[1] + 3.6, p[2] }, { self.moveSpeed * object.direction(), 0})
  end
end
