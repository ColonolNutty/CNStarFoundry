function init()
 object.setInteractive(true)
  if storage.state == nil then
    output(false)
  else
    output(storage.state)
  end
  if storage.timer == nil then
    storage.timer = 0
  end
  self.interval = config.getParameter("interval")
end

function onInteraction(args)
  if storage.state == false then
    output(true)
  end

  animator.playSound("onSounds");
  storage.timer = self.interval
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    object.setAllOutboundNodes(state)
    if state then
      animator.setAnimationState("switchState", "on")
      animator.playSound("onSounds");
    else
      animator.setAnimationState("switchState", "off")
      animator.playSound("offSounds");
    end
  else
  end
end

function main()
  if storage.timer > 0 then
    storage.timer = storage.timer - 1

    if storage.timer == 0 then
      output(false)
    end
  end
end
