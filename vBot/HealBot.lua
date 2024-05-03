local standBySpells = false
local standByItems = false

local red = "#ff0800" -- "#ff0800" / #ea3c53 best
local blue = "#7ef9ff"
setDefaultTab("HP")





local healSpells = {"Salvation", "Divine Healing", "Intense Healing", "Light Healing"}
local healPots = {1, 2}




local rootWidget = g_ui.getRootWidget()


if rootWidget then
    healWindow = UI.createWindow('HealWindow', rootWidget)
    for i, spell in ipairs(healSpells) do
        local icon = UI.createWidget("NSpellIcon", healWindow.spellsPanel)
        
        local spellData = SpellInfo["Default"][spell]
        local clipId = SpellIcons[spellData.icon][1]
        local iconx = (clipId - 1) % 12 * 32
        local icony = math.floor((clipId - 1) / 12) * 32
        icon.spellIcon:setImageClip(iconx .. " " .. icony .. " 32 32")
        icon.spellName:setText(spell)
        icon.spellWords:setText(spellData.words)

    end

    for i, spell in ipairs(healPots) do
        local icon = UI.createWidget("NPotIcon", healWindow.potsPanel)
        


    end

    healWindow:hide()
    healWindow.closeButton.onClick = function(widget)
        healWindow:hide()
    end

end

UI.Button("Healing", function()
    healWindow:show()
    healWindow:raise()
    healWindow:focus()
end)

if storage[name()] == nil then
    storage[name()] = {}
end

UI.Label("Healing spells")

local hasUtito = 0

hotkey("f7", function()
    hasUtito = now
end)

local timePassed = 0

local cooldowns = {
    exg = now,
    exs = now,
    exgs = now,
    ex = now,
    pot = now
}

UI.HPanel = function(params, callback, parent) -- callback = function(widget, newParams)

    local widget = UI.createWidget('HPanel', parent)

    widget.title:setText("" .. params.min .. "% <= " .. params.title .. " <= " .. params.max .. "% " .. params.max -
                             params.min)

    widget.scroll1:setValue(params.min)
    widget.scroll2:setValue(params.max)

    widget.scroll1.onValueChange = function(scroll, value)
        params.min = value
        widget.title:setText("" .. params.min .. "% <= " .. params.title .. " <= " .. params.max .. "% " .. params.max -
                                 params.min)
        callback(widget, params)

    end
    widget.scroll2.onValueChange = function(scroll, value)
        params.max = value
        widget.title:setText("" .. params.min .. "% <= " .. params.title .. " <= " .. params.max .. "% " .. params.max -
                                 params.min)
        callback(widget, params)

    end

end

if type(storage[name()].healing) ~= "table" then

    if player:getVocation() == 1 then

        storage[name()].healing = {
            [1] = {
                o = 1,
                k = "pot",
                title = "POT",
                min = 0,
                max = 80
            },
            [2] = {
                o = 2,
                k = "pot",
                title = "POT",
                min = 0,
                max = 80
            },
            [3] = {
                o = 3,
                k = "exgs",
                title = "EXGS",
                min = 0,
                max = 90,
                sp = "exura med ico",
                mana = 50
            }
        }
    
    elseif player:getVocation() == 2 then
        storage[name()].healing = {
            [1] = {
                o = 1,
                k = "pot",
                title = "POT",
                min = 0,
                max = 80
            },
            [2] = {
                o = 2,
                k = "pot",
                title = "POT UT",
                min = 0,
                max = 85
            },
            [3] = {
                o = 3,
                k = "exgs",
                title = "EXGS",
                min = 0,
                max = 86,
                sp = "exura gran san",
                mana = 210
            },
            [4] = {
                o = 4,
                k = "exs",
                title = "EXS",
                min = 86,
                max = 94,
                sp = "exura san",
                mana = 160
            },
            [5] = {
                o = 5,
                k = "exg",
                title = "EXG",
                min = 94,
                max = 97,
                sp = "exura gran",
                mana = 70
            },
            [6] = {
                o = 6,
                k = "ex",
                title = "EX",
                min = 97,
                max = 99,
                sp = "exura",
                mana = 20
            }
        }
        
    end
end

for i = 1, #storage[name()].healing do
    local v = storage[name()].healing[i]
    UI.HPanel(v, function(widget, newParams)
        storage[name()].healing[i].min = newParams.min
        storage[name()].healing[i].max = newParams.max
    end)
end

macro(20, function()

    local hp = player:getHealthPercent()
    local mana = player:getMana() / player:getMaxMana() * 100

    local pt = storage[name()].healing[1].max
    if now - hasUtito < 10000 then
        pt = storage[name()].healing[2].max
    end

    if player:getVocation() == 2 and (mana <= 45 or hp <= pt) and now - cooldowns["pot"] > 1000 then
        
        cooldowns["pot"] = now        

        schedule(0, function()
            g_game.useInventoryItemWith(23374, player)
        end)

    elseif player:getVocation() == 1 and hp <= pt and now - cooldowns["pot"] > 1000 then
        cooldowns["pot"] = now        

        schedule(0, function()
            g_game.useInventoryItemWith(23375, player)
        end)

    end

    for i = 3, #storage[name()].healing do
        local v = storage[name()].healing[i]
        if hp > v.min and hp <= v.max and now - cooldowns[v.k] > 1000 then
            say(v.sp)
            cooldowns[v.k] = now
            return
        end
    end

end)



UI.Separator()



if g_game.getClientVersion() < 780 then
    UI.Label("In old tibia potions & runes work only when you have backpack with them opened")
end

UI.Separator()

UI.Label("Mana shield spell:")
UI.TextEdit(storage[name()].manaShield or "utamo vita", function(widget, newText)
    storage[name()].manaShield = newText
end)

local lastManaShield = 0
macro(20, "mana shield", function()
    if hasManaShield() or lastManaShield + 90000 > now then
        return
    end
    if TargetBot then
        TargetBot.saySpell(storage[name()].manaShield) -- sync spell with targetbot if available
    else
        say(storage[name()].manaShield)
    end
end)

UI.Label("Haste spell:")
UI.TextEdit(storage[name()].hasteSpell or "utani hur", function(widget, newText)
    storage[name()].hasteSpell = newText
end)



macro(2000, "haste", function()
    if hasHaste() then
        return
    end


    if TargetBot then
        TargetBot.saySpell(storage[name()].hasteSpell) -- sync spell with targetbot if available
    else
        say(storage[name()].hasteSpell)
    end




end)
