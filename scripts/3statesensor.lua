local enableDebug = false;

function init(virtual)
  if not virtual then
    self.detectThresholdHigh = config.getParameter("detectThresholdHigh")
    self.detectThresholdLow = config.getParameter("detectThresholdLow")

    datawire.init()
  end
end

function onNodeConnectionChange()
  datawire.onNodeConnectionChange()
end

function getSample()
  --to be implemented by sensor
  return false
end

function update(dt)
  datawire.update()
  
  local sample = getSample()
  datawire.sendData(sample, "number", "all")

  if sample >= self.detectThresholdLow then
    object.setOutputNodeLevel(0, true)
    animator.setAnimationState("sensorState", "med")
  else
    object.setOutputNodeLevel(0, false)
    animator.setAnimationState("sensorState", "min")
  end

  if sample >= self.detectThresholdHigh then
    object.setOutputNodeLevel(1, true)
    animator.setAnimationState("sensorState", "max")
  else
    object.setOutputNodeLevel(1, false)
  end
end