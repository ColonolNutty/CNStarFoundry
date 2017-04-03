--PIPES
StarFoundryPipesApi = {}
local starFoundryPipes = {};
local containerQuerys = {};

function starFoundryPipes.createContainerSearch(sourceId, startPos, onFound, onEnd)
  local search = {};
  search.sourceId = sourceId;
  search.current = {};
  table.insert(search.current, startPos)
  search.next = {};
	query.onFound = onFound or function() return true end;
	query.onEnd = onEnd or function() end;
  query.alive = true
  return query;
end

function StarFoundryPipesApi.searchForContainers(sourceEntityId, startPos, onContainersFound, onSearchEnd)
  local query = starFoundryPipes.createContainerSearch(sourceEntityId, startPos, onContainersFound, onSearchEnd)
  table.insert(containerQuerys, query)
  return query;
end

function StarFoundryPipesApi.update()
	for i = 1, #containerQuerys do
		if starFoundryPipes.updateQuery(containerQuerys[i]) == false then
			containerQuerys[i].active = false;
			containerQuerys[i].onEnd();
			table.remove(containerQuerys, i);
			i = i - 1;
		end
	end
end

function starFoundryPipes.updateQuery(query)
  --Treat the query as you would a linked list
  if #query.currentNodes == 0 then
    return false
  end
  for i = 1, #query.currentNodes do
    local currentNode = query.currentNodes[i];
    -- Check the container at the current node
    -- Add pipes at current node
  end
  query.currentNodes = query.nextNodes;
  query.nextNodes = {};
	return query.alive;
end


--HOOKS

--- Hook used for determining if an object connects to a specified position
-- @param pipeName string - name of the pipe type to push through
-- @param position vec2 - world position to compare node positions to
-- @param pipeDirection vec2 - direction of the pipe to see if the object connects
-- @returns node ID if successful, false if unsuccessful
function entityConnectsAt(pipeName, position, pipeDirection)
  if pipes == nil or starFoundrystarFoundryPipes.nodes[pipeName] == nil then
    return false 
  end
  local entityPos = object.position()
  
  for i,node in ipairs(starFoundrystarFoundryPipes.nodes[pipeName]) do
    local absNodePos = object.toAbsolutePosition(node.offset)
    local distance = world.distance(position, absNodePos)
    if distance[1] == 0 and distance[2] == 0 and starFoundrystarFoundryPipes.pipesConnect(node.dir, {pipeDirection}) then
      return i 
    end
  end
  return false
end

--HELPERS

--- Checks if a table (array only) contains a value
-- @param table table - table to check
-- @param value (w/e) - value to compare
-- @returns true if table contains it, false if not
function table.contains(table, value)
  for _,val in ipairs(table) do
    if value == val then return true end
  end
  return false
end

--- Copies a table (not recursive)
-- @param table table - table to copy
-- @returns copied table
function table.copy(table)
  local newTable = {}
  for i,v in pairs(table) do
    newTable[i] = v
  end
  return newTable
end

starFoundrystarFoundryPipes.directions = {
  horz = {{1,0}, {-1, 0}},
  vert = {{0, 1}, {0, -1}},
  b1 = {{1,0}, {0,1}},
  b2 = {{1, 0}, {0, -1}},
  b3 = {{-1,0}, {0, -1}},
  b4 = {{-1, 0}, {0, 1}},
  plus = {{1,0}, {-1, 0}, {0, -1}, {0, 1}},
  horizontal = {{1,0}, {-1, 0}},
  vertical = {{0, 1}, {0, -1}},
  NE = {{1,0}, {0,1}},
  SE = {{1, 0}, {0, -1}},
  SW = {{-1,0}, {0, -1}},
  NW = {{-1, 0}, {0, 1}},
  middle = {{1,0}, {-1, 0}, {0, -1}, {0, 1}}
}

--- Initialize, always run this in init (when init args == false)
-- @param pipeTypes an array of pipe types (defined in itemstarFoundryPipes.lua and liquidstarFoundryPipes.lua)
-- @returns nil
function starFoundrystarFoundryPipes.init(pipeTypes)

  starFoundrystarFoundryPipes.updateTimer = 1 --Should be set to the same as updateInterval so it gets entities on the first update
  starFoundrystarFoundryPipes.updateInterval = 1
  
  starFoundrystarFoundryPipes.types = {}
  starFoundrystarFoundryPipes.nodes = {} 
  starFoundrystarFoundryPipes.nodeEntities = {}
  
  for _,pipeType in ipairs(pipeTypes) do
    starFoundrystarFoundryPipes.types[pipeType.pipeName] = pipeType
  end
  
  for pipeName,pipeType in pairs(starFoundrystarFoundryPipes.types) do
    starFoundrystarFoundryPipes.nodes[pipeName] = config.getParameter(pipeType.nodesConfigParameter)
    starFoundrystarFoundryPipes.nodeEntities[pipeName] = {}
  end

  starFoundrystarFoundryPipes.rejectNode = {}
end

--- Push, calls the put hook on the closest connected object that returns true
-- @param pipeName string - name of the pipe type to push through
-- @param nodeId number - ID of the node to push through
-- @param args - The arguments to send to the put hook
-- @returns Hook return if successful, false if unsuccessful
function starFoundrystarFoundryPipes.push(pipeName, nodeId, args)
  if #starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId] > 0 and not starFoundrystarFoundryPipes.rejectNode[nodeId] then
    for i,entity in ipairs(starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId]) do
      starFoundrystarFoundryPipes.rejectNode[nodeId] = true
      local entityReturn = world.callScriptedEntity(object.id, starFoundrystarFoundryPipes.types[pipeName].hooks.put, args, object.nodeId)
      starFoundrystarFoundryPipes.rejectNode[nodeId] = false
      if entityReturn then return entityReturn end
    end
  end
  return false
end

--- Pull, calls the get hook on the closest connected object that returns true
-- @param pipeName string - name of the pipe type to pull through
-- @param nodeId number - ID of the node to pull through
-- @param args - The arguments to send to the hook
-- @returns Hook return if successful, false if unsuccessful
function starFoundrystarFoundryPipes.pull(pipeName, nodeId, args)
  if #starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId] > 0 and not starFoundrystarFoundryPipes.rejectNode[nodeId] then
    for i,entity in ipairs(starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId]) do
      starFoundrystarFoundryPipes.rejectNode[nodeId] = true
      local entityReturn = world.callScriptedEntity(object.id, starFoundrystarFoundryPipes.types[pipeName].hooks.get, args, object.nodeId)
      starFoundrystarFoundryPipes.rejectNode[nodeId] = false
      if entityReturn then return entityReturn end
    end
  end
  return false
end

--- Peek push, calls the peekPut hook on the closest connected object that returns true
-- @param pipeName string - name of the pipe type to peek through
-- @param nodeId number - ID of the node to peek through
-- @param args - The arguments to send to the hook
-- @returns Hook return if successful, false if unsuccessful
function starFoundrystarFoundryPipes.peekPush(pipeName, nodeId, args)
  if #starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId] > 0 and not starFoundrystarFoundryPipes.rejectNode[nodeId] then
    for i,entity in ipairs(starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId]) do
      starFoundrystarFoundryPipes.rejectNode[nodeId] = true
      local entityReturn = world.callScriptedEntity(object.id, starFoundrystarFoundryPipes.types[pipeName].hooks.peekPut, args, object.nodeId)
      starFoundrystarFoundryPipes.rejectNode[nodeId] = false
      if entityReturn then return entityReturn end
    end 
  end
  return false
end

--- Peek pull, calls the peekPull hook on the closest connected object that returns true
-- @param pipeName string - name of the pipe type to peek through
-- @param nodeId number - ID of the node to peek through
-- @param args - The arguments to send to the hook
-- @returns Hook return if successful, false if unsuccessful
function starFoundrystarFoundryPipes.peekPull(pipeName, nodeId, args)
  if #starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId] > 0 and not starFoundrystarFoundryPipes.rejectNode[nodeId] then
    for i,entity in ipairs(starFoundrystarFoundryPipes.nodeEntities[pipeName][nodeId]) do
      starFoundrystarFoundryPipes.rejectNode[nodeId] = true
      local entityReturn = world.callScriptedEntity(object.id, starFoundrystarFoundryPipes.types[pipeName].hooks.peekGet, args, object.nodeId)
      starFoundrystarFoundryPipes.rejectNode[nodeId] = false
      if entityReturn then return entityReturn end
    end
  end
  return false
end

--- Checks if two pipes connect up, direction-wise
-- @param firstDirection vec2 - vector2 of direction to match
-- @param secondDirections array of vec2s - List of directions to match against
-- @returns true if the secondDirections can connect to the firstDirection
function starFoundrystarFoundryPipes.pipesConnect(firstDirection, secondDirections)
  for _,secondDirection in ipairs(secondDirections) do
    if firstDirection[1] == -secondDirection[1] and firstDirection[2] == -secondDirection[2] then
      return true
    end
  end
  return false
end

--- Gets the directions of a tile based on tile name
-- @param pipeName string - name of the pipe type to use
-- @param position vec2 - world position to check
-- @param layer - layer to check ("foreground" or "background")
-- @returns Hook return if successful, false if unsuccessful
function starFoundrystarFoundryPipes.tileDirections(pipeName, position, layer)
  local checkedTile = world.material(position, layer)
  for _,tileType in ipairs(starFoundrystarFoundryPipes.types[pipeName].tiles) do
    if checkedTile == tileType then
      return true
    end
  end
  return false
end

--- Gets the directions + layer for a connecting pipe, prioritises the layer specified in layerMode
-- @param pipeName string - name of the pipe type to use
-- @param position vec2 - world position to check
-- @param layerMode - layer to prioritise
-- @param direction (optional) - direction to compare to, if specified it will return false if the pipe does not connect
-- @returns Hook return if successful, false if unsuccessful
function starFoundrystarFoundryPipes.getPipeTileData(pipeName, position, direction)
  local fore = "foreground"
  local back = "background"
  
  local foregroundCheck = starFoundryPipes.tileDirections(pipeName, position, fore)
  
  --Return relevant values
  if foregroundCheck then
    return foregroundCheck
  end
  
  local backgroundCheck = starFoundryPipes.tileDirections(pipeName, position, back)
  if backgroundCheck then
    return backgroundCheck
  end
  return false
end

--- Gets all the connected entities for a pipe type
-- @param pipeName string - name of the pipe type to use
-- @returns list of connected entities with format {nodeId = {{id = 1, nodeId = 1, path = {{1,0},{2,0}}}}
function starFoundryPipes.getNodeEntities(pipeName)
  local position = object.position()
  local nodeEntities = {}
  local nodesTable = {}
  
  if starFoundryPipes.nodes[pipeName] == nil then
    return {}
  end
  for i,pipeNode in ipairs(starFoundryPipes.nodes[pipeName]) do
    nodeEntities[i] = starFoundryPipes.walkPipes(pipeName, pipeNode.offset, pipeNode.dir)
  end
  return nodeEntities
  
end

--- Should be run in main
-- @param dt number - delta time
-- @returns nil
--function starFoundryPipes.update(dt)
	--starFoundryPipes.updateQuerys()
  --local position = object.position()
  --starFoundryPipes.updateTimer = starFoundryPipes.updateTimer + dt
  
  --if starFoundryPipes.updateTimer >= starFoundryPipes.updateInterval then
  
    --Get connected entities
  --  for pipeName,pipeType in pairs(starFoundryPipes.types) do
      --Get inbound
  --    starFoundryPipes.nodeEntities[pipeName] = starFoundryPipes.getNodeEntities(pipeName)
  --  end
    
  --  starFoundryPipes.updateTimer = 0
  --end
--end

--- Calls a hook on the entity to see if it connects to the specified pipe
-- @param pipeName string - name of pipe type to use
-- @param entityId number - ID of entity to check against
-- @param position vec2 - position of the pipe tile
-- @param direction vec2 - direction of the pipe tile
-- @returns nil
function starFoundryPipes.validEntity(pipeName, entityId, position)
  if world.entityExists(entityId) then
    return world.callScriptedEntity(entityId, "entityConnectsAt", pipeName, position)
  else
    return false
  end
end

--- Walks through placed pipe tiles to find connected entities
-- @param pipeName string - name of pipe type to use
-- @param startOffset vec2 - Position *relative to the object* to start looking, should be set to a node's position
-- @param startDir vec2 - Direction to start looking in, should be set to a node's direction
-- @returns List of connected entities with ID, remote Node ID, and path info, sorted by nearest-first
function starFoundryPipes.walkPipes(pipeName, startOffset, startDir)
  local validEntities = {}
  local visitedTiles = {}
  local tilesToVisit = {{pos = {startOffset[1] + startDir[1], startOffset[2] + startDir[2]}, path = {}, directionName = "initial"}}
  local prevPipe = nil
  --left, right, down up
  local directions = {{-1,0},{1,0},{0,-1},{0,1}}
  local directionNames = {"left", "right","down","up"}
  
  sb.logInfo("Walking pipes")
  
  while #tilesToVisit > 0 do
    local tile = tilesToVisit[1]
    local absTilePos = object.toAbsolutePosition(tile.pos)
    if world.tileIsOccupied(absTilePos, true) or world.tileIsOccupied(absTilePos, false) then
      --sb.logInfo("checking pipe x: " .. absTilePos[1])
      --sb.logInfo("checking pipe y: " .. absTilePos[2])
      visitedTiles[tile.pos[1].."."..tile.pos[2]] = true --Add to global visited
      local currentTileIsPipe = starFoundryPipes.getPipeTileData(pipeName, absTilePos)
      --sb.logInfo("Checking pipe direction " .. tile.directionName)
      if currentTileIsPipe then
        sb.logInfo(tile.directionName .. " Is Pipe")
        tile.path[#tile.path+1] = tile.pos --Add tile to the path
        for _,direction in ipairs(directions) do
          --If a pipe, add connected spaces to the visit list
          local newPos = {tile.pos[1] + direction[1], tile.pos[2] + direction[2]}
          local isPrevTile = tile.prevTile and newPos[1] == tile.prevTile[1] and newPos[2] == tile.prevTile[2]
          if not isPrevTile and visitedTiles[newPos[1] .. "." .. newPos[2]] == nil then --Don't check the tile we just came from, and don't check already visited ones
            local newTile = {pos = newPos, path = table.copy(tile.path), directionName = directionNames[_], prevTile = tile}
            table.insert(tilesToVisit, 2, newTile)
          end
        end
      else
        --local connectedObjects = world.objectQuery(object.toAbsolutePosition(tile.pos), 2)
        local options = { withoutEntityId = entity.id()}
        local connectedObjects = world.objectLineQuery(absTilePos, {absTilePos[1] + 1, absTilePos[2] + 2}, options)
        if connectedObjects then
          for key,objectId in ipairs(connectedObjects) do
            if objectId >= 0 then
              local entNode = starFoundryPipes.validEntity(pipeName, objectId, object.toAbsolutePosition(tile.pos))
              if objectId ~= entity.id() and entNode and table.contains(validEntities, objectId) == false then
                validEntities[#validEntities+1] = {id = objectId, nodeId = entNode, path = table.copy(tile.path)}
              end
            end
          end
        end
      end
      sb.logInfo("done checking pipe x: " .. absTilePos[1])
      sb.logInfo("done checking pipe y: " .. absTilePos[2])
      table.remove(tilesToVisit, 1)
    end
  end
  
  sb.logInfo("done checking pipes")

  table.sort(validEntities, function(a,b) return #a.path < #b.path end)
  return validEntities
end