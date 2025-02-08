-- playerScript.lua

local playerScript = {}

-- Initialize the player and its properties.
function playerScript.load()
    playerScript.player = {
        x = 400,
        y = 200,
        angle = 0,
        rotationSpeed = 6.0,
        fastTurn = false,
        moveSpeed = 0,
        walkSpeed = 1,
        sprintSpeed = 2,
        maxStamina = 300,
        stamina = 300 / 2,  -- Start with half stamina.
        staminaRegen = 50,
        staminaDrain = 100,
        staminaCooldown = 0,
        wasSprinting = false,
        moveState = "standing",
        aimState = "notaiming",
        sprite = love.graphics.newImage('sprites/player.png')
    }
end

-- Update the player every frame.
function playerScript.update(dt)
    playerScript.UpdateAimState(dt)
    playerScript.PlayerMovement(dt)
    playerScript.ManageStamina(dt)
    playerScript.UpdatePlayerRotation(dt)
end

-- Draw the player.
function playerScript.draw()
    playerScript.DrawPlayer()
end

---------------------------------------------------
-- Player Movement and State Functions
---------------------------------------------------

function playerScript.PlayerMovement(dt)
    local player = playerScript.player
    local isMoving = love.keyboard.isDown("w") or love.keyboard.isDown("s") or 
                     love.keyboard.isDown("d") or love.keyboard.isDown("a")

    if not isMoving then
        player.moveState = "standing"
        player.moveSpeed = 0
    elseif love.keyboard.isDown("lshift") and isMoving and player.stamina > 0 then 
        player.moveSpeed = player.sprintSpeed
        player.moveState = "sprinting"
    else
        player.moveSpeed = player.walkSpeed
        player.moveState = "walking"
    end

    -- Reduce speed if aiming.
    if player.aimState == "aiming" then
        player.moveSpeed = player.moveSpeed * 0.5
    end

    -- WASD movement.
    if love.keyboard.isDown("w") then player.y = player.y - player.moveSpeed end
    if love.keyboard.isDown("s") then player.y = player.y + player.moveSpeed end
    if love.keyboard.isDown("d") then player.x = player.x + player.moveSpeed end
    if love.keyboard.isDown("a") then player.x = player.x - player.moveSpeed end
end

function playerScript.ManageStamina(dt)
    local player = playerScript.player
    if player.moveState == "sprinting" then
        player.stamina = math.max(player.stamina - player.staminaDrain * dt, 0)
        player.staminaCooldown = 0
        player.wasSprinting = true
    else
        if player.wasSprinting and player.staminaCooldown <= 0 then
            player.staminaCooldown = 2  -- 2-second cooldown.
            player.wasSprinting = false
        end

        if player.staminaCooldown > 0 then
            player.staminaCooldown = player.staminaCooldown - dt
        elseif player.stamina < player.maxStamina then
            player.stamina = math.min(player.stamina + player.staminaRegen * dt, player.maxStamina)
        end
    end
end

---------------------------------------------------
-- Player Rotation Functions
---------------------------------------------------

function playerScript.UpdatePlayerRotation(dt)
    local player = playerScript.player
    if love.mouse.isDown(2) then
        -- Rotate toward the mouse pointer when right-click is held.
        local mouseX, mouseY = love.mouse.getPosition()
        local dx = mouseX - player.x
        local dy = mouseY - player.y
        local targetAngle = math.atan2(dy, dx)
        playerScript.rotateTowards(targetAngle, dt, true)
    else
        -- Rotate toward the movement direction (if any).
        local moveX, moveY = 0, 0
        if love.keyboard.isDown("w") then moveY = moveY - 1 end
        if love.keyboard.isDown("s") then moveY = moveY + 1 end
        if love.keyboard.isDown("a") then moveX = moveX - 1 end
        if love.keyboard.isDown("d") then moveX = moveX + 1 end

        if moveX ~= 0 or moveY ~= 0 then
            local targetAngle = math.atan2(moveY, moveX)
            playerScript.rotateTowards(targetAngle, dt, false)
        end
    end
end

-- Smoothly rotate the player toward a target angle.
function playerScript.rotateTowards(targetAngle, dt, useMouse)
    local player = playerScript.player
    local diff = (targetAngle - player.angle + math.pi) % (2 * math.pi) - math.pi
    local angleDifferenceDegrees = math.abs(diff * (180 / math.pi))
    
    local staminaFraction = player.stamina / player.maxStamina
    if staminaFraction >= 0.8 then
        player.rotationSpeed = 6.0
    elseif staminaFraction >= 0.2 then
        player.rotationSpeed = 5.0
    elseif staminaFraction >= 0.1 then
        player.rotationSpeed = 4.0
    else
        player.rotationSpeed = 3.0
    end

    if useMouse and staminaFraction > 0.5 and angleDifferenceDegrees > 60 then
        player.fastTurn = true
        player.rotationSpeed = player.rotationSpeed * 1.5 -- 50% faster.
    else
        player.fastTurn = false
    end

    if math.abs(diff) < player.rotationSpeed * dt then
        player.angle = targetAngle
    else
        player.angle = player.angle + player.rotationSpeed * dt * (diff > 0 and 1 or -1)
    end
end

---------------------------------------------------
-- Drawing and Aim State
---------------------------------------------------

function playerScript.DrawPlayer()
    local player = playerScript.player
    love.graphics.draw(
        player.sprite,
        player.x, player.y,     -- Position.
        player.angle,           -- Rotation.
        0.25, 0.25,             -- Scale.
        player.sprite:getWidth() / 2,  -- Origin x (pivot at center).
        player.sprite:getHeight() / 2  -- Origin y (pivot at center).
    )
end

function playerScript.UpdateAimState(dt)
    local player = playerScript.player
    if love.mouse.isDown(2) then
        player.aimState = "aiming"
    else
        player.aimState = "notaiming"
    end
end

return playerScript
