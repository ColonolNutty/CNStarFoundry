function init(virtual)
  if not virtual then
    storage.state = storage.state or false
    self.nodeMap = { "top", "right", "bottom", "left" }
    checkNodes()
  end
end

function onNodeConnectionChange()
  checkNodes()
end

function onInputNodeChange(args)
  checkNodes()
end

function checkNodes()
  if object.getInputNodeLevel(0) ~= storage.state then
    storage.state = object.getInputNodeLevel(0)
    object.setAllOutputNodes(false)
    if storage.state then
      local choice = math.random(0, 3)
      object.setOutputNodeLevel(choice, true)
      animator.setAnimationState("randState", self.nodeMap[choice + 1])
    else
      animator.setAnimationState("randState", "off")
    end
  end
end