function init(virtual)
  if not virtual then
    storage.targetAngle = 0
    setTargetPosition()

    object.setInteractive(true)
  end
end

function onInteraction(args)
  cycleTarget()
end

function cycleTarget()
  storage.targetAngle = (storage.targetAngle + (math.pi / 2)) % (2 * math.pi)
  setTargetPosition()
end

function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function setTargetPosition()
  animator.resetTransformationGroup("target")
  local rotationAngle = storage.targetAngle
  local currentLocation = rotationAngle / (math.pi * 2)
  local targetXtranslation = 0
  local targetYtranslation = 0
  if currentLocation >= 0.5 and currentLocation < 1.0 then
    targetXtranslation = -1
  end
  if currentLocation <= 0.5 and currentLocation > 0.0 then
    targetYtranslation = -1
  end
  -- 1 is up, 2 is left, 3 is down, 4 is right
  local targetDirection = (currentLocation / 0.25) + 1
  animator.translateTransformationGroup("target", {targetXtranslation, targetYtranslation})
  animator.rotateTransformationGroup("target", rotationAngle)
  local pos = object.position()
  local tarX
  local tarY
  --up
  if targetDirection == 1 then
    tarX = pos[1]
    tarY = pos[2] + 2
  else
   --left
    if targetDirection == 2 then
      tarX = pos[1] - 2
      tarY = pos[2]
    else
      --down
      if targetDirection == 3 then
        tarX = pos[1]
        tarY = pos[2] - 2
      --right
      else
        tarX = pos[1] + 2
        tarY = pos[2]
      end
    end
  end
  self.clickPos = {tarX, tarY}
end

function onNodeConnectionChange()
  checkNodes()
end

function onInputNodeChange(args)
  checkNodes()
end

function checkNodes()
  if object.getInputNodeLevel(0) and not storage.state then
    click()
  end
  storage.state = object.getInputNodeLevel(0)
end

function click()
  if animator.animationState("clickState") ~= "on" then
    animator.setAnimationState("clickState", "on")
    local interactArgs = { source = object.position(), sourceId = entity.id() }

    local eIds = world.entityQuery(self.clickPos, 1.5, { 
      withoutEntityId = entity.id(),
      boundMode  = "position"
    })

    for i, eId in ipairs(eIds) do
      if world.entityType(eId) == "object" then
        world.callScriptedEntity(eId, "onInteraction", interactArgs)
      end
    end
  end
end