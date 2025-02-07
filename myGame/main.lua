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

    -- Player sprite
    player.sprite = love.graphics.newImage('sprites/player.png')

    -- Background sprite
    background = love.graphics.newImage('sprites/background.png')
end

function love.update(dt)
    -- Update player controls (keyboard movement)
    PlayerMovement()

    -- Make the player face the mouse (rotate, but don't move with it)
    UpdatePlayerRotation()
end

function love.draw()
    -- Draw the background
    DrawBackground()

    -- Draw the player sprite rotated to face the mouse without repositioning it
    DrawPlayer()
end

function PlayerMovement()
    
    -- LShift sprint
    if love.keyboard.isDown("lshift") then 
        player.moveSpeed = player.sprintSpeed
    elseif not love.keyboard.isDown("lshift") then
        player.moveSpeed = player.walkSpeed
    end
    
    -- WASD movement
    if love.keyboard.isDown("w") then player.y = player.y - player.moveSpeed end
    if love.keyboard.isDown("s") then player.y = player.y + player.moveSpeed end
    if love.keyboard.isDown("d") then player.x = player.x + player.moveSpeed end
    if love.keyboard.isDown("a") then player.x = player.x - player.moveSpeed end
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
