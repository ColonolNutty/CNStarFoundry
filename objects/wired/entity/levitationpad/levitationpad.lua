function init(v)
  if not v then
    energy.init()
  end
  if storage.active == nil then 
    storage.active = false
  end
  setActive(storage.active)
  self.levitationHeight = config.getParameter("levitationHeight")
  self.workSound = config.getParameter("workSound")
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
    if flag then animator.setAnimationState("jumpState", "jump")
    else animator.setAnimationState("jumpState", "idle") end
  end
end

function firstValidEntity(eids)
  local invalid = { "object", "plant", "effect" }
  for i, id in pairs(eids) do
    if not world.callScriptedEntity(id, "config.getParameter", "isStatic", false) then
      local et = world.entityType(id)
      local f = true
      for j, vt in pairs(invalid) do
        if et == vt then 
          f = false
          break
        end
      end
      if f then return id end
    end
  end
  return nil
end

function rand()
  return math.random() / 5 + 0.9
end

function main()
  energy.update()
  if storage.active then
    if not energy.consumeEnergy() then
      setActive(false)
    end
    self.st = self.st + 1
    if self.st > 7 then 
      self.st = 0
    elseif self.st == 3 then 
      object.playImmediateSound(self.workSound)
    end
    local p = object.toAbsolutePosition({ -1.25, 1 })
    local eids = world.entityQuery(p, { p[1] + 2.5, p[2] + self.levitationHeight }, { notAnObject = true, order = "nearest" })
    local id = firstValidEntity(eids)
    if id ~= nil then
      local y = world.entityPosition(id)[2]
      object.setForceRegion({ p[1], p[2] - 0.25, p[1] + 2.5, p[2] + self.levitationHeight }, { 0, rand() * 1000 * (y - p[2]) / self.levitationHeight })
    end
  end
end