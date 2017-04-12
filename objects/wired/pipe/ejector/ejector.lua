require "/scripts/pipes/itempipes.lua"
require "/scripts/pipesapi.lua"

local activeQuery = nil;

function init(virtual)
  if not virtual then
    storage.pipeTypes = itemPipe.tiles;
    
    local objPosition = object.position()
    storage.dropPoint = {objPosition[1] + 0.5, objPosition[2] + 0.5}
    
    storage.usedNode = 0
  end
end

function update(dt, args)
  StarFoundryPipesApi.update()
  
  if activeQuery == nil then
    activeQuery = StarFoundryPipesApi.searchForContainers(entity.id(), object.position(), onContainerFound, onContainerNotFound, storage.pipeTypes)
    activeQuery.active = true;
  end
end

function ejectItem(item)
  world.spawnItem(item.name, storage.dropPoint, item.count)
end

function onContainerFound(container)
  local containerId = container.id;
  local containerItems = world.containerItems(containerId);
  for _,item in pairs(containerItems) do
    world.containerConsumeAt(containerId, _ - 1, item.count)
    ejectItem(item);
  end
  return true;
end

function onContainerNotFound()
  activeQuery = nil;
end