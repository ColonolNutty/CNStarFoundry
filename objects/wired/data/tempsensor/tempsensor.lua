function getSample()
  --No temperature, so it'll just return room temperature
  --local sample = world.temperature(object.position())
  -- sb.logInfo(string.format("Temperature reading: %f", sample))
  return 32--math.floor(sample)
end