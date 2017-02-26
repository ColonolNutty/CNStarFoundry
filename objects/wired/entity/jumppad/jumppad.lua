function init(v)
  energy.init()
  self.jumpt = 0
  self.boostPower = config.getParameter("boostPower")
  self.jumpSound = config.getParameter("jumpSound")
  self.energyPerJump = config.getParameter("energyPerJump")
end

function die()
  energy.die()
end

function firstValidEntity(eids)
  local invalid = { "object", "projectile", "plant", "effect" }
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

function update(dt)
  energy.update()
  if self.jumpt > 0 then 
    self.jumpt = self.jumpt - 1
  else
    local p = object.toAbsolutePosition({ -1.3, 1 })
    local eids = world.entityQuery(p, { p[1] + 2.6, p[2] }, { notAnObject = true, order = "nearest" })
    if firstValidEntity(eids) ~= nil then
      if energy.consumeEnergy(self.energyPerJump) then
        object.setForceRegion({ p[1], p[2], p[1] + 2.6, p[2] }, { 0, self.boostPower })
        self.jumpt = 7
      end
    end
  end
  local state = animator.animationState("jumpState")
  if state == "idle" and self.jumpt > 0 then
    animator.setAnimationState("jumpState", "jump")
    object.playImmediateSound(self.jumpSound)
  elseif state == "jump" and self.jumpt < 1 then
    animator.setAnimationState("jumpState", "idle") 
  end
end