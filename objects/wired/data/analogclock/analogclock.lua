function init(args)
  if not args then
    storage.zeroAngle = math.pi / 2
  end
end

function update(dt)
  local timeOfDay = world.timeOfDay()
  local theta = storage.zeroAngle - (math.pi * 2 * timeOfDay)
  animator.rotateTransformationGroup("hand", theta)
  object.setOutputNodeLevel(0, (timeOfDay <= 0.5))
end