function getSample()
  local sample = world.windLevel(object.position())
  --sb.logInfo(string.format("Wind reading: %f", sample))
  return math.floor(math.abs(sample))
end