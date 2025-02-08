-- main.lua

function love.load()
    -- Prevent blurry sprites
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Load the player script module.
    playerScript = require("playerScript")
    playerScript.load()  -- Initialize the player

    -- Load the background sprite.
    background = love.graphics.newImage('sprites/background.png')
    
    -- (Optional) Store screen dimensions.
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.update(dt)
    playerScript.update(dt)
end

function love.draw()
    -- Draw the background.
    love.graphics.draw(background, 0, 0)
    
    -- Draw the player.
    playerScript.draw()
    
    -- Values of certain variables
    Debug()
end

function Debug()

    love.graphics.print("stamina: " .. playerScript.player.stamina, screenWidth - 140, 10)
    love.graphics.print("staminaCooldown: " .. playerScript.player.staminaCooldown, screenWidth - 140, 40)
    love.graphics.print("moveSpeed: " .. playerScript.player.moveSpeed, screenWidth - 140, 70)
    love.graphics.print("aimState: " .. playerScript.player.aimState, screenWidth - 140, 100)
    love.graphics.print("moveState: " .. playerScript.player.moveState, screenWidth - 140, 130)
    love.graphics.print("rotationSpeed: " .. playerScript.player.rotationSpeed, screenWidth - 140, 160)

    local fastTurnStatus = playerScript.player.fastTurn and "ACTIVE" or "INACTIVE"
    love.graphics.print("fastTurn: " .. fastTurnStatus, screenWidth - 140, 190)

end
