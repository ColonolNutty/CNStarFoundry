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
  output(not storage.state)

  animator.playSound("on");
  storage.timer = self.interval
end

function onNpcPlay(npcId)		
  onInteraction()		
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    object.setAllOutputNodes(state)
    if state then
      animator.setAnimationState("switchState", "on")
      animator.playSound("on");
    else
      animator.setAnimationState("switchState", "off")
      animator.playSound("off");
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
