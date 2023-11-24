local love = require("love")

function Button(imageName, x, y)
  return {
    x = x or 0,
    y = y or 0,
    width = 0,
    height = 0,
    isHovered = false,
    sprite = {
      image = love.graphics.newImage("assets/images/" .. imageName .. ".png"),
      width = 200,
      height = 100
    },
    quads = {
      frames = {},
      width = 0,
      height = 0
    },
    currentFrame = 0,
    totalFrames = 2,
    init = function(self)
      self.quads.height = self.sprite.height
      self.quads.width = self.sprite.width / self.totalFrames
      self.width = self.quads.width
      self.height = self.quads.height

      self.x = love.graphics.getWidth() / 2 - self.width / 2
      self.y = love.graphics.getHeight() / 2 - self.height / 2 + 150

      for i = 0, self.totalFrames - 1 do
        table.insert(self.quads.frames, i, love.graphics.newQuad(i * self.quads.width, 0, self.quads.width,
          self.quads.height, self.sprite.width, self.sprite.height))
      end
    end,

    draw = function(self)
      love.graphics.draw(self.sprite.image, self.quads.frames[self.currentFrame], self.x, self.y)
    end,

    update = function(self)
      x, y = love.mouse.getPosition()
      if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
        -- the button should be active
        self.currentFrame = 1
        self.isHovered = true
      else
        self.currentFrame = 0
        self.isHovered = false
      end
    end

  }
end

return Button
