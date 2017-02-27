function init(virtual)
  if not virtual then
    -- Every Initialization
    datawire.init()
  end
end

function getSample()
  return world.liquidAt(object.position())
end

function onNodeConnectionChange()
--sb.logInfo("(liquid) node change")
  datawire.onNodeConnectionChange()
end

function update(dt)
  datawire.update()
  
  local sample = getSample()
  if sample == nil then
	if storage.lastSample ~= nil then
		datawire.sendData(0, "number", "all")
	end
	storage.lastSample = nil
  else
	  if storage.lastSample ~= sample[1] then
	      if storage.lastSample ~= nil then
			--sb.logInfo(" last sample " .. storage.lastSample)
		  end
		  storage.lastSample = sample[1]
		  datawire.sendData(sample[1], "number", "all")
	  end
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