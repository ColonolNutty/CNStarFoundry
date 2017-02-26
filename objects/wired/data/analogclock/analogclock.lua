function init(args)
  if not args then
    storage.zeroAngle = math.pi / 2
  end
end

function main()
  local timeOfDay = world.timeOfDay()
  local theta = storage.zeroAngle - (math.pi * 2 * timeOfDay)
  object.rotateGroup("hand", theta)
  object.setOutputNodeLevel(0, (timeOfDay <= 0.5))
end