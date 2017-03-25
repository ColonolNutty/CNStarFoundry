require "/scripts/rect.lua"

function init(v)
  energy.init()

  if storage.active == nil then storage.active = false end

  self.flipStr = ""
  if object.direction() == -1 then
    self.flipStr = "flip"
  end
  animator.setParticleEmitterActive("fanwind", false)
  animator.setParticleEmitterActive("fanwindflip", false)
  physics.setForceEnabled("right", false)
  physics.setForceEnabled("left", false)
 
  setActive(storage.active)
  -- self.affectWidth = config.getParameter("affectWidth")
  -- self.fanPower = config.getParameter("fanPower")
  self.timer = 0
  self.st = 0
  onNodeConnectionChange(nil)
end

function die()
  energy.die()
end

function onNodeConnectionChange(args)
  if object.isInputNodeConnected(0) then
    object.setInteractive(false)
  else
    object.setInteractive(true)
  end
  onInputNodeChange(args)
end

function onInputNodeChange(args)
  if object.isInputNodeConnected(0) then
    setActive(object.getInputNodeLevel(0))
  end
end

function onInteraction(args)
  setActive(not storage.active)
end

function setActive(flag, dt)
  if not flag or energy.consumeEnergy(nil, true, dt or 0) then
    animator.setParticleEmitterActive("fanwind" .. self.flipStr, flag)
    if flag then
      animator.setAnimationState("fanState", "work")
    elseif storage.active then
      animator.setAnimationState("fanState", "slow")
      self.timer = 20
    else
      animator.setAnimationState("fanState", "idle")
    end
    storage.active = flag
  else
    sb.logInfo("stopping all")
    physics.setForceEnabled("right", false)
    physics.setForceEnabled("left", false)
  end
end


function update(dt)
  energy.update(dt)
  if storage.active then
    if not energy.consumeEnergy(nil, nil, dt) then
      setActive(false, dt)
      return
    end
    self.st = self.st + 1
    if self.st > 6 then 
      self.st = 0
    end
    local d = object.direction();
    -- local p = object.position();
    -- local region;
    -- local x1;
    -- local y1;
    -- local x2;
    -- local y2;
    -- if d == 1 then
      -- x1 = p[1]
      -- y1 = p[2] - 1
      -- x2 = p[1] + d * self.affectWidth
      -- y2 = p[2] + 1
    -- else
      -- x1 = p[1] + d * self.affectWidth
      -- y1 = p[2] - 1
      -- x2 = p[1]
      -- y2 = p[2] + 1
    -- end
    -- sb.logInfo("Direction: " .. d)
    -- sb.logInfo("current position of air fan:")
    -- sb.logInfo("X1: " .. p[1])
    -- sb.logInfo("Y1: " .. p[2])
    -- sb.logInfo("Rect region of air fan:")
    -- sb.logInfo("1a: " .. x1)
    -- sb.logInfo("2a: " .. y1)
    -- sb.logInfo("3a: " .. x2)
    -- sb.logInfo("4a: " .. y2)
    -- region = {x1, y1, x2, y2};
    physics.setForceEnabled("right", false)
    physics.setForceEnabled("left", false)
    physics.setForceEnabled((d > 0 and "right") or "left", true)
    return
  elseif self.timer > 0 then
    self.timer = self.timer - 1
    if self.timer == 1 then 
      animator.setAnimationState("fanState", "idle") 
    end
  end
  physics.setForceEnabled("right", false)
  physics.setForceEnabled("left", false)
end
