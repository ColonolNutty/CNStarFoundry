function init(virtual)
  if not virtual then
    object.setInteractive(true)

    if storage.state == nil then
      storage.state = true
    end
    updateAnimationState()

    self.connectionMap = {}
    self.connectionMap[1] = 2
    self.connectionMap[2] = 1
    self.connectionMap[3] = 4
    self.connectionMap[4] = 3
  
    pipes.init({liquidPipe,itemPipe})
  end
end

--------------------------------------------------------------------------------

function onInteraction(args)
  if not object.isInputNodeConnected(0) then
    storage.state = not storage.state
    updateAnimationState()
  end
end

function onInputNodeChange(args)
  checkInputNodes()
end

function onNodeConnectionChange()
  checkInputNodes()
end

--------------------------------------------------------------------------------
function main(args)
  pipes.update(dt)
end

function checkInputNodes()
  if object.isInputNodeConnected(0) then
    object.setInteractive(false)
    storage.state = object.getInputNodeLevel(0)
    updateAnimationState()
  else
    object.setInteractive(true)
  end
end

function updateAnimationState()
  if storage.state then
    animator.setAnimationState("switchState", "on")
  else
    animator.setAnimationState("switchState", "off")
  end
end

function beforeLiquidGet(filter, nodeId)
  if storage.state then
    --world.logInfo("passing liquid peek get from %s to %s", nodeId, self.connectionMap[nodeId])
    return peekPullLiquid(self.connectionMap[nodeId], filter)
  else
    return false
  end
end

function onLiquidGet(filter, nodeId)
  if storage.state then
    --world.logInfo("passing liquid get from %s to %s", nodeId, self.connectionMap[nodeId])
    return pullLiquid(self.connectionMap[nodeId], filter)
  else
    return false
  end
end

function beforeLiquidPut(liquid, nodeId)
  if storage.state then
    --world.logInfo("passing liquid peek from %s to %s", nodeId, self.connectionMap[nodeId])
    return peekPushLiquid(self.connectionMap[nodeId], liquid)
  else
    return false
  end
end

function onLiquidPut(liquid, nodeId)
  if storage.state then
    --world.logInfo("passing liquid from %s to %s", nodeId, self.connectionMap[nodeId])
    return pushLiquid(self.connectionMap[nodeId], liquid)
  else
    return false
  end
end

function beforeItemPut(item, nodeId)
  if storage.state then
    --world.logInfo("passing item peek from %s to %s", nodeId, self.connectionMap[nodeId])
    return peekPushItem(self.connectionMap[nodeId], item)
  else
    return false
  end
end

function onItemPut(item, nodeId)
  if storage.state then
    --world.logInfo("passing item from %s to %s", nodeId, self.connectionMap[nodeId])
    return pushItem(self.connectionMap[nodeId], item)
  else
    return false
  end
end

function beforeItemGet(filter, nodeId)
  if storage.state then
    --world.logInfo("passing item peek get from %s to %s", nodeId, self.connectionMap[nodeId])
    return peekPullItem(self.connectionMap[nodeId], filter)
  else
    return false
  end
end

function onItemGet(filter, nodeId)
  if storage.state then
    --world.logInfo("passing item get from %s to %s", nodeId, self.connectionMap[nodeId])
    return pullItem(self.connectionMap[nodeId], filter)
  else
    return false
  end
end