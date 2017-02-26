function init(args)  
  object.setInteractive(true)
  if args == false then
    pipes.init({liquidPipe})
    local initInv = config.getParameter("initialInventory")
    if initInv and storage.liquid == nil then
      storage.liquid = initInv
    end
    
    object.scaleGroup("liquid", {1, 0})
    self.liquidMap = {}
    self.liquidMap[1] = "water"
    self.liquidMap[3] = "lava"
    self.liquidMap[4] = "poison"
    self.liquidMap[6] = "tentacle juice"
    self.liquidMap[7] = "tar"
    
    self.capacity = config.getParameter("liquidCapacity")
    self.pushAmount = config.getParameter("liquidPushAmount")
    self.pushRate = config.getParameter("liquidPushRate")
    
    if storage.liquid == nil then storage.liquid = {} end
    
    self.pushTimer = 0
  end
end

function die()
  local position = object.position()
  if storage.liquid[1] ~= nil then
    world.spawnItem("liquidtank", {position[1] + 1.5, position[2] + 1}, 1, {initialInventory = storage.liquid})
  else
    world.spawnItem("liquidtank", {position[1] + 1.5, position[2] + 1}, 1)
  end
end


function onInteraction(args)
  local liquid = self.liquidMap[storage.liquid[1]]
  local count = storage.liquid[2]
  local capacity = self.capacity
  local itemList = ""
  
  if liquid == nil then liquid = "other" end

  local popupMessage
  if count ~= nil then
    popupMessage = string.format("^white;Holding ^green;%d^white; / ^green;%d^white; units of liquid ^green;%s", count, capacity, liquid)
  else
    popupMessage = "Tank is empty."
  end
  return { "ShowPopup", { message = popupMessage }}
end

function main(args)
  pipes.update(dt)
  
  local liquidState = self.liquidMap[storage.liquid[1]]
  if liquidState then
    animator.setAnimationState("liquid", liquidState)
  else
    animator.setAnimationState("liquid", "other")
  end
  
  if storage.liquid[2] then
    local liquidScale = storage.liquid[2] / self.capacity
    object.scaleGroup("liquid", {1, liquidScale})
  else
    object.scaleGroup("liquid", {1, 0})
  end
  
  if self.pushTimer > self.pushRate and storage.liquid[2] ~= nil then
    local pushedLiquid = {storage.liquid[1], storage.liquid[2]}
    if storage.liquid[2] > self.pushAmount then pushedLiquid[2] = self.pushAmount end
    for i=1,2 do
      if object.getInputNodeLevel(i-1) and pushLiquid(i, pushedLiquid) then
        storage.liquid[2] = storage.liquid[2] - pushedLiquid[2]
        break;
      end
    end
    self.pushTimer = 0
  end
  self.pushTimer = self.pushTimer + dt
  
  clearLiquid()
end

function clearLiquid()
  if storage.liquid[2] ~= nil and storage.liquid[2] == 0 then
    storage.liquid = {}
  end
end

function onLiquidPut(liquid, nodeId)
  if storage.liquid[1] == nil then
    storage.liquid = liquid
    return true
  elseif liquid and liquid[1] == storage.liquid[1] then
    local excess = 0
    local newLiquid = {liquid[1], storage.liquid[2] + liquid[2]}
    local nodeMap = {2, 1}
    
    if newLiquid[2] > self.capacity then 
      excess = newLiquid[2] - self.capacity
      newLiquid[2] = self.capacity
    end
    storage.liquid = newLiquid
    
    --Try to push excess liquid
    if excess > 0 and (object.isInputNodeConnected(nodeMap[nodeId]-1) == false or object.getInputNodeLevel(nodeMap[nodeId]-1)) then 
      return pushLiquid(nodeMap[nodeId], {newLiquid[1], excess}) 
    elseif excess ~= liquid[2] then
      return true
    end
  end
  return false
end

function beforeLiquidPut(liquid, nodeId)
  if storage.liquid[1] == nil then
    return true
  elseif liquid and liquid[1] == storage.liquid[1] then
    local excess = 0
    local newLiquid = {liquid[1], storage.liquid[2] + liquid[2]}
    local nodeMap = {2, 1}
    
    if newLiquid[2] > self.capacity then 
      excess = newLiquid[2] - self.capacity
    end
    
    if excess == liquid[2] and (object.isInputNodeConnected(nodeMap[nodeId]-1) == false or object.getInputNodeLevel(nodeMap[nodeId]-1)) then
      return peekPushLiquid(nodeMap[nodeId], {newLiquid[1], excess}) 
    elseif excess < liquid[2] then
      return true
    end
  end
  return false
end

function onLiquidGet(filter, nodeId)
  if storage.liquid[1] ~= nil then
    local liquids = {{storage.liquid[1], storage.liquid[2]}}

    local returnLiquid = filterLiquids(filter, liquids)
    if returnLiquid then
      if filter == nil and returnLiquid[2] > self.pushAmount then returnLiquid[2] = self.pushAmount end
      
      storage.liquid[2] = storage.liquid[2] - returnLiquid[2]
      if storage.liquid[2] <= 0 then
        storage.liquid = {}
      end

      return returnLiquid
    end
  end
  return false
end

function beforeLiquidGet(filter, nodeId)
  if storage.liquid[1] ~= nil then
    local liquids = {{storage.liquid[1], storage.liquid[2]}}

    local returnLiquid = filterLiquids(filter, liquids)
    if filter == nil and returnLiquid[2] > self.pushAmount then returnLiquid[2] = self.pushAmount end
    return returnLiquid
  end
  return false
end
