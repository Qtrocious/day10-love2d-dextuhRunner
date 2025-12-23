local player = {
    x = 80,
    y = 0,
    width = 1,
    height = 1,
    velocityY = 0,
    isJumping = false
}

local ground = { y = 0, height = 40 }
local obstacles = {}
local spawnTimer = 0
local spawnInterval = .2
local gameSpeed = 300
local score = 0
local highScore = 0
local gameOver = false
local gravity = 1200
local jumpForce = -800
local downForce = 2000
local images = {}
local dinoScale = 1
local bgMusic, lostSound, lost



function love.load()
    love.window.setTitle("Dexter Runner")
    bgMusic = love.audio.newSource("assets/pasion.mp3", "stream")
    if bgMusic then
        bgMusic:setLooping(true)
        bgMusic:play()
    end

    lostSound = love.audio.newSource("assets/blud.mp3", "static")
    images.dexter = love.graphics.newImage("assets/png-clipart-michael-c-hall-dexter-morgan-harry-morgan-debra-morgan-dexter-morgan-television-shoe-thumbnail.png")
    images.doakes = love.graphics.newImage("assets/james-doakes-james.png")
    images.dexterAir = love.graphics.newImage("assets/life-dexter-morgan-reaction-v0-20wetwv0nvpd1.png")
    
    local targetHeight = 60
    dinoScale = targetHeight / images.dexter:getHeight()
    player.width = images.dexter:getWidth() * dinoScale
    player.height = targetHeight
    
    ground.y = love.graphics.getHeight() - ground.height
    player.y = ground.y - player.height + 1
    
    love.graphics.setFont(love.graphics.newFont(20))
end

function love.update(dt)
    if gameOver then return end
    
    score = score + dt * 10
    gameSpeed = 300 + score * 0.5
    
    if player.isJumping then
        player.velocityY = player.velocityY + gravity * dt
        player.y = player.y + player.velocityY * dt
        
        if player.y >= ground.y - player.height then
            player.y = ground.y - player.height + 1
            player.isJumping = false
            player.velocityY = 0
        end
    end
    
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        spawnInterval = math.random(10, 20) / 10
        spawnObstacle()
    end
    
    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs.x = obs.x - gameSpeed * dt
        
        if obs.x + obs.width < 0 then
            table.remove(obstacles, i)
        end
        
        if checkCollision(player, obs) then
            if not gameOver then
                gameOver = true
                if bgMusic and bgMusic:isPlaying() then bgMusic:stop() end
                if lostSound then lost = lostSound:play() end
            end
        end
    end
end

function love.draw()
    love.graphics.clear(0.416, 0.353, 0.804)
    love.graphics.setColor(255, 0, 0)
    love.graphics.line(0, ground.y, love.graphics.getWidth(), ground.y)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(images.dexter, player.x, player.y, 0, dinoScale, dinoScale)
    
    for _, obs in ipairs(obstacles) do
        love.graphics.draw(images.doakes, obs.x, obs.y, 0,
        obs.width / images.doakes:getWidth(),
        obs.height / images.doakes:getHeight())
    end
    if player.isJumping then
        love.graphics.draw(images.dexterAir, player.x, player.y, 0, dinoScale, dinoScale)
    end
    love.graphics.setColor(255, 0, 0)
    love.graphics.print("Score: " .. math.floor(score), 700, 10)
    love.graphics.print("High Score: " .. math.floor(highScore), 650, 35)
    
    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("GAME OVER", love.graphics.getWidth() / 2 - 60, love.graphics.getHeight() / 2 - 30)
        love.graphics.print("Press SPACE to restart", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 10)
    end
end

function love.keypressed(key)
    if key == "space" or key == "up" then
        if gameOver then
            restartGame()
        elseif not player.isJumping then
            player.isJumping = true
            player.velocityY = jumpForce
        end
    end
    
    if key == "escape" then
        love.event.quit()
    end
    if key == "down" then
        player.isJumping = true
        player.velocityY = downForce
    end
end

function spawnObstacle()
    local obstacle = {
        x = love.graphics.getWidth(),
        width = 100,
        height = 100
    }
    obstacle.y = ground.y - obstacle.height + 1
    table.insert(obstacles, obstacle)
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function restartGame()
    gameOver = false
    score = 0
    obstacles = {}
    spawnTimer = 0
    gameSpeed = 300
    player.y = ground.y - player.height + 1
    player.isJumping = false
    player.velocityY = 0
    lostSound:stop()
    bgMusic:play()
end