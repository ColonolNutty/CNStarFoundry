function getSample()
  local sample = world.temperature(object.position())
  -- sb.logInfo(string.format("Temperature reading: %f", sample))
  return math.floor(sample)
end