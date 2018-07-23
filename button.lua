--! button.lua

Button = Object:extend()

function Button:new(x, y, width, height, colorTable, sound, btnNum)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 0
    self.height = height or 0
    self.color = {}
    self.color.fill = colorTable.fill
    self.color.dFill = colorTable.fill
    self.color.line = colorTable.line
    self.sound = sound or sounds.default
    self.btnNum = btnNum or 0
end
--/> Button:new

function Button:update(dt)
    if flags.control then
        x, y = self:getXY(love.system.getOS())
        if x ~= nil then
            if self:inBounds(x, y) then
                self:trigger()
                flags.control = false
                table.insert(pSeq, self.btnNum)
                tick.delay(
                    function() flags.control = true end,
                    0.2
                )
            end
        end
    end
end
--/> Button:update

function Button:draw(dt)
    --: Inside
    love.graphics.setColor(self.color.fill)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    --: And out
    love.graphics.setColor(self.color.line)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end
--/> Button:draw

--< Used to check if mouse or touch within bounds
function Button:inBounds(x, y)
    --: If within the x axis
    if x > self.x and x < self.x+self.width then
        --: If within the y axis
        if y > self.y and y < self.y+self.height then
            return true
        end
    end
end
--/> Button:inBounds

--: What to do when the button has been clicked
function Button:trigger()
    print('TRIGGERED!')
    love.audio.newSource(self.sound):play()
    self.color.fill = self.color.line
    love.system.vibrate(0.1)
    tick.delay(function() self.color.fill = self.color.dFill end, 0.1)
end
--/> Button:trigger

function Button:getXY(os)
    if os == "Android" or os == "iOS" then
        local touches = love.touch.getTouches()
        for i, id in ipairs(touches) do
            local x, y = love.touch.getPosition(id)
        end
        return x, y
    else
        if love.mouse.isDown(1) then
            return love.mouse.getX(), love.mouse.getY()
        else
            return nil, nil
        end
    end
end
--/> Button:getXY