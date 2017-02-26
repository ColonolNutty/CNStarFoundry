function init(virtual)
  if not virtual then
    pipes.init({itemPipe})

    self.dropPoint = {object.position()[1] + 0.5, object.position()[2] + 0.5} --Temporarily spawn inside until someone bothers adding several drop points based on orientation
    
    self.usedNode = 0
  end
end

--------------------------------------------------------------------------------
function main(args)
  pipes.update(object.dt())
  
  local position = object.position()
  local checkDirs = {}
  checkDirs[0] = {-1, 0}
  checkDirs[1] = {0, -1}
  checkDirs[2] = {1, 0}
  checkDirs[3] = {0, 1}
  

  if #pipes.nodeEntities["item"] > 0 then
    for i=0,3 do 
      local angle = (math.pi / 2) * i
      if #pipes.nodeEntities["item"][i+1] > 0 then
        object.rotateGroup("ejector", angle)
        self.usedNode = i + 1
      elseif i == 3 then --Not connected to an object, look for pipes instead
        for i=0,3 do 
          local angle = (math.pi / 2) * i
          local tilePos = {position[1] + checkDirs[i][1], position[2] + checkDirs[i][2]}
          local pipeDirections = pipes.getPipeTileData("item", tilePos, "foreground", checkDirs[i])
          if pipeDirections then
            object.rotateGroup("ejector", angle)
            self.usedNode = i + 1
          end
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
  --world.logInfo(item)
  --world.logInfo(nodeId)
  if item and nodeId == self.usedNode then
    local position = object.position()
    --world.logInfo("Putting item %s", item[1])
    if next(item.data) == nil then 
      world.spawnItem(item.name, self.dropPoint, item.count)
    else
      world.spawnItem(item.name, self.dropPoint, item.count, item.data)
    end
    return true
  end
  
  return false
end