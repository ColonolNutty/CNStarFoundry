stationState = {}

function stationState.enter()
  if world.entityExists(self.stationId or -1) == nil then return nil end
  return { pos = world.callScriptedEntity(self.stationId, "getLandingPos") }
end

function stationState.update(dt, sd)
  local stPos = world.entityPosition(self.stationId)
  stPos = {stPos[1], stPos[2]}
  moveTo(stPos, dt)
  local pos = mcontroller.position()
  if world.magnitude(pos, sd.pos) < 0.1 then
    sb.logInfo("made it to station")
    for i,v in storageApi.getIterator() do
      local item = storageApi.returnItem(i)
      local res = world.callScriptedEntity(self.stationId, "storageApi.storeItemFit", item.id, item.name, item.count, item.data)
      if res > 0 then
        storageApi.storeItem(item.id, item.name, res, item.data) 
      end
    end
    world.callScriptedEntity(self.stationId, "droneLand", entity.id())
    return true
  end
  return false
end
