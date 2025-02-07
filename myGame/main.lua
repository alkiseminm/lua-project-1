function love.load()
    -- Prevent blurry sprites
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- About Player
    player = {}
    player.x = 400
    player.y = 200
    
    player.moveSpeed = 0
    player.walkSpeed = 1
    player.sprintSpeed = 2

    player.maxStamina = 300
    player.stamina = player.maxStamina/2
    player.staminaRegen = 50
    player.staminaDrain = 100
    player.staminaCooldown = player.staminaCooldown or 0
    player.wasSprinting = false

    player.state = "standing"

    -- Player sprite
    player.sprite = love.graphics.newImage('sprites/player.png')

    -- Background sprite
    background = love.graphics.newImage('sprites/background.png')

    -- Debugging
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.update(dt)
    -- Update player controls (keyboard movement)
    PlayerMovement(dt)

    -- Anythign related to stamina
    ManageStamina(dt)

    -- Make the player face the mouse (rotate, but don't move with it)
    UpdatePlayerRotation()
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
        player.state = "standing"
    elseif love.keyboard.isDown("lshift") and isMoving and player.stamina > 0 then 
        -- LShift sprint (only if moving and stamina is available)
        player.moveSpeed = player.sprintSpeed
        player.state = "sprinting"
    else
        -- Walking state
        player.moveSpeed = player.walkSpeed
        player.state = "walking"
    end

    -- WASD movement
    if love.keyboard.isDown("w") then player.y = player.y - player.moveSpeed end
    if love.keyboard.isDown("s") then player.y = player.y + player.moveSpeed end
    if love.keyboard.isDown("d") then player.x = player.x + player.moveSpeed end
    if love.keyboard.isDown("a") then player.x = player.x - player.moveSpeed end
end

function ManageStamina(dt)
    if player.state == "sprinting" then
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

function UpdatePlayerRotation()
    -- Get the mouse position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Calculate the angle between the player and the mouse
    local dx = mouseX - player.x
    local dy = mouseY - player.y
    player.angle = math.atan2(dy, dx)  -- This gives the angle to face the mouse
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

function Debug()
    love.graphics.print(player.state, screenWidth - 100, 10)
    love.graphics.print(player.stamina, screenWidth - 100, 40)
    love.graphics.print(player.staminaCooldown, screenWidth - 100, 70)
    love.graphics.print(player.moveSpeed, screenWidth - 100, 100)
end
