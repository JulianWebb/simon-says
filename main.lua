--! main.lua
--! Created by: Pongles

--: Basic housekeeping
math.randomseed(os.time())

--: Libraries
tick = require 'libs.tick'
Object = require 'libs.classic'


require 'functions'

--: Classes
require 'button'

--: Currently the game window is unresizable so no need to constantly call the functions
window = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

--os = love.system.getOS()

sounds = {
    default = love.sound.newSoundData( "assets/tone1.ogg" ),
    levelup = love.sound.newSoundData( "assets/levelup.ogg" ),
    failure = love.sound.newSoundData( "assets/fail.ogg" )
}

music = {
    bg = love.audio.newSource("assets/Robobozo.mp3", 'stream')
}
--: Square properties
square = {}
if window.height > window.width then
    square.size = window.width  / 4
else
    square.size = window.height / 4
end

--: Just because they are current square doesn't mean they always will be
square.height = square.size
square.width = square.size
square.hPadding = square.height / 4
square.wPadding = square.width  / 4

btnAnchor = {
    x = (window.width - (square.width * 2 + square.wPadding)) / 2,
    y = (window.height - (square.height * 2 + square.hPadding)) / 2
}

colors = {
    red = {
        {1, 0, 0}, -- Line
        {60/255, 0, 0} -- Fill
    },
    green = {
        {0, 1, 0},
        {0, 60/255, 0}
    },
    blue = {
        {0, 0, 1},
        {0, 0, 60/255}
    },
    yellow = {
        {1, 1, 0},
        {60/255, 60/255, 0}
    }
}

btns = {
    Button(
        btnAnchor.x,
        btnAnchor.y,
        square.width, square.height,
        {
            line = colors.red[1],
            fill = colors.red[2]
        },
        sounds.default,
        1),
    Button(
        btnAnchor.x + square.width + square.wPadding,
        btnAnchor.y,
        square.width, square.height,
        {
            line = colors.green[1],
            fill = colors.green[2]
        },
        sounds.default,
        2),
    Button(
        btnAnchor.x,
        btnAnchor.y + square.height + square.hPadding,
        square.width, square.height,
        {
            line = colors.blue[1],
            fill = colors.blue[2]
        },
        sounds.default,
        3),
    Button(
        btnAnchor.x + square.width + square.wPadding,
        btnAnchor.y + square.height + square.hPadding,
        square.width, square.height,
        {
            line = colors.yellow[1],
            fill = colors.yellow[2]
        },
        sounds.default,
        4)
}

--: Starts with playback = true since we generate the inital sequence right away
flags = {
    playback = true,
    control = false
}

gSeq = genSeq(4)
pSeq = {}

score = {
    num = 0,
    text = love.graphics.newText(love.graphics.newFont(16))
}

music.bg:setVolume(0.05)
music.bg:play()

function love.update(dt)
    score.text:set("Score: " .. score.num)
    if music.bg:isPlaying() == false then
        music.bg:play()
    end
    tick.update(dt)

    --: Loop through current 
    for i=1, #pSeq do
        --: If the sequences don't match
        if pSeq[i] ~= gSeq[i] then
            --: Restart
            love.graphics.captureScreenshot(os.time() .. ".png")
            gSeq = genSeq(4)
            pSeq = {}
            flags.control = false
            score.num = 0
            tick.delay(function() love.audio.newSource(sounds.failure):play() end, 0.5)
                :after(function() flags.playback = true end, 0.5)
        end
    end
    --: If the counts match (and if it's made it this far, then the sequence matches)
    if #pSeq == #gSeq then
        table.insert(gSeq, math.random(1, 4))
        pSeq = {}
        flags.control = false
        score.num = score.num + 1
        tick.delay(function() love.audio.newSource(sounds.levelup):play() end, 0.5)
            :after(function() flags.playback = true end, 0.5)
    end

    --: Playback the new sequence if there is need to
    if flags.playback then
        flags.control = false
        t = tick.delay(
            function()
                btns[gSeq[1]]:trigger()
            end, 
            0.1)
        for i=2, #gSeq do
            t = t:after(
                function()
                    btns[gSeq[i]]:trigger()
                end,
                1)
        end
        t:after(function() flags.control = true end, 0.1)
        flags.playback = false
    end

    for i=1, #btns do
        btns[i]:update(dt)
    end
end
--/> love.update

function love.draw()
    love.graphics.setColor({1, 1, 1}) --: White
    love.graphics.draw(score.text, (window.width - score.text:getWidth()) / 2, (window.height - score.text:getHeight()) / 2)
    for i=1, #btns do
        btns[i]:draw()
    end
end
--/> love.draw