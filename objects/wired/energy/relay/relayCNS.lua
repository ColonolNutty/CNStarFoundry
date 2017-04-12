function init(virtual)
  if not virtual then
    storage.variant = storage.variant or "default"
    energy.init()
  end
end

function die()
  energy.die()
end

function energy.isRelay()
  return true
end

function onEnergyNeedsCheck(energyNeeds)
  energyNeeds[tostring(object.id())] = -1 -- -1 is just a hack to mark relays for ordering
  return energy.energyNeedsQuery(energyNeeds)
end

function update(dt)
  energy.update(dt)
end

function setRelayVariant(newTag)
  storage.variant = newTag
end

-- this will have to wait until setGlobalTag works properly
-- function setRelayVariant(newTag)
--   --animator.setGlobalTag("variant", "default") --thrashin it like Tony Hawk's Pro Skater
--   animator.setGlobalTag("variant", newTag)
--   return true
-- end