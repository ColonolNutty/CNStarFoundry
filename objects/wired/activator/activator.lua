function init(virtual)
  if not virtual then
    self.zeroAngle = -math.pi / 2
    storage.targetAngle = (storage.targetAngle and storage.targetAngle % (2 * math.pi)) or 0
    setTargetPosition()

    object.setInteractive(true)
  end
end

function onInteraction(args)
  cycleTarget()
end

function cycleTarget()
  storage.targetAngle = storage.targetAngle - (math.pi / 2)
  setTargetPosition()
end

function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function setTargetPosition()
  animator.rotateGroup("target", self.zeroAngle + storage.targetAngle)
  local pos = object.position()
  local tarX = math.round(math.cos(storage.targetAngle) * 2) + pos[1] + 0.5
  local tarY = math.round(math.sin(storage.targetAngle) * 2) + pos[2] + 0.5
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
    local interactArgs = { source = object.position(), sourceId = object.id() }

    local eIds = world.entityLineQuery(self.clickPos, self.clickPos, { withoutEntityId = object.id() })

    for i, eId in ipairs(eIds) do
      if world.entityType(eId) == "object" then
        --world.logInfo("clicking %d the %s", eId, world.entityName(eId))
        world.callScriptedEntity(eId, "onInteraction", interactArgs)
      end
    end
  end
end