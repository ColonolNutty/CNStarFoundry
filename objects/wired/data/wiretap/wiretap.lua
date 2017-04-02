

function init(virtual)
  if not virtual then
    if storage.fingerpint == nil then
      -- First Initialization
      storage.fingerprint = object.position()[1] .. "." ..object.position()[2]
      storage.name = storage.fingerprint
      storage.logStack = {}
      animator.setAnimationState("tapState", "on")
    else
      -- Re-Initialization
    end
    -- Every Initialization
    datawire.init()
    object.setInteractive(true)
    storage.currentData = ""
  end
end

function update(dt)
  datawire.update()
end

function onInteraction(args)
  -- need to make custom interface for this, popup sucks
  return { "ShowPopup", { message = getPopupString() }}
end

function onNodeConnectionChange()
--sb.logInfo("(wiretap) node change")
  datawire.onNodeConnectionChange()
end

function validateData(data, dataType, nodeId, sourceEntityId)
  --only receive data on node 0
  return nodeId == 0
end

function onValidDataReceived(data, dataType, nodeId, sourceEntityId)
  logInfo(data, dataType)
  datawire.sendData(data, dataType, 0)
end

function logInfo(data, dataType)

	--sb.logInfo("(wiretap) saving data to the log")

  if dataType == "number" then
    if storage.prevData == nil or data == storage.prevData then
      logString = "^white;" .. dataType .. " : " .. data
    elseif data > storage.prevData then
      logString = "^white;" .. dataType .. " : ^green;" .. data
    else
      logString = "^white;" .. dataType .. " : ^red;" .. data
    end
  else
    logString = "^white;" .. dataType .. " : " .. data
  end
  storage.prevData = data
  storage.currentData = data
  if not storage.currentData then
    storage.currentData = ""
  end

  -- I'm using some dirty 'features' of # here
  -- while the full, list will have keys 0-10,  # will still return 10
  -- This is just a poor-man's stack, with a max of 10 entries.
  --if #storage.logStack >= 10 then
  --  for i = 1, 10, 1 do
  --    storage.logStack[i - 1] = storage.logStack[i]
  --  end
  --  storage.logStack[10] = logString
  --else
  --  storage.logStack[#storage.logStack + 1] = logString
 --end
end

function getPopupString()
  popupString = ""
  if storage.currentData then
    popupString = popupString.. "\n^green;" .. 1 .. ") ^white;" .. storage.currentData
  end
  --for i = 1, #storage.logStack, 1 do
  --  popupString = popupString.. "\n^green;" .. i .. ") ^white;" .. storage.logStack[i]
  --end
  if popupString == "" then
    return "^red;No Data Collected"
  else
    -- Unknown data will be possible with datawire.lua update in future
    popupString = "^green;Device: ^red;Unknown\n^green;Coords: ^red;Unknown\n" .. popupString
    return popupString
  end
end

function name(newName)
  storage.name = newName
end