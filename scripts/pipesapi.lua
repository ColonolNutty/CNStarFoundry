--PIPES
StarFoundryPipesApi = {}
local starFoundryPipes = {};
local containerQuerys = {};

function StarFoundryPipesApi.searchForContainers(sourceEntityId, startPos, onContainersFound, onSearchEnd, pipeTypes)
  local query = starFoundryPipes.createContainerSearch(sourceEntityId, startPos, onContainersFound, onSearchEnd, pipeTypes);
  table.insert(containerQuerys, query);
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

function starFoundryPipes.createContainerSearch(sourceId, startPos, onFound, onEnd, pipeTypes)
  local search = {};
  search.sourceId = sourceId;
  search.current = {};
  table.insert(search.current, startPos);
  search.next = {};
  search.pipeList = {};
  search.searchedContainerIds = {};
  search.pipeTypes = pipeTypes;
	search.onFound = onFound or function() return true end;
	search.onEnd = onEnd or function() end;
  search.alive = true;
  return search;
end

function starFoundryPipes.updateQuery(search)
  if search.active ~= true then
    return search.alive;
  end
  --Treat the search as you would a linked list
  if #search.current == 0 then
    return false;
  end
  for i = 1, #search.current do
    local currentNode = search.current[i];
    -- Check the container at the current node and see if it can be used
    if starFoundryPipes.containerIsValid(currentNode, search) ~= true then
      return false;
    end
    -- Add pipes at current node
    starFoundryPipes.findPipes(currentNode, search);
  end
  search.current = search.next;
  search.next = {};
	return search.alive;
end

function starFoundryPipes.containerIsValid(position, search)
    local containerIds = world.objectQuery(position, 5, { withoutEntityId = search.sourceId, order = "nearest"});
    for i = 1, #containerIds do
      local containerId = containerIds[i];
      local containerSize = world.containerSize(containerId)
      if containerId ~= nil and containerId ~= search.sourceId and starFoundryPipes.shouldSearchContainer(search.searchedContainerIds, containerId) then
        if containerSize ~= nil and starFoundryPipes.doesContainerContainPosition(containerId, position) then
            table.insert(search.searchedContainerIds, containerId)
            local container = { id = containerId };
            if search.onFound(container) ~= true then
              return false;
            end
        end
      end
    end
    return true;
end

function starFoundryPipes.doesContainerContainPosition(containerId, position)
  local containerPosition = world.entityPosition(containerId);
  local containerSpaces = world.objectSpaces(containerId);
  local posX = position[1];
  local posY = position[2];
  
  for i = 1, #containerSpaces do
    local space = containerSpaces[i];
    local spaceX = world.xwrap(space[1] + containerPosition[1]);
    local spaceY = space[2] + containerPosition[2];
    if spaceX == posX and spaceY == posY then
      return true;
    end
  end
  return false;
end

function starFoundryPipes.findPipes(position, search)
  local posOne = position[1];
  local posTwo = position[2];
  starFoundryPipes.addPipe({posOne, posTwo + 1}, search);
  starFoundryPipes.addPipe({posOne, posTwo - 1}, search);
  starFoundryPipes.addPipe({world.xwrap(posOne + 1), posTwo}, search);
  starFoundryPipes.addPipe({world.xwrap(posOne - 1), posTwo}, search);
end

function starFoundryPipes.addPipe(position, search);
  local posX = position[1]
  local posY = position[2]
  local pipeAlreadyUsed = search.pipeList[posX .. "." .. posY] == nil;
  local pipeExists = pipeAlreadyUsed and starFoundryPipes.checkPipeType(position, search)
  if not pipeExists then
    return;
  end
  search.pipeList[posX .. "." .. posY] = position;
  table.insert(search.next, position);
end

function starFoundryPipes.checkPipeType(position, search)
  local worldMat = world.material(position, "background");
  for i = 1, #search.pipeTypes do
    local pipeType = search.pipeTypes[i]
    if worldMat == pipeType then
      return true;
    end
  end
  return false;
end

function starFoundryPipes.shouldSearchContainer(containerList, containerId)
  for i = 1, #containerList do
    local containerSearched = containerList[i]
    if containerSearched == containerId then
      return false;
    end
  end
  return true;
end