--TODO: make this implement motionsensor.lua and generalize?

function init(virtual)
  if not virtual then
    object.setInteractive(true)

    self.detectArea = config.getParameter("detectArea")
    self.detectAreaOffset = config.getParameter("detectAreaOffset")
    local objPosition = object.position()
    if type(self.detectArea) == "table" then
      --build rectangle for detection using object position and specified detectAreaOffset
      if type(self.detectAreaOffset) == "table" then
        self.detectArea = {objPosition[1] + self.detectArea[1] + self.detectAreaOffset[1], objPosition[2] + self.detectArea[2] + self.detectAreaOffset[2]}
      else
        self.detectArea = {objPosition[1] + self.detectArea[1], objPosition[2] + self.detectArea[2]}
      end
    end

    if type(self.detectAreaOffset) == "table" then
      self.detectOrigin = {objPosition[1] + self.detectAreaOffset[1], objPosition[2] + self.detectAreaOffset[2]}
    else
      self.detectOrigin = objPosition
    end

    self.modes = { "maxhp", "currenthp" }
    if storage.currentMode == nil then
      storage.currentMode = self.modes[1]
    end

    updateAnimationState()

    datawire.init()
  end
end

function onNodeConnectionChange()
  datawire.onNodeConnectionChange()
end

function onInteraction()
  cycleMode()
end

function cycleMode()
  for i, mode in ipairs(self.modes) do
    if mode == storage.currentMode then
      storage.currentMode = self.modes[(i % #self.modes) + 1]
      updateAnimationState()
      return
    end
  end

  --previous mode invalid, default to mode 1
  storage.currentMode = self.modes[1]
  updateAnimationState()
end

function updateAnimationState()
  animator.setAnimationState("scannerState", storage.currentMode)
end

function doDetect()
  local entityIds = world.entityQuery(self.detectOrigin, self.detectArea, { includedTypes = {"player", "monster", "npc"}, notAnObject = true, order = "nearest" })
  local nearestValid = entityIds[1]
  onDetect(nearestValid)
end

function onDetect(entityId)
  if entityId then
    local sample
    if storage.currentMode == "currenthp" then
      sample = math.floor(world.entityHealth(entityId)[1])
    elseif storage.currentMode == "maxhp" then
      sample = math.floor(world.entityHealth(entityId)[2])
    end
    datawire.sendData(sample, "number", 0)
  else
    datawire.sendData(0, "number", 0)
  end
end

function update(dt)
  datawire.update()
  doDetect()
end