function init(args)
    entity.setGravityEnabled(false)
    object.setDamageOnTouch(false)
    object.setDeathParticleBurst(config.getParameter("deathParticles"))
    object.setDeathSound(entity.randomizeParameter("deathNoise"))
    self.dead = false
end

function damage()
    self.dead = true
end
function shouldDie()
    return self.dead
end

function collide(args)
    entity.setVelocity({0,0})
    --animator.setAnimationState("movement", "idle")
end

function dig(args)
    entity.setVelocity({0,0})
    --animator.setAnimationState("movement", "idle")
end

function move(args)
    entity.setVelocity(args.velocity)
    animator.scaleTransformationGroup("chain", { 1, args.chain })
    --animator.setAnimationState("movement", "dig")
end

function burstParticleEmitter()
    if self.emitter then
        self.emitter = self.emitter - 1
        if self.emitter == 0 then
            animator.setParticleEmitterActive("dig", false)
            self.emitter = false
        end
    end
end