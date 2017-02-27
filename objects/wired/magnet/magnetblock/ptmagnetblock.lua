function init(args)
  if not args then
    if datawire then
      datawire.init()
    end
    
    storage.usesEnergy = config.getParameter("energyAllowConnection", false)
    if storage.usesEnergy then
      energy.init()
    end
    
    if storage.magnetOnAnim == nil then
      storage.magnetOnAnim = config.getParameter("chargeStrength") > 0 and "positiveOn" or "negativeOn"
    end
    
    if storage.magnetOffAnim == nil then
      storage.magnetOffAnim = config.getParameter("chargeStrength") > 0 and "positiveOff" or "negativeOff"
    end
  
    if storage.charge == nil then
      storage.charge = clamp(config.getParameter("chargeStrength"), -magnets.limit, magnets.limit)
    end
    
    if storage.magnetCenter == nil then
      storage.magnetCenter = config.getParameter("magnetCenter", {0.5, 0.5})
    end
    
    killData()
	
    object.setInteractive(storage.usesEnergy)
    object.setColliding(false)
    if storage.state == nil then
      output(not storage.usesEnergy)
    else
      output(storage.state)
    end
  end
end

function die()
  if storage.usesEnergy then 
    energy.die()
  end
  killData()
end

function killData()
  if storage.dataID ~= nil then
    world.callScriptedEntity(storage.dataID, "kill")
    storage.dataID = nil
  end
end

function onInteraction(args)
  output(not storage.state)
end

function onNodeConnectionChange()
  if datawire then
    datawire.onNodeConnectionChange()
  end
end

function onInputNodeChange(args)
  output(not storage.state)
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    object.setAllOutputNodes(state)
	
    updateMagnetData()
	
    if state then
      animator.setAnimationState("magnetState", storage.magnetOnAnim)
      animator.playSound("onSounds")
    else
      animator.setAnimationState("magnetState", storage.magnetOffAnim)
      animator.playSound("offSounds")
    end
  end
end

function update(dt)
  if storage.usesEnergy then
    energy.update()
  end
  if (storage.dataID == nil or (storage.dataID ~= nil and not world.entityExists(storage.dataID))) then
    updateMagnetData()
  end
  if datawire then
    datawire.update()
  end
  
  local charge = storage.charge
  if storage.state then -- Magnet is active
    if storage.usesEnergy and not energy.consumeEnergy(getEnergyUsage()) then
      output(false)
      return
    end
    
    -- Push monsters/npcs
    local radius = magnets.radius
    local pos = object.position()
    local ents = world.entityQuery(pos, radius, { withoutEntityId = storage.dataID, notAnObject = true })
    for key,value in pairs(ents) do
      if magnets.shouldAffect(value) then
        local ent = entityProxy.create(value)
        magnets.applyForce(ent, magnets.vecSum(pos, storage.magnetCenter), charge)
      end
    end
  end
end

-- Function for other magnets to overwrite
function getEnergyUsage()
  return nil
end

function updateMagnetData()
  killData()
  
  -- 13/9 Is the level the monster needs for the health to scale by 1
  if storage.state then
    local pos = object.position()
    pos = magnets.vecSum(pos, { 0.5, 0.5 })
    -- This dummy monster is needed for the magnetize tech to interact with magnets
    storage.dataID = world.spawnMonster("ptmagnetdata", pos, { level = (13/9), statusParameters = { baseMaxHealth = storage.charge }})
  else
    storage.dataID = nil
  end
end

function clamp(num, minimum, maximum)
  if num < minimum then
    return minimum
  elseif num > maximum then
    return maximum
  else
    return num
  end
end