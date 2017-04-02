function init()
  animator.setAnimationState("movement", "start")
  self.rect = { -1, -1, 1, 1 }
  if storageApi.isInit() then
    storageApi.init({ mode = 1, capacity = 4, merge = true, ondeath = 1 })
  end
  local states = stateMachine.scanScripts(config.getParameter("scripts"), "(%a+State)%.lua")
  self.state = stateMachine.create(states)
  if storage.stationPos == nil then
    storage.stationPos = config.getParameter("stationPos")
  end
  if storage.active == nil then storage.active = true end
  if (self.stationId == nil) or not world.entityExists(self.stationId) then
    local ids = world.objectQuery(storage.stationPos, 1, { name = "dronestation", callScript = "droneRegister", callScriptArgs = { entity.id() } })
    for _,v in pairs(ids) do
      self.stationId = v
      break
    end
  end
  self.start = 2
  if storage.fuel == nil then
    storage.fuel = 50
  end
  astarApi.setConfig({ diagonal = true })
end

function setActive(flag)
  storage.active = flag
end

function die()
  if world.entityExists(self.stationId or -1) then
    world.callScriptedEntity(self.stationId or -1, "droneDeath", entity.id())
  end
  storageApi.die(mcontroller.position())
end

function onLanding()
  animator.setAnimationState("movement", "start")
  entity.setDeathParticleBurst(nil)
  self.dead = true
  return storage.fuel or 0
end

function shouldDie()
  return self.dead or not world.entityExists(self.stationId or -1)
end

function moveTo(pos, dt)
  return astarApi.flyTo(pos, self.rect)
end

function update(dt, stateData)
  if not self.dead then
    if not world.entityExists(self.stationId or -1) then
      self.dead = true
    elseif self.start > 0 then
      mcontroller.setVelocity({ 0, 0.15 })
      self.start = self.start - dt
      if self.start <= 0 then
        animator.setAnimationState("movement", "fly")
      end
    else
      if storage.fuel > 0 then
        --sb.logInfo("decreasing fuel by " .. dt * 2)
        storage.fuel = storage.fuel - dt * 2
      end
      self.state.update(dt)
    end
  end
  if storage.fuel <= 0 then
    self.dead = true
  end
end