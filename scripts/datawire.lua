local enableDebug = false;

datawire = {}

--- this should be called by the implementing object in its own init()
function datawire.init()
  datawire.inboundConnections = {}
  datawire.outboundConnections = {}

  datawire.initialized = false
end

--- this should be called by the implementing object in its own onNodeConnectionChange()
function datawire.onNodeConnectionChange()
  datawire.createConnectionTable()
end

--- any datawire operations that need to be run when update() is first called
function datawire.update()
  if datawire.initialized then
    -- nothing for now
  else
    datawire.initAfterLoading()
    if initAfterLoading then initAfterLoading() end
  end
end

-------------------------------------------

--- this will be called internally, to build connection tables once the world has fully loaded
function datawire.initAfterLoading()
  datawire.createConnectionTable()
  datawire.initialized = true
end

--- Creates connection tables for inbound and outbound nodes
function datawire.createConnectionTable()
  datawire.outboundConnections = {}
  logData("(datawire) creating outputs ")
  local i = 0
  while i < object.outputNodeCount() do
    logData("(datawire) found some outputs")
    local connInfo = object.getOutputNodeIds(i)
    local entityIds = {}
    for k, v in pairs(connInfo) do
      logData("(datawire) creating outputs with " .. k)
      entityIds[#entityIds + 1] = k
    end
    datawire.outboundConnections[i] = entityIds
    i = i + 1
  end

  datawire.inboundConnections = {}
  logData("(datawire) creating inputs")
  local connInfos
  i = 0
  while i < object.inputNodeCount() do
    logData("(datawire) found some inputs")
    connInfos = object.getInputNodeIds(i)
    for j, connInfo in pairs(connInfos) do
      datawire.inboundConnections[j] = i
      logData("(datawire) creating inputs with " .. j)
      logData("(datawire) creating inputs with " .. connInfo)
    end
    i = i + 1
  end

  logData(string.format("%s (id %d) created connection tables for %d outbound and %d inbound nodes", config.getParameter("objectName"), entity.id(), object.outputNodeCount(), object.outputNodeCount()))
  logData("outbound: %s", datawire.outboundConnections)
  logData("inbound: %s", datawire.inboundConnections)
end

--- determine whether there is a valid recipient on the specified outbound node
-- @param nodeId the node to be queried
-- @returns true if there is a recipient connected to the node
function datawire.isOutboundNodeConnected(nodeId)
  return datawire.outboundConnections and datawire.outboundConnections[nodeId] and #datawire.outboundConnections[nodeId] > 0
end

--- Sends data to another datawire object
-- @param data the data to be sent
-- @param dataType the data type to be sent ("boolean", "number", "string", "area", etc.)
-- @param nodeId the outbound node id to send to, or "all" for all outbound nodes
-- @returns true if at least one object successfully received the data
function datawire.sendData(data, dataType, nodeId)
  -- don't transmit if connection tables haven't been built
  if not datawire.initialized then
    logData("Not ready yet")
    return false
  end
  
  logData("(datawire) Sending data")

  local transmitSuccess = false

  if nodeId == "all" then
    for k, v in pairs(datawire.outboundConnections) do
      logData("(datawire) Sending data to output " .. k)
      transmitSuccess = datawire.sendData(data, dataType, k) or transmitSuccess
    end
  else
    if datawire.outboundConnections[nodeId] and #datawire.outboundConnections[nodeId] > 0 then 
      for i, entityId in ipairs(datawire.outboundConnections[nodeId]) do
        logData("sending data to " .. entityId)
        if entityId ~= entity.id() then
          transmitSuccess = world.callScriptedEntity(entityId, "datawire.receiveData", { data, dataType, entity.id() }) or transmitSuccess
        end
      end
    end
  end

  if not transmitSuccess then
    logData(string.format("DataWire: %s (id %d) FAILED to send data of type %s", config.getParameter("objectName"), entity.id(), dataType))
    logData(data)
  end

  return transmitSuccess
end

--- Receives data from another datawire object
-- @param data (args[1]) the data received
-- @param dataType (args[2]) the data type received ("boolean", "number", "string", "area", etc.)
-- @param sourceEntityId (args[3]) the id of the sending entity, which can be use for an imperfect node association
-- @param sourceName (args[4]) the name of the object sending data
-- @returns true if valid data was received
function datawire.receiveData(args)
  --unpack args
  local data = args[1]
  local dataType = args[2]
  local sourceEntityId = args[3]
  local sourceName = world.callScriptedEntity(sourceEntityId, "config.getParameter", "objectName")
  
  logData("receiving " .. data .. " from " .. sourceEntityId .. " in " .. entity.id() .. " my name is " .. object.name())

  logData("%s %d sent me this %s %s", sourceName, sourceEntityId, dataType, data)

  --convert entityId to nodeId
  local nodeId = datawire.inboundConnections[sourceEntityId]
  
  if nodeId == nil then
    logData("Data not received from: " .. sourceName)
    return false
  elseif validateData and validateData(data, dataType, nodeId, sourceEntityId) then
    if onValidDataReceived then
      onValidDataReceived(data, dataType, nodeId, sourceEntityId)
    end

    logData(string.format("DataWire: %s received data of type %s from %d", config.getParameter("objectName"), dataType, sourceEntityId))
    return true
  else
    logData("DataWire: %s received INVALID data of type %s from entity %d: %s", config.getParameter("objectName"), dataType, sourceEntityId, data)
    return false
  end
end

function logData(msg)
  if enableDebug then
    sb.logInfo(msg)
  end
end