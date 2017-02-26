function init(args)
  object.setInteractive(true)

  if storage.state == nil then
    output(false)
  else
    output(storage.state)
  end

  if storage.triggered == nil then
    storage.triggered = false
  end
end

function onInteraction(args)
  output(not storage.state)
end

function onInboundNodeChange(args)
  checkInputNodes()
end

function onNodeConnectionChange(args)
  checkInputNodes()
end

function checkInputNodes()
  if object.inputNodeCount() > 0 and object.getInputNodeLevel(0) then
    output(not storage.state)
  end
end

function output(state)
  storage.state = state
  if state then
    animator.setAnimationState("switchState", "on")
    animator.playSound("onSounds");
    object.setAllOutputNodes(true)
  else
    animator.setAnimationState("switchState", "off")
    animator.playSound("offSounds");
    object.setAllOutputNodes(false)
  end
end