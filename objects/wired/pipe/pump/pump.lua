function init(virtual)
  if virtual == false then
    object.setInteractive(true)
    
    pipes.init({liquidPipe})
    energy.init()
    
    animator.setAnimationState("pumping", "idle")
    
    self.pumping = false
    self.pumpRate = config.getParameter("pumpRate")
    self.pumpTimer = 0

    buildFilter()
    
    if storage.state == nil then storage.state = false end
  end
end

function onInboundNodeChange(args)
  storage.state = args.level
end

function onNodeConnectionChange()
  storage.state = object.getInputNodeLevel(0)
end

function onInteraction(args)
  --pump liquid
  if object.isInputNodeConnected(0) == false then
    storage.state = not storage.state
  end
end

function die()
  energy.die()
end

function main(args)
  pipes.update(object.dt())
  energy.update()
  
  if storage.state then
    local srcNode
    local tarNode
    if object.direction() == 1 then
      srcNode = 1
      tarNode = 2
    else
      srcNode = 2
      tarNode = 1
    end
    
    if self.pumpTimer > self.pumpRate then
      local canGetLiquid = peekPullLiquid(srcNode, self.filter)
      local canPutLiquid = peekPushLiquid(tarNode, canGetLiquid)

      if canGetLiquid and canPutLiquid and energy.consumeEnergy() then
        animator.setAnimationState("pumping", "pump")
        object.setAllOutputNodes(true)
        
        local liquid = pullLiquid(srcNode, self.filter)
        pushLiquid(tarNode, liquid)
      else
        object.setAllOutputNodes(false)
        animator.setAnimationState("pumping", "error")
      end
      self.pumpTimer = 0
    end
    self.pumpTimer = self.pumpTimer + object.dt()
  else
    animator.setAnimationState("pumping", "idle")
    object.setAllOutputNodes(false)
  end
end

function buildFilter()
  local pullAmount = config.getParameter("pumpAmount")
  self.filter = {}
  for i = 0, 7 do
    self.filter[tostring(i)] = {1, pullAmount}
  end
end