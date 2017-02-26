function init(virtual)
  if not virtual then
    if not storage.dataType then
      storage.dataType = "empty"
    end

    if storage.lockOutput == nil then
      storage.lockOutput = false
    end

    if storage.lockInput == nil then
      storage.lockInput = false
    end

    self.flipStr = ""
    if object.direction() == -1 then
      self.flipStr = "flipped."
    end

    updateAnimationState()

    datawire.init()
  end
end

function onInteraction(args)
  reset()
end

function onNodeConnectionChange()
  datawire.onNodeConnectionChange()
end

function onInputNodeChange(args)
  storage.lockInput = object.getInputNodeLevel(1)
  storage.lockOutput = object.getInputNodeLevel(2)

  output()
  updateAnimationState()
end

function updateAnimationState()
  if object.getInputNodeLevel(1) and object.getInputNodeLevel(2) then
    animator.setAnimationState("lockState", self.flipStr.."both")
  elseif object.getInputNodeLevel(1) then
    animator.setAnimationState("lockState", self.flipStr.."in")
  elseif object.getInputNodeLevel(2) then
    animator.setAnimationState("lockState", self.flipStr.."out")
  else
    animator.setAnimationState("lockState", self.flipStr.."none")
  end
end

function validateData(data, dataType, nodeId, sourceEntityId)
  --only receive data on node 0
  return nodeId == 0
end

function onValidDataReceived(data, dataType, nodeId, sourceEntityId)
  if not storage.lockInput then
    storage.data = data
    storage.dataType = dataType
  end
end

function output()
  if not storage.lockOutput and storage.data then
    datawire.sendData(storage.data, storage.dataType, 0)
  end
end

function update(dt)
  datawire.update()
  output()
end