function init(virtual)
  if not virtual then
    object.setInteractive(not object.isInputNodeConnected(0))

    if storage.tileArea == nil then
      storage.tileArea = {}
    end

    if storage.swapState == nil then
      storage.swapState = false -- false = blocks in foreground, true = blocks in background
    end

    if storage.transitionState == nil then
      storage.transitionState = 0 -- >1 = breaking, 1 = placing, 0 = passive
    end

    if storage.bgData == nil then
      storage.bgData = {}
    end

    if storage.fgData == nil then
      storage.fgData = {}
    end

    updateAnimationState()

    datawire.init()
  end
end

function updateAnimationState()
  if storage.swapState then
    animator.setAnimationState("layerState", "background")
  else
    animator.setAnimationState("layerState", "foreground")
  end
end

function onInboundNodeChange(args) 
  checkNodes()
end
 
function onNodeConnectionChange()
  datawire.onNodeConnectionChange()

  checkNodes()
  object.setInteractive(not object.isInputNodeConnected(0))
end

function checkNodes()
  if storage.transitionState == 0 then
    swapLayer(object.getInputNodeLevel(0))
  else
    self.pendingNodeChange = true
  end
end

function validateData(data, dataType, nodeId, sourceEntityId)
  return dataType == "area"
end

function onValidDataReceived(data, dataType, nodeId, sourceEntityId)
  if storage.transitionState > 0 then
    storage.pendingAreaData = data
  else
    storage.tileArea = data
  end
end

function onInteraction(args)
  if not object.isInputNodeConnected(0) and storage.transitionState == 0 then
    swapLayer(not storage.swapState)
  end
end

function swapLayer(newState)
  if newState ~= storage.swapState then
    --world.logInfo("storage.tileArea")
    --world.logInfo(storage.tileArea)

    storage.swapState = newState
    storage.transitionState = 3

    storage.bgData = scanLayer(storage.tileArea, "background")
    storage.fgData = scanLayer(storage.tileArea, "foreground")

    breakLayer(storage.tileArea, "background", false)
    breakLayer(storage.tileArea, "foreground", false)
    
    updateAnimationState()
  end
end

function main()
  datawire.update()

  --timer waits for blocks to finish being destroyed before starting placement
  if storage.transitionState > 0 then
    if storage.transitionState == 1 then
      --place stored blocks
      placeLayer(storage.tileArea, "background", storage.fgData, true)
      placeLayer(storage.tileArea, "foreground", storage.bgData, false)

      --sweep out those pesky (but handy!) invisitiles
      cleanupTransition(storage.tileArea)

      if storage.pendingAreaData then
        storage.tileArea = storage.pendingAreaData
        storage.pendingAreaData = false
      end

      if storage.pendingNodeChange then
        checkNodes()
        storage.pendingNodeChange = false
      end
    end
    storage.transitionState = storage.transitionState - 1
  end
end