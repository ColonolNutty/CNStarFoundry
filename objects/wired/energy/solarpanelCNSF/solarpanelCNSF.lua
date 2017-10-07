function init(virtual)
    if not virtual then
        energy.init()

        if storage.state == nil then
           storage.state = true
        end

        updateAnimationState()
        storage.lightLevelThreshold = config.getParameter("lightLevelThreshold")
    end
end

function update(dt)
  energy.update(dt)
  local lightLevel = getLightLevel()
  sb.logInfo("lightLevel: " .. lightLevel)
  if(not isEnoughLight(lightLevel) or not checkSolar()) then
    return
  end
  energy.generateEnergy(lightLevel * dt)
  updateAnimationState()
end

function getLightLevel()
  if(onShip()) then
    return 1.0
  end
  return world.lightLevel(object.position())
end

function isEnoughLight(lightLevel)
  return lightLevel < storage.lightLevelThreshold
end

function updateAnimationState()
   if storage.state then
      animator.setAnimationState("solarState", "on")
   else
      animator.setAnimationState("solarState", "off")
   end
end

function onShip()
  local worldType = world.type()
  return worldType == "unknown"
end

-- Check requirements for solar generation
function checkSolar()
  return (onShip() or (world.timeOfDay() <= 0.5 and not world.underground(object.position()))) and clearSkiesAbove()
end

function clearSkiesAbove()
  local ll = object.toAbsolutePosition({ -2.0, 1.0 })
  local tr = object.toAbsolutePosition({ 2.0, 200.0 })
  
  local bounds = {0, 0, 0, 0}
  bounds[1] = ll[1]
  bounds[2] = ll[2]
  bounds[3] = tr[1]
  bounds[4] = tr[2]
  
  return not world.rectCollision(bounds)
end

--- Energy
function onEnergySendCheck()
   if storage.state then
      return energy.getEnergy()
   else
      return 0
   end
end

--never accept energy from elsewhere
function onEnergyNeedsCheck(energyNeeds)
   energyNeeds[tostring(entity.id())] = 0
   return energyNeeds
end

function die()
  energy.die()
end
