function init(virtual)
  if not virtual then
    pipes.init({itemPipe})
    local objPosition = object.position()
    self.dropPoint = {objPosition[1] + 0.5, objPosition[2] + 0.5} --Temporarily spawn inside until someone bothers adding several drop points based on orientation
    
    self.usedNode = 0
  end
end

--------------------------------------------------------------------------------
function update(dt, args)
  pipes.update(dt)
  
  local position = object.position()
  local checkDirs = {}
  checkDirs[0] = {-1, 0}
  checkDirs[1] = {0, -1}
  checkDirs[2] = {1, 0}
  checkDirs[3] = {0, 1}
  

  if #pipes.nodeEntities["item"] <= 0 then
    return
  end
  
  local angle = 0
  for i= 0, 3 do
    angle = (math.pi / 2) * i
    if #pipes.nodeEntities["item"][i+1] > 0 then
      animator.resetTransformationGroup("ejector")
      animator.rotateTransformationGroup("ejector", angle)
      self.usedNode = i + 1
    elseif i == 3 then --Not connected to an object, look for pipes instead
      for i= 0, 3 do
        angle = (math.pi / 2) * i
        local tilePos = {position[1] + checkDirs[i][1], position[2] + checkDirs[i][2]}
        local pipeDirections = pipes.getPipeTileData("item", tilePos, "foreground", checkDirs[i])
        if pipeDirections then
          animator.resetTransformationGroup("ejector")
          animator.rotateTransformationGroup("ejector", angle)
          self.usedNode = i + 1
        end
      end
    end
  end
end

function beforeItemPut(item, nodeId)
  if nodeId == self.usedNode then
    return true
  end
end

function onItemPut(item, nodeId)
  --sb.logInfo(item)
  --sb.logInfo(nodeId)
  local itemPut = item and nodeId == self.usedNode
  if itemPut then
    local position = object.position()
    --sb.logInfo("Putting item %s", item[1])
    if next(item.data) == nil then 
      world.spawnItem(item.name, self.dropPoint, item.count)
    else
      world.spawnItem(item.name, self.dropPoint, item.count, item.data)
    end
  end
  return itemPut
end