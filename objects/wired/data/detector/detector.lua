function init(virtual)
   if not virtual then
      object.setInteractive(true)
      object.setAllOutputNodes(false)

      self.modes = config.getParameter("modes") or {"all", "owner", "player", "monster", "item", "npc"}
      storage.currentMode = storage.currentMode or self.modes[1]
      animator.setGlobalTag("modePart", storage.currentMode)

      self.detectDuration = config.getParameter("detectDuration") or 1
      self.detectCooldown = 0

      self.detectArea = {object.toAbsolutePosition({-2, -2}), object.toAbsolutePosition({2, 2})}
   end
end

function on()
   object.setAllOutputNodes(true)
   self.detectCooldown = self.detectDuration
   animator.setAnimationState("detectorState", "on")
end

function off()
   object.setAllOutputNodes(false)
   self.detectCooldown = 0
   animator.setAnimationState("detectorState", "off")
end

function onInteraction(args)
   storage.owner = world.entityName(args["sourceId"])
   cycleMode()
   off()
end

function cycleMode()
  for i, mode in ipairs(self.modes) do
    if mode == storage.currentMode then
      storage.currentMode = self.modes[(i % #self.modes) + 1]
      animator.setGlobalTag("modePart", storage.currentMode)
      return
    end
  end

  --previous mode invalid, default to mode 1
  storage.currentMode = self.modes[1]
  animator.setGlobalTag("modePart", storage.currentMode)
end

function main()
   --stupid tags don't update properly in init()
   animator.setGlobalTag("modePart", storage.currentMode)

   if self.detectCooldown > 0 then
      self.detectCooldown = self.detectCooldown - object.dt()
   else
      local entityIds = {}

      if storage.currentMode == "all" then
         entityIds = world.entityQuery(self.detectArea[1], self.detectArea[2], { notAnObject = true })
      elseif storage.currentMode == "owner" then
         for _, entityId in pairs(world.playerQuery(self.detectArea[1], self.detectArea[2], { notAnObject = true })) do
            if world.entityName(entityId) == storage.owner then
               entityIds[1] = "test"
               break
            end
         end
      elseif storage.currentMode == "player" then
         entityIds = world.playerQuery(self.detectArea[1], self.detectArea[2], { notAnObject = true })
      elseif storage.currentMode == "monster" then
         entityIds = world.monsterQuery(self.detectArea[1], self.detectArea[2], { notAnObject = true })
      elseif storage.currentMode == "item" then
         entityIds = world.itemDropQuery(self.detectArea[1], self.detectArea[2], { notAnObject = true })
      elseif storage.currentMode == "npc" then
         entityIds = world.npcQuery(self.detectArea[1], self.detectArea[2], { notAnObject = true })
      elseif storage.currentMode == "solar" then
         if world.lightLevel(pos) >= config.getParameter("lightLevel") then
            entityIds[1] = "test"
         end
      end

      if #entityIds > 0 then
         on()
      else
         off()
      end
   end
end