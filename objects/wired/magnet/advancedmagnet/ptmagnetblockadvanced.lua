
function validateData(data, dataType, nodeId, sourceEntityId)
  return dataType == "number"
end

function onValidDataReceived(data, dataType, nodeId, sourceEntityId)
  storage.charge = clamp(data * 20, -magnets.limit, magnets.limit)
  storage.magnetOnAnim = storage.charge == 0 and "positiveOn" or (storage.charge > 0 and "positiveOn" or "negativeOn")
  storage.magnetOffAnim = storage.charge == 0 and "positiveOff" or (storage.charge > 0 and "positiveOff" or "negativeOff")
  if storage.state then
    animator.setAnimationState("magnetState", storage.magnetOnAnim)
    updateMagnetData()
  else
    animator.setAnimationState("magnetState", storage.magnetOffAnim)
  end
end

function getEnergyUsage()
  return (math.abs(storage.charge) / 100) * 5 * dt
end

function energy.getProjectileSourcePosition()
  return {object.position()[1] + 1, object.position()[2] + 1}
end