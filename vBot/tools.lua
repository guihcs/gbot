-- tools tab
setDefaultTab("Tools")

if type(storage.fightItems) ~= "table" then
    storage.fightItems = {}
end

if type(storage.restItems) ~= "table" then
    storage.restItems = {}
end

if type(storage.hotkey) ~= "string" then
    storage.hotkey = "'"
end

UI.Label("Hotkey")
UI.TextEdit(storage.hotkey, function(widget, text)
    storage.hotkey = text
end)

UI.Label("Auto equip fight mode")
local fightMode = UI.Container(function(widget, items)
    storage.fightItems = items
end, true)

fightMode:setHeight(35)
fightMode:setItems(storage.fightItems)

UI.Label("Auto equip rest mode")
local restMode = UI.Container(function(widget, items)
    storage.restItems = items
end, true)

restMode:setHeight(35)
restMode:setItems(storage.restItems)

if type(storage.isFighting) ~= "boolean" then
    storage.isFighting = true
end

hotkey("'", function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    local slots = {getHead, getNeck, getBack, getBody, getRight, getLeft, getLeg, getFeet, getFinger, getAmmo, getPurse}

    local equipped = {}
    for i, slot in pairs(slots) do
        local item = slot()
        if item then
            equipped[item:getId()] = true
        end
    end

    local fromItems = storage.fightItems
    local toItems = storage.restItems
    local activeValue = false

    if not storage.isFighting then
        activeValue = true
        fromItems = storage.restItems
        toItems = storage.fightItems
    end

    storage.combo = activeValue
    modules.combo.switch:setOn(activeValue)

    for i, item in pairs(fromItems) do
        if equipped[item.id] then
            g_game.equipItemId(item.id)
        end
    end
    for i, item in pairs(toItems) do
        g_game.equipItemId(item.id)
    end

    storage.isFighting = not storage.isFighting
end)

UI.Separator()



-- player:getDirection()

hotkey("1", function()

    -- if client is in chat mode, don't do anything
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    local direction = player:getDirection()
    local pp = pos()
    local tiles = {}
    if direction == 2 then

        tiles = {g_map.getTile({
            x = pp.x - 1,
            y = pp.y - 1,
            z = pp.z
        }), g_map.getTile({
            x = pp.x,
            y = pp.y - 1,
            z = pp.z
        }), g_map.getTile({
            x = pp.x + 1,
            y = pp.y - 1,
            z = pp.z
        })}

    elseif direction == 3 then

        tiles = {g_map.getTile({
            x = pp.x + 1,
            y = pp.y - 1,
            z = pp.z
        }), g_map.getTile({
            x = pp.x + 1,
            y = pp.y,
            z = pp.z
        }), g_map.getTile({
            x = pp.x + 1,
            y = pp.y + 1,
            z = pp.z
        })}

    elseif direction == 0 then

        tiles = {g_map.getTile({
            x = pp.x - 1,
            y = pp.y + 1,
            z = pp.z
        }), g_map.getTile({
            x = pp.x,
            y = pp.y + 1,
            z = pp.z
        }), g_map.getTile({
            x = pp.x + 1,
            y = pp.y + 1,
            z = pp.z
        })}

    elseif direction == 1 then

        tiles = {g_map.getTile({
            x = pp.x - 1,
            y = pp.y - 1,
            z = pp.z
        }), g_map.getTile({
            x = pp.x - 1,
            y = pp.y,
            z = pp.z
        }), g_map.getTile({
            x = pp.x - 1,
            y = pp.y + 1,
            z = pp.z
        })}

    end
    dropPlants(tiles)

end)

function dropPlants(tiles)
    local plants = {2980, 2981, 2982, 2983, 2984, 2985, 2986, 2987}
    for i, tile in ipairs(tiles) do

        if tile and tile:isWalkable() then
            local topThing = tile:getTopThing()

            if not topThing or (topThing:isItem() and not table.find(plants, topThing:getId())) then
                for j, plant in ipairs(plants) do

                    local dropItem = findItem(plant)

                    if dropItem then

                        g_game.move(dropItem, tile:getPosition(), 1)

                        break
                    end

                end
            end

        end
    end
end

UI.Separator()
UI.Label("Plant Containers")

if type(storage.plantContainers) ~= "table" then
    storage.plantContainers = {}
end

local plantStore = UI.Container(function(widget, items)
    storage.plantContainers = items
end, true)

plantStore:setHeight(35)
plantStore:setItems(storage.plantContainers)

hotkey("2", function()

    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    -- pick up plants regardless of direction
    local pp = pos()

    local tiles = getNearTiles(pos(), 1)

    local plants = {2980, 2981, 2982, 2983, 2984, 2985, 2986, 2987}

    local amount = 0

    for i, tile in ipairs(tiles) do
        if tile and tile:isWalkable() then
            local topThing = tile:getTopThing()
            if topThing and topThing:isItem() and table.find(plants, topThing:getId()) then

                local container = findItem(2872)

                if container then
                    g_game.move(topThing, container:getPosition(), 1)
                    amount = amount + 1
                    if amount >= 3 then
                        break
                    end
                end

            end
        end
    end

end)

hotkey("9", function()

    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    if g_mouse.isPressed(MouseRightButton) then
        g_game.setChaseMode(ChaseOpponent)
        return
    end

    local tile = getTileUnderCursor()
    if tile then
        local topThing = tile:getTopCreature()
        if topThing and topThing:isCreature() then
            -- stop attacking
            targetID = nil
            g_game.follow(topThing)
        end
    end

end)

hotkey("R", function()

    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    local tile = getTileUnderCursor()
    if tile then
        local topThing = tile:getTopUseThing()

        if topThing then
            useWith(3192, topThing)
        end

    end

end)

hotkey("0", function()

    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    local tile = getTileUnderCursor()
    if tile then
        local topThing = tile:getTopUseThing()

        if topThing then
            useWith(3180, topThing)
        end

    end

end)

local currentTime = 0
local curPing = 0
local pushDist = 0
local pushEvents = {}
local pushTiles = {}

if type(storage.pushDelay) ~= "number" then
    storage.pushDelay = 1050
end

UI.Label("PushDelay")
UI.TextEdit(storage.pushDelay, function(widget, text)
    storage.pushDelay = tonumber(text)
end)

if type(storage.mwDelay) ~= "number" then
    storage.mwDelay = 1100
end

UI.Label("Mw Delay")
UI.TextEdit(storage.mwDelay, function(widget, text)
    storage.mwDelay = tonumber(text)
end)

local followTarget = nil

hotkey("Escape", function()

    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    g_game.setChaseMode(DontChase)
    followTarget = nil
    for i, event in pairs(pushEvents) do
        if event then
            pushEvents[i] = nil
            if pushTiles[i] then
                pushTiles[i]:setTimer(0)
                pushTiles[i] = nil
            end
        end
    end
end)

function hashPos(pos)
    return pos.x * 100000 + pos.y * 1000 + pos.z
end

function mwOnPos(ps)

    local tile = g_map.getTile(ps)
    if not tile then
        return
    end

    local topUseThing = tile:getTopUseThing()

    if not topUseThing then
        return
    end

    useWith(3180, topUseThing)

end

function pushRealtime(mouseTile, tile, thingPos, mwPos)
    local tid = now
    tile:setTimer(mouseTile:getTimer() - storage.pushDelay)
    pushEvents[tid] = true
    pushTiles[tid] = tile

    schedule(mouseTile:getTimer() - storage.pushDelay, function()
        if not pushEvents[tid] then
            return
        end
        pushEvents[tid] = nil
        pushTiles[tid] = nil
        tile:setTimer(1100)

        pushAntipush(tile, mouseTile)

        if mwPos then
            schedule(storage.mwDelay, function()
                mwOnPos(thingPos)
            end)
        end
    end)

end

function pushAntipush(tile, mouseTile)
    local container = findItem(2865)

    if not container then
        return
    end

    for i, thing in ipairs(tile:getThings()) do
        if thing:isItem() and not thing:isGround() then
            g_game.move(thing, container:getPosition(), thing:getCount())
        end
        if thing:isCreature() then
            tile:setTimer(1100)
            schedule(40, function()
                g_game.move(thing, mouseTile:getPosition(), 1)
            end)
        end
    end
end

function onDropD(self, widget, mousePos)

    if not self:canAcceptDrop(widget, mousePos) then
        return false
    end

    local tile = self:getTile(mousePos)
    if not tile then
        return false
    end

    local thing = widget.currentDragThing

    local toPos = tile:getPosition()

    local thingPos = thing:getPosition()
    if thingPos.x == toPos.x and thingPos.y == toPos.y and thingPos.z == toPos.z then
        return false
    end

    if g_keyboard.isAltPressed() then
        local mwPos = g_keyboard.isShiftPressed()

        local ps = pos()
        local tile = g_map.getTile(thingPos)

        local mouseTile = getTileUnderCursor()
        local topThing = mouseTile:getTopUseThing()

        if topThing:getId() == 2129 then

            pushRealtime(mouseTile, tile, thingPos, mwPos)
            return
        elseif topThing:getId() == 2130 then
            useWith(9596, topThing)
            
            pushAntipush(tile, mouseTile)
            return
        end
            

        pushAntipush(tile, mouseTile)

        local fields = {
            [105] = true,
            [2118] = true,
            [2122] = true,
            [2119] = true,
            [2123] = true
        }

        for i, thing in ipairs(mouseTile:getThings()) do
            if fields[thing:getId()] then
                useWith(3148, topThing)
                return
            end
        end

        if mwPos then
            schedule(storage.mwDelay, function()
                mwOnPos(thingPos)
            end)
        end

        return

    end

    if thing:isItem() and thing:getCount() > 1 then
        modules.game_interface.moveStackableItem(thing, toPos)
    else

        pushEvents[thing:getPosition()] = thing
        currentTime = now
        curPing = ping()
        local thingTile = g_map.getTile(thingPos)
        if thing:isCreature() then
            thingTile:setTimer(1100)
        end

        g_game.move(thing, toPos, 1, false)

        if g_keyboard.isShiftPressed() then
            doublePush(thing, thingPos, toPos)
        end

    end

    return true
end

function doublePush(thing, thingPos, toPos)
    local currentTile = g_map.getTile(thingPos)
    local things = currentTile:getThings()
    

    if thingPos.z ~= toPos.z then
        if things[#things-1]:getId() == 30913 then
            thingPos = {
                x = thingPos.x + 2,
                y = thingPos.y,
                z = toPos.z
            }
        else
            thingPos = {
                x = thingPos.x,
                y = thingPos.y - 1,
                z = toPos.z
            }
        end

    end

    local dr = getDir(thingPos, toPos)

    local npos = {
        x = toPos.x + dr.x,
        y = toPos.y + dr.y,
        z = toPos.z + dr.z
    }

    local ft = g_map.getTile(npos)
    local topFtThing = ft:getTopThing()
    local pdir = getDir(pos(), thingPos)

    local pnpos = {
        x = thingPos.x + pdir.x,
        y = thingPos.y + pdir.y,
        z = thingPos.z + pdir.z
    }

    if not ft:isWalkable() or ft:getTopCreature() or npos.x == pnpos.x and npos.y == pnpos.y and npos.z == pnpos.z or topFtThing:getId() == 433 or topFtThing:getId() == 432 then
        local ndr = getDir(thingPos, npos)

        local ndr1 = {
            x = ndr.y,
            y = -ndr.x,
            z = ndr.z
        }
        local ndr2 = {
            x = -ndr.y,
            y = ndr.x,
            z = ndr.z
        }

        local fnpos1 = {
            x = npos.x + ndr1.x,
            y = npos.y + ndr1.y,
            z = npos.z + ndr1.z
        }
        local fnpos2 = {
            x = npos.x + ndr2.x,
            y = npos.y + ndr2.y,
            z = npos.z + ndr2.z
        }

        local sqrdDist1 = math.pow(toPos.x - fnpos1.x, 2) + math.pow(toPos.y - fnpos1.y, 2)
        local sqrdDist2 = math.pow(toPos.x - fnpos2.x, 2) + math.pow(toPos.y - fnpos2.y, 2)

        if sqrdDist1 <= sqrdDist2 and g_map.getTile(fnpos1):isWalkable() and not g_map.getTile(fnpos1):getTopCreature() then
            npos = fnpos1
        else
            npos = fnpos2
        end

    end


    local fd = getDir(thingPos, npos)



    local pd = 300

    if math.abs(fd.x) + math.abs(fd.y) > 1 then
        pd = 120
    end


    schedule(pd, function()
        g_game.move(thing, npos, 1, false)
    end)
end

function getDir(pos1, pos2)
    local npos = {
        x = pos1.x - pos2.x,
        y = pos1.y - pos2.y,
        z = pos1.z - pos2.z
    }
    local max = math.max(math.abs(npos.x), math.abs(npos.y), math.abs(npos.z))
    if max == 0 then
        max = 1
    end
    npos.x = math.round(npos.x / max)
    npos.y = math.round(npos.y / max)
    npos.z = math.round(npos.z / max)
    return npos
end

modules.game_interface.gameMapPanel.onDrop = onDropD

onCreaturePositionChange(function(creature, newPos, oldPos)
    if not oldPos then
        return
    end
    if not pushEvents[hashPos(oldPos)] or creature:getId() ~= pushEvents[hashPos(oldPos)]:getId() then
        return
    end

    g_map.getTile(pushEvents[hashPos(oldPos)]:getPosition()):setTimer(0)
    pushEvents[hashPos(oldPos)] = nil
end)

function walkMW(dir)
    local ps = pos()
    if not walk(dir) then
        return
    end
    local tile = g_map.getTile(ps)
    if not tile then
        return
    end

    local topUseThing = tile:getTopUseThing()

    if not topUseThing then
        return
    end

    useWith(3180, topUseThing)
end

onKeyDown(function(keys)
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    if keys == 'Shift+W' then
        walkMW(North)
    elseif keys == 'Shift+A' then
        walkMW(West)
    elseif keys == 'Shift+S' then
        walkMW(South)
    elseif keys == 'Shift+D' then
        walkMW(East)
    elseif keys == 'Shift+Q' then
        walkMW(NorthWest)
    elseif keys == 'Shift+E' then
        walkMW(NorthEast)
    elseif keys == 'Shift+Z' then
        walkMW(SouthWest)
    elseif keys == 'Shift+C' then
        walkMW(SouthEast)
    end

end)

setDefaultTab('Main')

local supaFolom = macro(100, "Supa Folow", function()

    local followingCreature = g_game.getFollowingCreature()
    if followingCreature then
        followTarget = followingCreature:getId()
        return
    end

    local creatures = g_map.getSpectators(pos())
    for _, creature in ipairs(creatures) do
        if creature:getId() == followTarget then
            g_game.follow(creature)
            return
        end
    end

end)

function isStairs(thing)
    return thing:getId() == 1948 or thing:getId() == 1968
end



hotkey("U", function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    dropPlants(getNearTiles(pos(), 1))

end)

hotkey("H", function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    -- pick up plants regardless of direction
    local pp = pos()

    local tiles = getNearTiles(pos(), 1)

    local plants = {2980, 2981, 2982, 2983, 2984, 2985, 2986, 2987}

    local amount = 0

    for i, tile in ipairs(tiles) do
        if tile and tile:isWalkable() then
            local topThing = tile:getTopThing()
            if topThing and topThing:isItem() and table.find(plants, topThing:getId()) then

                local container = findItem(2872)

                if container then
                    g_game.move(topThing, container:getPosition(), 1)
                    amount = amount + 1
                end

            end
        end
    end
end)

local plants = {2980, 2981, 2982, 2983, 2984, 2985, 2986, 2987}
local plantsSet = {[2980] = true, [2981] = true, [2982] = true, [2983] = true, [2984] = true, [2985] = true, [2986] = true, [2987] = true}
hotkey("V", function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end
    local mouseTile = getTileUnderCursor()

    for i, thing in ipairs(mouseTile:getThings()) do
        if thing:isItem() and plantsSet[thing:getId()] then
            return
            
        end
    end


    for j, plant in ipairs(plants) do

        local dropItem = findItem(plant)

        if dropItem then

            g_game.move(dropItem, mouseTile:getPosition(), 1)

            break
        end

    end
end)

hotkey("F", function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    local dropItem = findItem(3031)


    if not dropItem then
        local platinumCoin = findItem(3035)
        if platinumCoin then
            g_game.use(platinumCoin)
            return
        end
    end

    if dropItem then
        local mouseTile = getTileUnderCursor()

        local count = 2
        if not dropItem then
            return
        end
        if dropItem:getCount() < 2 then
            count = 1
        end
        g_game.move(dropItem, mouseTile:getPosition(), count)

    end
end)

-- hotkey("B", function()
--     if modules.game_console and modules.game_console.isChatEnabled() then
--         return
--     end

--     local plants = {3503}
--     for j, plant in ipairs(plants) do

--         local dropItem = findItem(plant)

--         if dropItem then
--             local mouseTile = getTileUnderCursor()
--             -- drop in random position
--             local px = pos()
--             local pt = {x = px.x + rd(), y = px.y + rd(), z = px.z}
--             g_game.move(dropItem, pt, 1)

--             break
--         end

--     end
-- end)


-- function rd()
--     return math.random() * -20 + 10
-- end

-- macro(100, "drop par", function()


--     if modules.game_console and modules.game_console.isChatEnabled() then
--         return
--     end

--     local plants = {3503}
--     -- local plants = {3492}
--     -- local plants = {3606}
--     local px = pos()
--     local pt = {x = px.x + rd(), y = px.y + rd(), z = px.z}


--     local tile = g_map.getTile(pt)
--     if not tile then
--         return
--     end
--     local topThing = tile:getTopThing()

--     if topThing and topThing:isItem() and topThing:getId() == plants[1] then
--         return
--     end

--     for j, plant in ipairs(plants) do

--         local dropItem = findItem(plant)

--         if dropItem then
            
            
--             g_game.move(dropItem, pt, 2)

--             break
--         end

--     end
    
-- end)

-- local t = 0
-- local range = 8
-- local itemID = 3503
-- local lastCount = 0
-- local total = 0


-- macro(100, "drop par", function()

--     local dim = range * 2
--     if total > 14 then
--         delay(3000)
--         total = 0
--     end
--     print(t)
--     if lastCount > 3 then
--         lastCount = 0
--         t = t + 2
--         return
--     end

--     if t > (dim + 1) * (dim) then
--         return
--     end
--     local px = pos()

--     local sx = -range + t % dim
--     local sy = -range + math.floor(t / dim)    

--     local pt = {x = px.x + sx, y = px.y + sy, z = px.z}
    
--     local item = findItem(itemID)

--     g_game.move(item, pt, 1)

--     lastCount = lastCount + 1
--     total = total + 1
-- end)





-- onTextMessage(function(mode, text)
--     print(mode, text)
-- end)



-- 


-- hotkey("Shift+0", function()

--     if modules.game_console and modules.game_console.isChatEnabled() then
--         return
--     end

--     local tile = getTileUnderCursor()
--     if tile then
--         local topThing = tile:getTopUseThing()

--         if topThing:getId() == 2129 then
--             topThing:setMarked("red")
--             schedule(tile:getTimer() - 150, function()
--                 useWith(3180, tile:getTopUseThing())
--             end)
--         end



--     end
    
-- end)



-- hotkey("G", function()

--     if modules.game_console and modules.game_console.isChatEnabled() then
--         return
--     end

    

--     local topTile = g_map.getTile({x = posx() + 1, y = posy() - 1, z = posz()})
--     local topThing = topTile:getTopUseThing()
--     useWith(9596, topThing)

--     local rightTile = g_map.getTile({x = posx() + 1, y = posy(), z = posz()})
--     local rightThing = rightTile:getTopUseThing()
--     g_game.move(rightThing, topTile:getPosition(), 1)
    
-- end)


-- say('https://www,youtube,com/watch?v=QRJYX3j-Olw&t=6s&ab_channel=GianGilbert')


-- local til = g_map.getTile({x = posx() + 2, y = posy(), z = posz()})
-- local topThing = til:getTopThing()
-- topThing:setId(3501)
-- print(topThing:getId())

-- say("https://discord,gg/YKZxSjNp")

macro(5000, "exeta", function()
    say("exana amp res")
end)

-- macro(1000, "uh", function()
--     local tile = g_map.getTile({x = posx() + 5, y = posy(), z = posz()})
--     local topCreature = tile:getTopCreature()

--     g_game.useInventoryItemWith(3160, topCreature, 0)
    
-- end)
