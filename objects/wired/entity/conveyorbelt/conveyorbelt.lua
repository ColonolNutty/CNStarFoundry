function init(v)
  energy.init()
  if storage.active == nil then storage.active = false end
  setActive(storage.active)
  self.workSound = config.getParameter("workSound")
  self.moveSpeed = config.getParameter("moveSpeed")
  onNodeConnectionChange(nil)
  physics.setForceEnabled("right", false)
  physics.setForceEnabled("left", false)
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
    storage.active = flag
    if flag then 
      animator.setAnimationState("workState", "work")
    else
      animator.setAnimationState("workState", "idle")
    end
  else
    physics.setForceEnabled("right", false)
    physics.setForceEnabled("left", false)
  end
end

function update(dt)
  energy.update(dt)
  physics.setForceEnabled("right", false)
  physics.setForceEnabled("left", false)
  if storage.active then
    if not energy.consumeEnergy(nil, nil, dt) then
      setActive(false, dt)
      return
    end
    
    local d = object.direction();
    physics.setForceEnabled((d > 0 and "right") or "left", true)
  end
end
