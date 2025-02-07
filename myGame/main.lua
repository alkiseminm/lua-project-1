function love.load()
    -- Prevent blurry sprites
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Player
    player = {}
    player.x = 400
    player.y = 200
    player.walkSpeed = 1  -- Only used for WASD movement

    player.sprite = love.graphics.newImage('sprites/player.png')

    -- Background
    background = love.graphics.newImage('sprites/background.png')
end

function love.update(dt)
    -- Update player controls (keyboard movement)
    PlayerControls()

    -- Make the player face the mouse (rotate, but don't move with it)
    UpdatePlayerRotation()
end

function love.draw()
    -- Draw the background
    love.graphics.draw(background, 0, 0)

    -- Draw the player sprite rotated to face the mouse without repositioning it
    DrawPlayer()
end

function PlayerControls()
    -- Movement controls (WASD keys) to move the player
    if love.keyboard.isDown("w") then player.y = player.y - player.walkSpeed end
    if love.keyboard.isDown("s") then player.y = player.y + player.walkSpeed end
    if love.keyboard.isDown("d") then player.x = player.x + player.walkSpeed end
    if love.keyboard.isDown("a") then player.x = player.x - player.walkSpeed end
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
