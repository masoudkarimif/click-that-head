local love = require("love")

function Head(x, y, direction, level)
  return {
    x = x or 0,
    y = y or 0,
    hitX = 0,
    hitY = 0,
    hit = false,
    width = 50,
    height = 50,
    level = level or 0,
    direction = direction,
    hasMoved = false,
    image = love.graphics.newImage("assets/images/character.jpg"),
    hitSound = love.audio.newSource("assets/sounds/enemy-hit.mp3", "static"),

    draw = function(self)
      love.graphics.draw(self.image, self.x, self.y)
      if self.hit then
        love.graphics.setColor(200, 0, 0)
        love.graphics.circle("fill", self.hitX, self.hitY, 10)
        love.graphics.reset()
      end
    end,

    update = function(self, dt)
      self.hasMoved = true
      local factor = dt * level * 100

      if self.direction == "right" then
        self.x = self.x + factor
      elseif self.direction == "left" then
        self.x = self.x - factor
      elseif self.direction == "up" then
        self.y = self.y - factor
      elseif self.direction == "down" then
        self.y = self.y + factor
      end

      return self:isMissed()
    end,

    isHit = function(self, x, y)
      if x >= self.x and x <= self.x + self.width and y <= self.y + self.height and y >= self.y then
        self.hitSound:play()
        self.hit = true
        self.hitX = x
        self.hitY = y
        return true
      else
        return false
      end
    end,

    isMissed = function(self)
      if not self.hasMoved then
        return false
      else
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        return (self.direction == "right" and self.x > screenWidth) or
            (self.direction == "left" and self.x + self.width < 0) or
            (self.direction == "up" and self.y + self.height < 0) or
            (self.direction == "down" and self.y > screenHeight)
      end
    end
  }
end

return Head
