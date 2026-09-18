local resize = {}

function resize:new(gw, gh) 
    local instance = {
        gw = gw,
        gh = gh,
        nw = gw,
        nh = gh,
        ox = 0,
        oy = 0,
        s = 1,
        wr = 1,
        hr = 1,
    }
    setmetatable(instance, {__index = resize})
    return instance
end

function resize:resize(nw, nh)
    self.nw = nw
    self.nh = nh
    self.wr = self.nw/self.gw
    self.hr = self.nh/self.gh

    if self.wr < self.hr then --leterbox
        self.s = self.nw / self.gw
        self.ox = 0
        self.oy = (self.nh - self.gh * self.s) / 2
    elseif self.wr > self.hr then --pillarbox
        self.s = self.nh / self.gh
        self.ox = (self.nw - self.gw * self.s) / 2
        self.oy = 0
    else --perfect match
        self.s = self.nw / self.gw
        self.ox = 0
        self.oy = 0
    end
end

function resize:draw_start()
    love.graphics.push()
    love.graphics.translate(self.ox, self.oy)
    love.graphics.scale(self.s, self.s)
end

function resize:draw_end() 
    love.graphics.setColor(0, 0, 0, 1)
    if self.wr < self.hr then --letterbox
        love.graphics.rectangle("fill", 0, -self.oy/self.s, self.gw, self.oy/self.s)
        love.graphics.rectangle("fill", 0, self.gh, self.gw, self.oy/self.s)
    elseif self.wr > self.hr then --pillarbox
        love.graphics.rectangle("fill", -self.ox/self.s, 0, self.ox/self.s, self.gh)
        love.graphics.rectangle("fill", self.gw, 0, self.ox/self.s, self.gh)
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.pop()
end

return resize