function init(args)
  object.setInteractive(true)
  
  if args == false then
    pipes.init({itemPipe})
    
    local initInv = config.getParameter("initialInventory")
    if initInv and storage.sApi == nil then
      storage.sApi = initInv
    end

    storageApi.init({ mode = 3, capacity = 16, merge = true })
    
    animator.scaleTransformationGroup("invbar", {2, 0})
    
    if object.direction() < 0 then
      animator.setAnimationState("flipped", "left")
    end
    
    self.pushRate = config.getParameter("itemPushRate")
    self.pushTimer = 0
  end
end

function die()
  local position = object.position()
  if storageApi.getCount() == 0 then
    world.spawnItem("itembox", {position[1] + 1.5, position[2] + 1}, 1)
  else
    world.spawnItem("itembox", {position[1] + 1.5, position[2] + 1}, 1, {initialInventory = storage.sApi})
  end
end

function onInteraction(args)
  local count = storageApi.getCount()
  local capacity = storageApi.getCapacity()
  local itemList = ""
  
  for _,item in storageApi.getIterator() do
    itemList = itemList .. "^green;" .. item.name .. "^white; x " .. item.count .. ", "
  end
  
  return { "ShowPopup", { message = "^white;Holding ^green;" .. count ..
									"^white; / ^green;" .. capacity ..
                  "^white; stacks of items." ..
                  "\n\nStorage: " ..
                  itemList
									}}
end

function main(args)
  pipes.update(dt)
  
  --Scale inventory bar
  local relStorage = storageApi.getCount() / storageApi.getCapacity()
  animator.scaleTransformationGroup("invbar", {2, relStorage})
  if relStorage < 0.5 then 
    animator.setAnimationState("invbar", "low")
  elseif relStorage < 1 then
    animator.setAnimationState("invbar", "medium")
  else
    animator.setAnimationState("invbar", "full")
  end
  
  --Push out items if switched on
  if self.pushTimer > self.pushRate then
    pushItems()
    self.pushTimer = 0
  end
  self.pushTimer = self.pushTimer + dt
end

function pushItems()
  for node = 0, 1 do
    if object.getInputNodeLevel(node) then
      for i, item in storageApi.getIterator() do
        local result = pushItem(node+1, item)
        if result == true then storageApi.returnItem(i) end --Whole stack was accepted
        if result and result ~= true then item.count = item.count - result end --Only part of the stack was accepted
        if result then break end
      end
    end
  end
end

function onItemPut(item, nodeId)
  if item and not object.getInputNodeLevel(nodeId - 1) then
    return storageApi.storeItem(item.name, item.count, item.data)
  end
  return false
end

function beforeItemPut(item, nodeId)
  if item and not object.getInputNodeLevel(nodeId - 1) then
    return not storageApi.isFull() --TODO: Make this use the future function for fitting in a stack of items
  end
  return false
end

function onItemGet(filter, nodeId)
  if filter then
    for i,item in storageApi.getIterator() do
      for filterString,amount  in pairs(filter) do
        if item.name == filterString and item.count >= amount[1] then
          if item.count <= amount[2] then
            return storageApi.returnItem(i)
          else
            item.count = item.count - amount[2]
            return {name = item.name, count = amount[2], data = item.data}
          end
        end
      end
    end
  else
    for i,item in storageApi.getIterator() do
      return storageApi.returnItem(i)
    end
  end
  return false
end

function beforeItemGet(filter, nodeId)
  if filter then
    for i,item in storageApi.getIterator() do
      for filterString,amount  in ipairs(filter) do
        if item.name == filterString and item.count >= amount[1] then
          return true 
        end
      end
    end
  else
    for i,item in storageApi.getIterator() do
      return true
    end
  end
  return false
end