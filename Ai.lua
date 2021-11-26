Ai = Class{}

function Ai:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
    self.score = 0
end

function Ai:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy * dt)
    end
end

function Ai:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ai:addPoint()
    self.score = self.score + 1
end