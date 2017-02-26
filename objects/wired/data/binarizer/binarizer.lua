function init(virtual)
  if not virtual then
    
    -- if storage.state == nil then
    --   storage.state = false
    -- end
    throughput()

    updateAnimationState()
  end
end

function onInputNodeChange(args)
  throughput()
end

function onNodeConnectionChange()
  throughput()
end

function throughput()
  storage.state = entity.getInputNodeLevel(0)
  object.setOutputNodeLevel(0, storage.state)
end

function updateAnimationState()
  if object.direction() == 1 then
    animator.setAnimationState("flipState", "default")
  else
    animator.setAnimationState("flipState", "flipped")
  end
end