function getSample()
  local sample = world.lightLevel(object.position())
  return math.floor(sample * 1000) * 0.1
end