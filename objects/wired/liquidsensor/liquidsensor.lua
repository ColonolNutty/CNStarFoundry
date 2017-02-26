function getSample()
  return world.liquidAt(object.position())
end

function update(dt)
  datawire.update()

  local sample = getSample()
  if sample then
    datawire.sendData(sample[1], "number", "all")
  else
    datawire.sendData(0, "number", "all")
  end

  if not sample then
    object.setOutputNodeLevel(0, false)
    animator.setAnimationState("sensorState", "off")
  elseif sample[1] == 1 or sample[1] == 2 then
    object.setOutputNodeLevel(0, true)
    animator.setAnimationState("sensorState", "water")
  elseif sample[1] == 4 then
    object.setOutputNodeLevel(0, true)
    animator.setAnimationState("sensorState", "poison")
  elseif sample[1] == 3 or sample[1] == 5 then
    object.setOutputNodeLevel(0, true)
    animator.setAnimationState("sensorState", "lava")
  else
    object.setOutputNodeLevel(0, true)
    animator.setAnimationState("sensorState", "other")
  end
end