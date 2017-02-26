function init(args)
  if not virtual then
    storage.pos = {object.position(), {object.position()[1] + 1, object.position()[2]}, {object.position()[1] - 1, object.position()[2]}}
    if storage.state == nil then
      output(false)
    else
      output(storage.state)
    end
  end
end

-- Change Animation
function output(state)
  if state ~= storage.state then
    storage.state = state
    if state then
      animator.setAnimationState("drainState", "on")
    else
      animator.setAnimationState("drainState", "off")
    end
  end
end

-- Removes Liquids at current position
function drain()
  if world.liquidAt(storage.pos[1])then
    world.destroyLiquid(storage.pos[1])
  end
end

function main()
  if not object.isInputNodeConnected(0) or object.getInputNodeLevel(0) then
    output(true)
    drain()
  else
    output(false)
  end
end