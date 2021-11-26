-- window width (not to be changed):
WINDOW_WIDTH = 1280
-- window height (not to be changed):
WINDOW_HEIGHT = 720
-- virtual width (not to be changed and to be used with the push settings):
VIRTUAL_WIDTH = 432
-- virtual height (not to be changed and to be used with the push settings):
VIRTUAL_HEIGHT = 243
-- sets a movement speed for both paddles (not to be changed):
PADDLE_SPEED = 200
-- imports push from the game directory
Class = require 'class'
push = require 'push'
require 'Paddle'
require 'Ai'
require 'Ball'
mult = 0
 -- lua with love 
function love.load()
    -- seeds a number to the random function:
    math.randomseed(os.time())
    -- sets the default filter to be 'nearest' instead of 'blurred':
    love.graphics.setDefaultFilter('nearest', 'nearest')
    -- sets the title of the window:
    love.window.setTitle('Pong')
    -- creates a new font object linked to the font.ttf file in the game directory:
    smallFont = love.graphics.newFont('font.TTF', 8)
    -- creates a new font object linked to the font.ttf file in the game directory (bigger than the other one):
    scoreFont = love.graphics.newFont('font.TTF', 32)
    -- creates a font for the victory screen:
    victoryFont = love.graphics.newFont('font.TTF', 24)
    -- sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('Blip_Select.wav', 'static'),
        ['point_scored'] = love.audio.newSource('Explosion12.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('Hit_Hurt.wav', 'static')
    }
    -- serving player:
    servingPlayer = math.random(2) == 1 and 1 or 2
    -- winner player:
    winningPlayer = 0
    -- instantiates the players:
    paddle1 = Paddle(5, 20, 5, 20)
    -- sets the push settings:
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
            fullscreen = false,
            vsync = true,
            resizable = true
    })
    -- instantiates the ball:
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)
    -- gets the right velocity to the ball accordig to the serving player:
    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end
    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

-- update function (kinda like tick):
function love.update(dt)
    if gameState == 'play' then
        -- scoring system:
        if ball.x <= 0 then
            paddle2:addPoint()
            sounds['point_scored']:play()
            servingPlayer = 1
            ball:reset()
            ball.dx = 100
            if paddle2.score >= 10 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        elseif ball.x >= VIRTUAL_WIDTH - 4 then
            paddle1:addPoint()
            sounds['point_scored']:play()
            servingPlayer = 2
            ball:reset()
            ball.dx = -100
            if paddle1.score >= 10 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end
        -- paddle collision:
        if ball:collides(paddle1) or ball:collides(paddle2) then
            ball:invert()
            sounds['paddle_hit']:play()
        end
        -- bottom and top edges collision for the ball:
        if ball.y <= 0 or ball.y >= VIRTUAL_HEIGHT - 4 then
            ball:switch()
            sounds['wall_hit']:play()
            if ball.y <= 0 then
                ball.y = 0
            else
                ball.y = VIRTUAL_HEIGHT - 4
            end
        end
        -- calls the update functions on both players:
        paddle1:update(dt)
        paddle2:update(dt)
        -- player 1 movement:
        if love.keyboard.isDown('w') then
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end
        -- player 2 movement:
        if mult == 2 then
            if love.keyboard.isDown('up') then
                paddle2.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('down') then
                paddle2.dy = PADDLE_SPEED
            else
                paddle2.dy = 0
            end
        elseif mult == 1 then
            paddle2.dy = (ball.y - paddle2.y) * 3.5
        end
        -- moves the ball in the direction it started:
        ball:update(dt)
    end
end

-- reads a key input (comes in the form of a string):
function love.keypressed(key)
    -- if the key is equal to 'escape' the program ends:
    if key == 'escape' then
        love.event.quit()
    elseif key == 'm' then
        if gameState == 'start' then
            mult = 1
            paddle2 = Ai(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
            gameState = 'serve'
        end
    elseif key == 'n' then
        if gameState == 'start' then
            mult = 2
            paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
            gameState = 'serve'
        end
    elseif key == 'enter' or key == 'return' then
        if gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'start'
            ball:reset()
            paddle1.score = 0
            paddle2.score = 0
        end
    -- if the enter key is pressed then the game starts or stops depending on the previous state:
    --elseif key == 'enter' or key == 'return' then
        --if gameState == 'start' then
            --gameState = 'serve'
        --elseif gameState == 'serve' then
            --gameState = 'play'
        --elseif gameState == 'play'  or gameState == 'victory' then
            --gameState = 'start'
            --ball:reset()
            --paddle1.score = 0
            --paddle2.score = 0
        --end
    end
end

function love.draw()
    -- sets everything until push:apply('end') to be using the push settings:
    push:apply('start')
    -- "coats" the screen with a greish color:
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    -- creates the ball roughly in the middle of the screen:
    ball:render()
    --love.graphics.rectangle('fill', ballX, ballY, 5, 5)
    -- creates the paddle in the left side of the sccreen:
    paddle1:render()
    -- creates the paddle in the right side of the screen:
    if mult ~= 0 then
        paddle2:render()
    end
    -- sets the font to be the small one (used locally):
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        -- says hello
        love.graphics.printf("Welcome to pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press m to play singleplayer or n to play multiplayer!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Serving player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press enter to serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        -- victory message
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. "wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press enter to serve!", 0, 42, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont(smallFont)
    -- displays the FPS on the screen
    displayFPS()
    -- sets the font to be the big one (used locally):
    love.graphics.setFont(scoreFont)
    -- writes the scores on the screen:
    love.graphics.print(paddle1.score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    if mult ~= 0 then
        love.graphics.print(paddle2.score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    end
    -- ends the action range of the push settings:
    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end