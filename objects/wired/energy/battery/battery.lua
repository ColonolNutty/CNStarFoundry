function init(virtual)
  if not virtual then
    energy.init()

    self.particleCooldown = 0.2
    self.particleTimer = 0

    self.acceptCharge = config.getParameter("acceptCharge") or true

    object.setParticleEmitterActive("charging", false)
    updateAnimationState()
  end
end

function die()
  local position = object.position()
  if energy.getEnergy() == 0 then
    world.spawnItem("battery", {position[1] + 0.5, position[2] + 1}, 1)
  elseif energy.getUnusedCapacity() == 0 then
    world.spawnItem("fullbattery", {position[1] + 0.5, position[2] + 1}, 1, {savedEnergy=energy.getEnergy()})
  else
    world.spawnItem("battery", {position[1] + 0.5, position[2] + 1}, 1, {savedEnergy=energy.getEnergy()})
  end

  energy.die()
end

function isBattery()
  return true
end

function getBatteryStatus()
  return {
    id=object.id(),
    capacity=energy.getCapacity(),
    energy=energy.getEnergy(),
    unusedCapacity=energy.getUnusedCapacity(),
    position=object.position(),
    acceptCharge=self.acceptCharge
  }
end

function onEnergyChange(newAmount)
  updateAnimationState()
end

function showChargeEffect()
  object.setParticleEmitterActive("charging", true)
  self.particleTimer = self.particleCooldown
end

function updateAnimationState()
  local chargeAmt = energy.getEnergy() / energy.getCapacity()
  object.scaleGroup("chargebar", {1, chargeAmt})
end

function main()
  if self.particleTimer > 0 then
    self.particleTimer = self.particleTimer - object.dt()
    if self.particleTimer <= 0 then
      object.setParticleEmitterActive("charging", false)
    end
  end

  energy.update()
end