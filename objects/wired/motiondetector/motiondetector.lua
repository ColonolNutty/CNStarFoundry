function init(args)
  self.detectArea = config.getParameter("detectArea")
  self.detectAreaOffset = config.getParameter("detectAreaOffset")

  --compute the origin or bottom left corner for detection
  if type(self.detectAreaOffset) == "table" then
    self.detectOrigin = {object.position()[1] + self.detectAreaOffset[1], object.position()[2] + self.detectAreaOffset[2]}
  else
    self.detectOrigin = object.position()
  end

  --compute top right corner for detection (if area rectangular)
  if type(self.detectArea) == "table" then
    
    if type(self.detectAreaOffset) == "table" then
      self.detectArea = {object.position()[1] + self.detectArea[1] + self.detectAreaOffset[1], object.position()[2] + self.detectArea[2] + self.detectAreaOffset[2]}
    else
      self.detectArea = {object.position()[1] + self.detectArea[1], object.position()[2] + self.detectArea[2]}
    end
  end

  --allow triggering through manual interaction if specified
  object.setInteractive(config.getParameter("manualTrigger") ~= nil and config.getParameter("manualTrigger"))

  --define valid entity types (defaults to player, monster and npc)
  self.detectEntityTypes = config.getParameter("detectEntityTypes")
  if self.detectEntityTypes == nil then
    self.detectEntityTypes = {"player", "monster", "npc"}
  end

  --define time to stay active after detecting
  self.timeout = config.getParameter("timeout")
  if self.timeout == nil then
    self.timeout = 0.1
  end

  object.setAllOutputNodes(false)
  animator.setAnimationState("switchState", "off")
  self.cooldown = 0
end

function trigger()
  object.setAllOutputNodes(true)
  animator.setAnimationState("switchState", "on")
  self.cooldown = self.timeout
end

function onInteraction(args)
  trigger()
end

function onEntityDetected(entityId, entityType)
  --hook for derivative scripts (e.g. target.lua)
end

function onTick()
  --hook for derivative scripts (e.g. target.lua)
end

function validateEntities(entityIds)
  for i, entityId in ipairs(entityIds) do
    local entityType = world.entityType(entityId)
    for j, detectEntityType in ipairs(self.detectEntityTypes) do
      if entityType == detectEntityType then
        onEntityDetected(entityId, entityType)
        return true
      end
    end
  end
  
  return false
end

function main() 
  if self.cooldown > 0 then
    self.cooldown = self.cooldown - object.dt()
  else
    if self.cooldown <= 0 then
      local entityIds = world.entityQuery(self.detectOrigin, self.detectArea, { notAnObject = true, order = "nearest" })
      if #entityIds > 0 and validateEntities(entityIds) then
        trigger()
      else
        object.setAllOutputNodes(false)
        animator.setAnimationState("switchState", "off")
      end
    end
  end

  onTick()
end