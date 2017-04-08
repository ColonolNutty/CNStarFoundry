require "/scripts/pipes/itempipes.lua"
require "/scripts/pipesapi.lua"

local activeQuery = nil;

function init(virtual)
  if not virtual then
    storage.pipeTypes = itemPipe.tiles;

    storage.timer = 0
    storage.pickupCooldown = 0.2

    storage.ignoreIds = {}
    local objPosition = object.position()
    storage.dropPoint = {world.xwrap(objPosition[1] + 1), objPosition[2] + 1.5}
  end
end

--------------------------------------------------------------------------------
function update(dt, args)
  StarFoundryPipesApi.update()
  --local shouldUpdate = storage.timer > storage.pickupCooldown and (isItemNodeConnected(1) or isItemNodeConnected(2))
  local result = false;
  local items = world.containerItems(entity.id())
  local itemCount = 0;
  for key, item in pairs(items) do
    itemCount = itemCount + item.count;
  end
  if itemCount <= 0 then
    if activeQuery ~= nil then
      activeQuery.active = false;
    end
    return
  end
  local pos = object.position();
  if activeQuery == nil then
    activeQuery = StarFoundryPipesApi.searchForContainers(entity.id(), pos, onContainerFound, onContainerNotFound, storage.pipeTypes)
  else
    activeQuery.active = true;
  end
end

function findItemDrops()
  local pos = object.position()
  return world.itemDropQuery(pos, {pos[1] + 2, pos[2] + 1})
end

function ejectItem(item)
  local itemDropId = world.spawnItem(item.name, storage.dropPoint, item.count)
  storage.ignoreIds[itemDropId] = true
end

function onContainerFound(container)
  local items = world.containerItems(entity.id());
  local containerId = container.id;
  local totalcount = 0;
  for key, item in pairs(items) do
    local fitCount = world.containerItemsCanFit(containerId, item)
    if fitCount ~= nil and fitCount == item.count then
        totalcount = totalcount + item.count;
        world.containerAddItems(containerId, item);
        world.containerConsume(entity.id(), item);
    end
  end
  if totalcount <= 0 then
    return true;
  end
  return false;
end

function onContainerNotFound()
  activeQuery.active = false
  activeQuery = nil
  local items = world.containerItems(entity.id());
  for key, item in pairs(items) do
    ejectItem(item)
  end
  --Removes the items
  world.containerTakeAll(entity.id());
end