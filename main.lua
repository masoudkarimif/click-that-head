local love             = require("love")
local Button           = require("Button")
local Head             = require("Head")

local game             = {
  isOver = false,
  isRunning = false,
  hasStarted = false,
  isWon = false,
  isTransitioningLevel = false
}

local directions       = {
  "right",
  "left",
  "up",
  "down"
}

local cursor           = love.mouse.getSystemCursor("hand")
local gameOverSound    = love.audio.newSource("assets/sounds/enemy-win.wav", "static")
local transitionBucket = 0
local headSize         = 50

local gameOverImage    = love.graphics.newImage("assets/images/game-over.png")
local gameWonImage     = love.graphics.newImage("assets/images/game-won.png")
local gameTextWidth    = 400
local gameTextHeight   = 100


local bg           = love.graphics.newImage("assets/images/background-3.jpg")
local bgInitial    = love.graphics.newImage("assets/images/background-initial.jpg")

local currentLevel = 10
local currentHead  = nil

local font         = love.graphics.newFont("assets/fonts/KGSecondChancesSolid.ttf", 16)

local buttons      = {
  play = Button("play", 0, 0),
  replay = Button("reply", 0, 0)
}


local function drawStats()
  love.graphics.setFont(font)
  love.graphics.print("Level: " .. currentLevel, love.graphics.getWidth() - 80, 10)
  love.graphics.print("Clicked Heads: " .. currentLevel - 1, 10, 10)
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 30)
end

local function drawGameOver()
  love.graphics.draw(gameOverImage, love.graphics.getWidth() / 2 - gameTextWidth / 2,
    love.graphics.getHeight() / 2 - gameTextHeight / 2)
end

local function nextLevel()
  currentLevel = currentLevel + 1
  local initialX, initialY = 0, 0

  local randomDirection = directions[math.random(1, #directions)]
  local randX = math.random(1, love.graphics.getWidth() - headSize - 1)
  local randY = math.random(1, love.graphics.getHeight() - headSize - 1)
  if randomDirection == "right" then
    initialX = -headSize
    initialY = randY
  elseif randomDirection == "left" then
    initialX = love.graphics.getWidth()
    initialY = randY
  elseif randomDirection == "up" then
    initialX = randX
    initialY = love.graphics.getHeight()
  elseif randomDirection == "down" then
    initialX = randX
    initialY = -headSize
  end
  currentHead = Head(initialX, initialY, randomDirection, currentLevel)
  game.isTransitioningLevel = false
  game.isRunning = true
end

local function drawButtons()
  if not game.hasStarted then
    buttons.play:draw()
  elseif game.isOver or game.isWon then
    buttons.replay:draw()
  end

  if not game.isRunning then
    if buttons.play.isHovered or buttons.replay.isHovered then
      love.mouse.setCursor(cursor)
    else
      love.mouse.setCursor()
    end
  else
    love.mouse.setCursor()
  end
end

local function restartGame()
  currentLevel = 0
  nextLevel()

  buttons.play:init()
  buttons.replay:init()
end

local function closeInitialPage()
  game.hasStarted = true
  game.isRunning = true
  game.isOver = false
  game.isWon = false
end

function love.load()
  restartGame()
end

function love.mousepressed(x, y, button, istouch)
  if not game.hasStarted and buttons.play.isHovered then
    closeInitialPage()
  elseif (game.isOver or game.isWon) and buttons.replay.isHovered then
    closeInitialPage()
    restartGame()
  end

  if currentHead:isHit(x, y) then
    game.isRunning = false
    game.isTransitioningLevel = true
  end
end

local function drawGameWon()
  love.graphics.draw(gameWonImage, love.graphics.getWidth() / 2 - gameTextWidth / 2,
    love.graphics.getHeight() / 2 - gameTextHeight / 2)
end

local function gameOver()
  game.isRunning = false
  game.isOver = true
  gameOverSound:play()
  drawGameOver()
end

function love.update(dt)
  buttons.play:update()
  buttons.replay:update()
  if game.hasStarted and game.isRunning then
    local missed = currentHead:update(dt)
    if missed then
      gameOver()
    end
  elseif game.isTransitioningLevel then
    transitionBucket = transitionBucket + dt
    if transitionBucket >= 1 then
      nextLevel()
      transitionBucket = 0
    end
  end
end

local function drawInitial()
  love.graphics.draw(bgInitial, 0, 0)
end

function love.draw()
  if not game.hasStarted then
    drawInitial()
  else
    -- background
    love.graphics.draw(bg, 0, 0)

    drawStats()
    currentHead:draw()

    if game.isOver then
      drawGameOver()
    elseif game.isWon then
      drawGameWon()
    end
  end
  drawButtons()
end
