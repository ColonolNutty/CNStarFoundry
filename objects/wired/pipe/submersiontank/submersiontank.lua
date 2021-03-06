function init(args)  
  object.setInteractive(true)
  if args == false then
    pipes.init({liquidPipe})
    local initInv = config.getParameter("initialInventory")
    if initInv and storage.liquid == nil then
      storage.liquid = initInv
    end
    
    animator.scaleTransformationGroup("liquid", {1, 0})
    self.liquidMap = {}
    self.liquidMap[1] = "water"
    self.liquidMap[3] = "lava"
    self.liquidMap[4] = "poison"
    self.liquidMap[6] = "juice"
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
    world.spawnItem("submersiontank", {position[1] + 1.5, position[2] + 1}, 1, {initialInventory = storage.liquid})
  else
    world.spawnItem("submersiontank", {position[1] + 1.5, position[2] + 1}, 1)
  end
end

function onInteraction(args)
  local liquid = self.liquidMap[storage.liquid[1]]
  local count = storage.liquid[2]
  local capacity = self.capacity
  local itemList = ""
  
  if liquid == nil then liquid = "other" end
  if count ~= nil then 
    return { "ShowPopup", { message = "^white;You manage to suppress the desire to climb into the tank... for now.\n\n^white;Holding ^green;" .. count ..
      "^white; / ^green;" .. capacity ..
      "^white; units of liquid ^green;" .. liquid
    }}
  else
    return { "ShowPopup", { message = "Tank is empty."}}
  end
end

function onInteractionNew(args)
  world.logInfo("SUBMERSIONTANK: onInteraction")
  return { "SitDown", {config={
    ["sitFlipDirection"] = false,
    ["sitPosition"] = {20,20},
    ["sitOrientation"] = "lay",
    ["sitAngle"] = 0,
    ["sitCoverImage"] = "/objects/wired/pipe/submersiontank.png:foreground",
    ["sitEmote"] = "sleep",
    ["sitStatusEffects"] =  {
      ["kind"] = "Nude",
    },
  }}}
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
    animator.scaleTransformationGroup("liquid", {1, liquidScale})
  else
    animator.scaleTransformationGroup("liquid", {1, 0})
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
    
    if newLiquid[2] > self.capacity then 
      excess = newLiquid[2] - self.capacity
      newLiquid[2] = self.capacity
    end
    storage.liquid = newLiquid
    
    --Try to push excess liquid
    if excess > 0 then return pushLiquid(2, {newLiquid[1], excess}) end
    return true
  end
  return false
end

function beforeLiquidPut(liquid, nodeId)
  if storage.liquid[1] == nil then
    return true
  elseif liquid and liquid[1] == storage.liquid[1] then
    local excess = 0
    local newLiquid = {liquid[1], storage.liquid[2] + liquid[2]}
    
    if newLiquid[2] > self.capacity then 
      excess = newLiquid[2] - self.capacity
    end
    
    if excess == liquid[2] then return peekPushLiquid(2, {newLiquid[1], excess}) end
    return true
  end
  return false
end

function onLiquidGet(filter, nodeId)
  if storage.liquid[1] ~= nil then
    local liquids = {{storage.liquid[1], math.min(storage.liquid[2], self.pushAmount)}}

    local returnLiquid = filterLiquids(filter, liquids)
    if returnLiquid then
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
    local liquids = {{storage.liquid[1], math.min(storage.liquid[2], self.pushAmount)}}

    local returnLiquid = filterLiquids(filter, liquids)

    return returnLiquid
  end
  return false
end
