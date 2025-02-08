-- gunScript.lua

local gun = {}

-- A table to store all active bullets.
gun.bullets = {}

-- Gun settings.
gun.fireRate = 0.1          -- Minimum time between shots (in seconds).
gun.timeSinceLastShot = 0    -- Timer to track cooldown.

-- Load bullet sprite.
function gun.load()
    gun.bulletImage = love.graphics.newImage('sprites/bullet.png')
end

-- Handles shooting input and fires bullets if allowed.
function gun.update(dt, player)
    gun.timeSinceLastShot = gun.timeSinceLastShot + dt

    if love.mouse.isDown(1) and gun.timeSinceLastShot >= gun.fireRate then
        gun.shoot(player.x, player.y, player.angle)
        gun.timeSinceLastShot = 0
    end

    -- Update bullets.
    for i = #gun.bullets, 1, -1 do
        local b = gun.bullets[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        b.life = b.life - dt

        if b.life <= 0 then
            table.remove(gun.bullets, i)
        end
    end
end

-- Create a new bullet. Now spawns outside the player. -- [CHANGED]
function gun.shoot(x, y, angle)
    local spawnOffset = 20 -- Distance from player's center; adjust based on your player's size. -- [CHANGED]
    local spawnX = x + math.cos(angle) * spawnOffset  -- [CHANGED]
    local spawnY = y + math.sin(angle) * spawnOffset  -- [CHANGED]

    local bulletSpeed = 1500  -- Adjust bullet speed.
    local bulletLife = 2     -- Bullet lifespan before removal.

    local bullet = {
        x = spawnX,  -- Use spawnX instead of player's center.
        y = spawnY,  -- Use spawnY instead of player's center.
        dx = math.cos(angle) * bulletSpeed,
        dy = math.sin(angle) * bulletSpeed,
        life = bulletLife,
        angle = angle
    }

    table.insert(gun.bullets, bullet)
end

-- Draw all active bullets.
function gun.draw()
    for _, b in ipairs(gun.bullets) do
        love.graphics.draw(
            gun.bulletImage,  
            b.x, b.y,         
            b.angle,         
            0.5, 0.5,         
            gun.bulletImage:getWidth()/2,  
            gun.bulletImage:getHeight()/2  
        )
    end
end

return gun
