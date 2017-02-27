function init(virtual)
  if not virtual then
    self.convertLiquid = config.getParameter("liquidConversions")

    pipes.init({liquidPipe})
    
    self.usedNode = 0
  end
end

--------------------------------------------------------------------------------
function main(args)
  pipes.update(dt)
  
  local position = object.position()
  local checkDirs = {}
  checkDirs[0] = {-1, 0}
  checkDirs[1] = {0, -1}
  checkDirs[2] = {1, 0}
  checkDirs[3] = {0, 1}
  
  if #pipes.nodeEntities["liquid"] > 0 then
    for i=0,3 do 
      local angle = (math.pi / 2) * i
      if #pipes.nodeEntities["liquid"][i+1] > 0 then
        animator.rotateTransformationGroup("pipe", angle)
        self.usedNode = i + 1
      elseif i == 3 then --Not connected to an object, check for pipes instead
        for i=0,3 do 
          local angle = (math.pi / 2) * i
          local tilePos = {position[1] + checkDirs[i][1], position[2] + checkDirs[i][2]}
          local pipeDirections = pipes.getPipeTileData("liquid", tilePos, "foreground", checkDirs[i])
          if pipeDirections then
            animator.rotateTransformationGroup("pipe", angle)
            self.usedNode = i + 1
          end
        end
      end
    end
  end
end

function convertEndlessLiquid(liquid)
  for _,liquidTo in ipairs(self.convertLiquid) do
    if liquid[1] == liquidTo[1] then
      liquid[1] = liquidTo[2]
      break
    end
  end
  return liquid
end

function canGetLiquid(filter, nodeId)
  if nodeId ~= self.usedNode then return false end
  --Only get liquid if the pipe is emerged in liquid
  local position = object.position()
  local liquidPos = {position[1] + 0.5, position[2] + 0.5}
  local availableLiquid = world.liquidAt(liquidPos)
  if availableLiquid then
    local liquid = convertEndlessLiquid(availableLiquid)

    local returnLiquid = filterLiquids(filter, {liquid})
    --world.logInfo("(canGetLiquid) filter result: %s", returnLiquid)
    
    if returnLiquid then
      return returnLiquid
    end
  end
  return false
end

function canPutLiquid(liquid, nodeId)
  if nodeId ~= self.usedNode then return false end
  
  return true
end

function onLiquidGet(filter, nodeId)
  local position = object.position()
  local liquidPos = {position[1] + 0.5, position[2] + 0.5}
  local getLiquid = canGetLiquid(filter, nodeId)
  if getLiquid then
    local destroyed = world.destroyLiquid(liquidPos)
    if destroyed[2] > getLiquid[2] then
      world.spawnLiquid(liquidPos, destroyed[1], destroyed[2] - getLiquid[2])
    end
    getLiquid = convertEndlessLiquid(getLiquid)
    return getLiquid
  end
  return false
end

function onLiquidPut(liquid, nodeId)
  local position = object.position()
  local liquidPos = {position[1] + 0.5, position[2] + 0.5}
  if canPutLiquid(liquid, nodeId) then
    local curLiquid = world.liquidAt(liquidPos)
    if curLiquid then liquid[2] = liquid[2] + curLiquid[2] end
    world.spawnLiquid(liquidPos, liquid[1], liquid[2])
    return true
  else
    return false
  end
end

function beforeLiquidGet(filter, nodeId)
  return canGetLiquid(filter, nodeId)
end

function beforeLiquidPut(liquid, nodeId)
  return canPutLiquid(liquid, nodeId)
end
