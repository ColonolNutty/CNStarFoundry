function init(virtual)
  if not virtual then
    energy.init()

    self.particleCooldown = 0.2
    self.particleTimer = 0

    self.acceptCharge = config.getParameter("acceptCharge") or true

    animator.setParticleEmitterActive("charging", false)
    updateAnimationState()
  end
end

function die()
  local position = object.position()
  if energy.getEnergy() == 0 then
    world.spawnItem("cnsfbattery", {position[1] + 0.5, position[2] + 1}, 1)
  elseif not energy.canReceiveEnergy() then
    world.spawnItem("fullbattery", {position[1] + 0.5, position[2] + 1}, 1, { savedEnergy = energy.getEnergy()})
  else
    world.spawnItem("cnsfbattery", {position[1] + 0.5, position[2] + 1}, 1, { savedEnergy = energy.getEnergy()})
  end

  energy.die()
end

function isBattery()
  return true
end

function getBatteryStatus()
  return {
    id = entity.id(),
    capacity = energy.getCapacity(),
    energy = energy.getEnergy(),
    unusedCapacity = energy.getUnusedCapacity(),
    position = object.position(),
    acceptCharge = self.acceptCharge
  }
end

function onEnergyChange(newAmount)
  updateAnimationState()
end

function showChargeEffect()
  animator.setParticleEmitterActive("charging", true)
  self.particleTimer = self.particleCooldown
end

function updateAnimationState()
  local chargeAmt = energy.getEnergy() / energy.getCapacity()
  animator.resetTransformationGroup("chargebar")
  animator.scaleTransformationGroup("chargebar", {1, chargeAmt})
end

function update(dt)
  if self.particleTimer > 0 then
    self.particleTimer = self.particleTimer - dt
    if self.particleTimer <= 0 then
      animator.setParticleEmitterActive("charging", false)
    end
  end

  energy.update(dt)
end