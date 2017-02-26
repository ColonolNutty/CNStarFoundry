function init(virtual)
  if virtual == false then
    object.setInteractive(false)
    self.maxHealth = config.getParameter("health")
    if storage.health == nil then storage.health = self.maxHealth end
    local initState = config.getParameter("initState")
    if initState then animator.setAnimationState("blocktype", initState) end
  end
end

function setBlockState(state)
  world.logInfo("Block state: %s", state)
  
end

function damageBlock(amount)
  storage.health = storage.health - amount
  local damage = self.maxHealth - storage.health
  local damageState = tostring(math.min(math.ceil((damage / self.maxHealth) * 5), 5))
  animator.setAnimationState("damage", damageState)
  
  if storage.health <= 0 then
    object.smash()
  end
end
