setDefaultTab("Anti-Push")

local pushLabel = setupUI([[
Label
  height: 26
  width: 26
  anchors.bottom: parent.bottom
  anchors.left: parent.left
  margin-left: 300
  margin-bottom: 12

  Label
    id: lblHighscore
    color: white
    font: verdana-11px-rounded
    height: 12
    opacity: 0.87
    anchors.left: parent.left
    anchors.top: prev.bottom
    text-horizontal-auto-resize: true
    text-auto-resize: true
    !text: tr('')


]], modules.game_interface.getMapPanel())

gpPushEnabled = false
gpPushDelay = 600 -- safe value: 600ms

local pullMacro = macro(600, "Enable Pull", function()
    push(0, -1, 0)
    push(0, 1, 0)
    push(-1, -1, 0)
    push(-1, 0, 0)
    push(-1, 1, 0)
    push(1, -1, 0)
    push(1, 0, 0)
    push(1, 1, 0)
end)

function push(x, y, z)
    local position = player:getPosition()
    position.x = position.x + x
    position.y = position.y + y

    local tile = g_map.getTile(position)
    local thing = tile:getTopThing()
    if thing and thing:isItem() then
        g_game.move(thing, player:getPosition(), thing:getCount())
    end
end

-- check if item exists in tile
function tileHasItem(tile, id)
    if tile then
        local thing = tile:getTopUseThing()
        if thing and thing:isItem() and thing:getId() == id then
            return true
        end
    end
    return false
end

local e1m = macro(100, "Enable Anti-Push", function()

    dropCoin()
end)

function hasField(tile)
    for i, item in ipairs(tile:getItems()) do
        if item:getId() == 2118 or item:getId() == 2119 or item:getId() == 2122 or item:getId() == 105 or item:getId() ==
            2130 or item:getId() == 1949 or item:getId() == 1947 or item:getId() == 438 or item:getId() == 2012 or item:getId() == 432 then
            return true
        end
    end

    return false
end

local e2m = macro(100, "Enable Anti-Push with fire", function()

    -- check if there is fire field on the ground

    local pp = player:getPosition()


    local playerTile = g_map.getTile(pp)

    if not hasField(playerTile) then
        g_game.useInventoryItemWith(3192, player, 0)
        return
    end

    -- get all tiles around player
    local tiles = getNearTiles(pp, 1)

    for i, tile in ipairs(tiles) do
        if tile and tile:isWalkable() and not hasField(tile) then
            
            g_game.useInventoryItemWith(3192, player, 0)
            break
        end
    end

    dropCoin()

end)

hotkey('5', function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end
    e1m:setOff(true)
    e2m:setOff(true)

    if pullMacro:isOn() then
        pullMacro:setOff(true)
        pushLabel.lblHighscore:setText('')
    else
        pullMacro:setOn(true)
        pushLabel.lblHighscore:setText('Pull Enabled')
        pushLabel.lblHighscore:setColor('white')
    end
end)

hotkey('3', function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end
    e2m:setOff(true)
    pullMacro:setOff(true)
    if e1m:isOn() then
        e1m:setOff(true)
        pushLabel.lblHighscore:setText('')
    else
        e1m:setOn(true)
        pushLabel.lblHighscore:setText('Antipush Enabled')
        pushLabel.lblHighscore:setColor('yellow')
    end
end)

hotkey('4', function()
    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    e1m:setOff(true)
    pullMacro:setOff(true)
    if e2m:isOn() then
        e2m:setOff(true)
        pushLabel.lblHighscore:setText('')
    else
        e2m:setOn(true)
        pushLabel.lblHighscore:setText('Antipush Fire Enabled')
        pushLabel.lblHighscore:setColor('orange')
    end
end)

function dropCoin()

    local dropItem = findItem(3031)

    if not dropItem then
        local platinumCoin = findItem(3035)
        if platinumCoin then
            g_game.use(platinumCoin)
            return
        end
    end

    local tile = g_map.getTile(pos())

    if not tile then
        return
    end

    local topThing = tile:getTopThing()

    if topThing and topThing:isItem() and topThing:getId() == 3031 and topThing:getCount() > 1 then
        return
    end

    local count = 2
    if not dropItem then
        return
    end
    if dropItem:getCount() < 2 then
        count = 1
    end
    g_game.move(dropItem, pos(), count)

end