function love.load()
    -- Prevent blurry sprites
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- About Player
    player = {}
    player.x = 400
    player.y = 200
    
    player.angle = 0
    player.rotationSpeed = 6.0
    player.fastTurn = false
    
    player.moveSpeed = 0
    player.walkSpeed = 1
    player.sprintSpeed = 2

    player.maxStamina = 300
    player.stamina = player.maxStamina/2
    player.staminaRegen = 50
    player.staminaDrain = 100
    player.staminaCooldown = player.staminaCooldown or 0
    player.wasSprinting = false

    player.moveState = "standing"
    player.aimState = "notaiming"

    -- Player sprite
    player.sprite = love.graphics.newImage('sprites/player.png')

    -- Background sprite
    background = love.graphics.newImage('sprites/background.png')

    -- Debugging
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.update(dt)
    UpdateAimState(dt)
    
    -- Update player controls (keyboard movement)
    PlayerMovement(dt)

    -- Anythign related to stamina
    ManageStamina(dt)

    -- Make the player face the mouse (rotate, but don't move with it)
    UpdatePlayerRotation(dt)
end

function love.draw()
    -- Draw the background
    DrawBackground()

    -- Draw the player sprite rotated to face the mouse without repositioning it
    DrawPlayer()

    -- Text to screen
    Debug()
end

function PlayerMovement(dt)
    local isMoving = love.keyboard.isDown("w") or love.keyboard.isDown("s") or 
                     love.keyboard.isDown("d") or love.keyboard.isDown("a")

    -- LShift sprint (only if moving and stamina is available)
    if not isMoving then
        player.moveState = "standing"
    elseif love.keyboard.isDown("lshift") and isMoving and player.stamina > 0 then 
        -- LShift sprint (only if moving and stamina is available)
        player.moveSpeed = player.sprintSpeed
        player.moveState = "sprinting"
    else
        -- Walking state
        player.moveSpeed = player.walkSpeed
        player.moveState = "walking"
    end

    -- If the player is aiming, reduce movement speed by 50%
    if player.aimState == "aiming" then
        player.moveSpeed = player.moveSpeed * 0.5
    end

    -- WASD movement
    if love.keyboard.isDown("w") then player.y = player.y - player.moveSpeed end
    if love.keyboard.isDown("s") then player.y = player.y + player.moveSpeed end
    if love.keyboard.isDown("d") then player.x = player.x + player.moveSpeed end
    if love.keyboard.isDown("a") then player.x = player.x - player.moveSpeed end
end

function ManageStamina(dt)
    if player.moveState == "sprinting" then
        -- While sprinting: drain stamina and reset cooldown.
        player.stamina = math.max(player.stamina - player.staminaDrain * dt, 0)
        player.staminaCooldown = 0
        player.wasSprinting = true  -- Mark that we were sprinting.
    else
        -- If the player just stopped sprinting, initiate a 2-second cooldown.
        if player.wasSprinting and player.staminaCooldown <= 0 then
            player.staminaCooldown = 2  -- Start 2 second cooldown.
            player.wasSprinting = false  -- Reset the flag so cooldown is triggered only once.
        end

        -- If cooldown is active, count it down.
        if player.staminaCooldown > 0 then
            player.staminaCooldown = player.staminaCooldown - dt
        -- Once cooldown is finished, regenerate stamina.
        elseif player.stamina < player.maxStamina then
            player.stamina = math.min(player.stamina + player.staminaRegen * dt, player.maxStamina)
        end
    end
end

function UpdatePlayerRotation(dt)
    if love.mouse.isDown(2) then
        -- Rotate toward the mouse pointer when right-click is held.
        local mouseX, mouseY = love.mouse.getPosition()
        local dx = mouseX - player.x
        local dy = mouseY - player.y
        local targetAngle = math.atan2(dy, dx)
        rotateTowards(targetAngle, dt, true)
    else
        -- Otherwise, rotate toward the movement direction (if any)
        local moveX, moveY = 0, 0
        if love.keyboard.isDown("w") then moveY = moveY - 1 end
        if love.keyboard.isDown("s") then moveY = moveY + 1 end
        if love.keyboard.isDown("a") then moveX = moveX - 1 end
        if love.keyboard.isDown("d") then moveX = moveX + 1 end

        -- Only update rotation if there is some movement.
        if moveX ~= 0 or moveY ~= 0 then
            local targetAngle = math.atan2(moveY, moveX)
            rotateTowards(targetAngle, dt, false)
        end
    end
end

-- Helper function to smoothly rotate the player toward a target angle.
function rotateTowards(targetAngle, dt, useMouse)
    -- Calculate the shortest angular difference.
    local diff = (targetAngle - player.angle + math.pi) % (2 * math.pi) - math.pi
    local angleDifferenceDegrees = math.abs(diff * (180 / math.pi))

    -- Determine rotation speed based on current stamina fraction.
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

    -- Ensure fast turn only happens when rotating towards the mouse
    if useMouse and staminaFraction > 0.5 and angleDifferenceDegrees > 75 then
        player.fastTurn = true
        player.rotationSpeed = player.rotationSpeed * 1.5 -- 50% faster turning.
    else
        player.fastTurn = false
    end

    -- If the difference is small, snap to the target; otherwise, rotate incrementally.
    if math.abs(diff) < player.rotationSpeed * dt then
        player.angle = targetAngle
    else
        player.angle = player.angle + player.rotationSpeed * dt * (diff > 0 and 1 or -1)
    end
end

function DrawPlayer()
    love.graphics.draw(
        player.sprite,
        player.x, player.y,           -- Position
        player.angle,                 -- Rotation
        0.25, 0.25,                     -- Scale factors
        player.sprite:getWidth()/2,    -- Origin x (pivot at center)
        player.sprite:getHeight()/2    -- Origin y (pivot at center)
    )
end

function DrawBackground()
    love.graphics.draw(background, 0, 0)
end

-- Function to update the player's aim state
function UpdateAimState(dt)
    if love.mouse.isDown(2) then
        player.aimState = "aiming"
    else
        player.aimState = "notaiming"
    end
end

function Debug()
    love.graphics.print("moveState: " .. player.moveState, screenWidth - 140, 10)
    love.graphics.print("stamina: " .. player.stamina, screenWidth - 130, 40)
    love.graphics.print("staminaCooldown: " .. player.staminaCooldown, screenWidth - 160, 70)
    love.graphics.print("moveSpeed: " .. player.moveSpeed, screenWidth - 120, 100)
    love.graphics.print("rotationSpeed: " .. player.rotationSpeed, screenWidth - 120, 130)
    
    local fastTurnStatus = player.fastTurn and "ACTIVE" or "INACTIVE"
    love.graphics.print("fastTurn: " .. fastTurnStatus, screenWidth - 120, 160)
    love.graphics.print("aimState: " .. player.aimState, screenWidth - 140, 190)
    love.graphics.print("staminaRegen: " .. player.staminaRegen, screenWidth - 160, 220)
end
