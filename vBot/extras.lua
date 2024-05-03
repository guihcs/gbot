setDefaultTab("Main")

-- securing storage namespace
local panelName = "extras"
if not storage[panelName] then
    storage[panelName] = {}
end
local settings = storage[panelName]

-- basic elements
extrasWindow = UI.createWindow('ExtrasWindow', rootWidget)
extrasWindow:hide()
extrasWindow.closeButton.onClick = function(widget)
    extrasWindow:hide()
end

extrasWindow.onGeometryChange = function(widget, old, new)
    if old.height == 0 then
        return
    end

    settings.height = new.height
end

extrasWindow:setHeight(settings.height or 360)

-- available options for dest param
local rightPanel = extrasWindow.content.right
local leftPanel = extrasWindow.content.left

-- objects made by Kondrah - taken from creature editor, minor changes to adapt
local addCheckBox = function(id, title, defaultValue, dest, tooltip)
    local widget = UI.createWidget('ExtrasCheckBox', dest)
    widget.onClick = function()
        widget:setOn(not widget:isOn())
        settings[id] = widget:isOn()
        if id == "checkPlayer" then
            local label = rootWidget.newHealer.targetSettings.vocations.title
            if not widget:isOn() then
                label:setColor("#d9321f")
                label:setTooltip("! WARNING ! \nTurn on check players in extras to use this feature!")
            else
                label:setColor("#dfdfdf")
                label:setTooltip("")
            end
        end
    end
    widget:setText(title)
    widget:setTooltip(tooltip)
    if settings[id] == nil then
        widget:setOn(defaultValue)
    else
        widget:setOn(settings[id])
    end
    settings[id] = widget:isOn()
end

local addItem = function(id, title, defaultItem, dest, tooltip)
    local widget = UI.createWidget('ExtrasItem', dest)
    widget.text:setText(title)
    widget.text:setTooltip(tooltip)
    widget.item:setTooltip(tooltip)
    widget.item:setItemId(settings[id] or defaultItem)
    widget.item.onItemChange = function(widget)
        settings[id] = widget:getItemId()
    end
    settings[id] = settings[id] or defaultItem
end

local addTextEdit = function(id, title, defaultValue, dest, tooltip)
    local widget = UI.createWidget('ExtrasTextEdit', dest)
    widget.text:setText(title)
    widget.textEdit:setText(settings[id] or defaultValue or "")
    widget.text:setTooltip(tooltip)
    widget.textEdit.onTextChange = function(widget, text)
        settings[id] = text
    end
    settings[id] = settings[id] or defaultValue or ""
end

local addScrollBar = function(id, title, min, max, defaultValue, dest, tooltip)
    local widget = UI.createWidget('ExtrasScrollBar', dest)
    widget.text:setTooltip(tooltip)
    widget.scroll.onValueChange = function(scroll, value)
        widget.text:setText(title .. ": " .. value)
        if value == 0 then
            value = 1
        end
        settings[id] = value
    end
    widget.scroll:setRange(min, max)
    widget.scroll:setTooltip(tooltip)
    if max - min > 1000 then
        widget.scroll:setStep(100)
    elseif max - min > 100 then
        widget.scroll:setStep(10)
    end
    widget.scroll:setValue(settings[id] or defaultValue)
    widget.scroll.onValueChange(widget.scroll, widget.scroll:getValue())
end

UI.Button("vBot Settings and Scripts", function()
    extrasWindow:show()
    extrasWindow:raise()
    extrasWindow:focus()
end)
UI.Separator()

---- to maintain order, add options right after another:
--- add object
--- add variables for function (optional)
--- add callback (optional)
--- optionals should be addionaly sandboxed (if true then end)

addItem("rope", "Rope Item", 9596, leftPanel,
    "This item will be used in various bot related scripts as default rope item.")
addItem("shovel", "Shovel Item", 9596, leftPanel,
    "This item will be used in various bot related scripts as default shovel item.")
addItem("machete", "Machete Item", 9596, leftPanel,
    "This item will be used in various bot related scripts as default machete item.")
addItem("scythe", "Scythe Item", 9596, leftPanel,
    "This item will be used in various bot related scripts as default scythe item.")
addCheckBox("pathfinding", "CaveBot Pathfinding", true, leftPanel,
    "Cavebot will automatically search for first reachable waypoint after missing 10 goto's.")
addScrollBar("talkDelay", "Global NPC Talk Delay", 0, 2000, 1000, leftPanel,
    "Breaks between each talk action in cavebot (time in miliseconds).")
addScrollBar("looting", "Max Loot Distance", 0, 50, 40, leftPanel,
    "Every loot corpse futher than set distance (in sqm) will be ignored and forgotten.")
addScrollBar("lootDelay", "Loot Delay", 0, 1000, 200, leftPanel,
    "Wait time for loot container to open. Lower value means faster looting. \n WARNING if you are having looting issues(e.g. container is locked in closing/opnening), increase this value.")
addScrollBar("huntRoutes", "Hunting Rounds Limit", 0, 300, 50, leftPanel,
    "Round limit for supply check, if character already made more rounds than set, on next supply check will return to city.")
addScrollBar("killUnder", "Kill monsters below", 0, 100, 1, leftPanel,
    "Force TargetBot to kill added creatures when they are below set percentage of health - will ignore all other TargetBot settings.")
addScrollBar("gotoMaxDistance", "Max GoTo Distance", 0, 127, 30, leftPanel,
    "Maximum distance to next goto waypoint for the bot to try to reach.")
addCheckBox("lootLast", "Start loot from last corpse", true, leftPanel,
    "Looting sequence will be reverted and bot will start looting newest bodies.")
addCheckBox("joinBot", "Join TargetBot and CaveBot", false, leftPanel, "Cave and Target tabs will be joined into one.")
addCheckBox("reachable", "Target only pathable mobs", false, leftPanel, "Ignore monsters that can't be reached.")

addCheckBox("title", "Custom Window Title", true, rightPanel,
    "Personalize OTCv8 window name according to character specific.")
if true then
    local vocText = ""

    if voc() == 1 or voc() == 11 then
        vocText = "- EK"
    elseif voc() == 2 or voc() == 12 then
        vocText = "- RP"
    elseif voc() == 3 or voc() == 13 then
        vocText = "- MS"
    elseif voc() == 4 or voc() == 14 then
        vocText = "- ED"
    end

    macro(5000, function()
        if settings.title then
            if hppercent() > 0 then
                g_window.setTitle("Tibia - " .. name() .. " - " .. lvl() .. "lvl " .. vocText)
            else
                g_window.setTitle("Tibia - " .. name() .. " - DEAD")
            end
        else
            g_window.setTitle("Tibia - " .. name())
        end
    end)
end

addCheckBox("separatePm", "Open PM's in new Window", false, rightPanel,
    "PM's will be automatically opened in new tab after receiving one.")
if true then
    onTalk(function(name, level, mode, text, channelId, pos)
        if mode == 4 and settings.separatePm then
            local g_console = modules.game_console
            local privateTab = g_console.getTab(name)
            if privateTab == nil then
                privateTab = g_console.addTab(name, true)
                g_console.addPrivateText(g_console.applyMessagePrefixies(name, level, text),
                    g_console.SpeakTypesSettings['private'], name, false, name)
            end
            return
        end
    end)
end

addTextEdit("useAll", "Use All Hotkey", "space", rightPanel,
    "Set hotkey for universal actions - rope, shovel, scythe, use, open doors")
if true then
    local useId = {1644, 1642, 9558, 30833, 30837, 34847, 1764, 21051, 30823, 6264, 5282, 20453, 20454, 20474, 11708,
                   11705, 6257, 6256, 2772, 27260, 2773, 1632, 1633, 1948, 435, 6252, 6253, 5007, 4911, 1629, 1630,
                   5108, 5107, 5281, 1968, 435, 1948, 5542, 31116, 31120, 30742, 31115, 31118, 20474, 5737, 5736, 5734,
                   5733, 31202, 31228, 31199, 31200, 33262, 30824, 5125, 5126, 5116, 5117, 8257, 8258, 8255, 8256, 5120,
                   30777, 30776, 23873, 23877, 5736, 6264, 31262, 31130, 31129, 6250, 6249, 5122, 30049, 7131, 7132,
                   7727, 30838, 30835, 30774, 30772, 5289, 22506, 8259, 8363}
    local shovelId = {606, 593, 867, 608}
    local ropeId = {17238, 12202, 12935, 386, 421, 21966, 14238}
    local macheteId = {2130, 3696}
    local scytheId = {3653}

    setDefaultTab("Tools")
    -- script
    if settings.useAll and settings.useAll:len() > 0 then
        hotkey(settings.useAll, function()
            if not modules.game_walking.wsadWalking then
                return
            end
            for _, tile in pairs(g_map.getTiles(posz())) do
                if distanceFromPlayer(tile:getPosition()) < 2 then
                    for _, item in pairs(tile:getItems()) do
                        -- use
                        if table.find(useId, item:getId()) then
                            use(item)
                            return
                        elseif table.find(shovelId, item:getId()) then
                            useWith(settings.shovel, item)
                            return
                        elseif table.find(ropeId, item:getId()) then
                            useWith(settings.rope, item)
                            return
                        elseif table.find(macheteId, item:getId()) then
                            useWith(settings.machete, item)
                            return
                        elseif table.find(scytheId, item:getId()) then
                            useWith(settings.scythe, item)
                            return
                        end
                    end
                end
            end
        end)
    end
end

local activeTimers = {}
local mwTimers = {}

onAddThing(function(tile, thing)

    local timer = 0
    if thing:getId() == 2129 then -- mwall id
        timer = 20000 -- mwall time
    elseif thing:getId() == 2130 then -- wg id
        timer = 46000 -- wg time
    else
        return
    end

    local pos = tile:getPosition().x * 1e15 + tile:getPosition().y * 1e6 + tile:getPosition().z
    -- mwTimers[pos] = now
    if not activeTimers[pos] or activeTimers[pos] < now then
        activeTimers[pos] = now + timer
    end
    tile:setTimer(timer)
end)

onRemoveThing(function(tile, thing)

    if (thing:getId() == 2129 or thing:getId() == 2130) and tile:getGround() then
        local pos = tile:getPosition().x * 1e15 + tile:getPosition().y * 1e6 + tile:getPosition().z
        activeTimers[pos] = nil
        tile:setTimer(0)
    end
end)

addCheckBox("antiKick", "Anti - Kick", true, rightPanel, "Turn every 10 minutes to prevent kick.")
if true then
    macro(600 * 1000, function()
        if not settings.antiKick then
            return
        end
        local dir = player:getDirection()
        turn((dir + 1) % 4)
        schedule(50, function()
            turn(dir)
        end)
    end)
end

addCheckBox("bless", "Buy bless at login", true, rightPanel, "Say !bless at login.")
if true then
    local blessed = false
    onTextMessage(function(mode, text)
        if not settings.bless then
            return
        end

        text = text:lower()

        if text == "you already have all blessings." then
            blessed = true
        end
    end)
    if settings.bless then
        if player:getBlessings() == 0 then
            say("!bless")
            schedule(2000, function()
                if g_game.getClientVersion() > 1000 then
                    if not blessed and player:getBlessings() == 0 then
                        warn("!! Blessings not bought !!")
                    end
                end
            end)
        end
    end
end

local function checkPlayers()
    for i, spec in ipairs(getSpectators()) do
        -- print(spec:getPosition().z, posz())
        if spec:isPlayer() and spec ~= player and #spec:getText() < 1 and spec:getPosition().z == posz() then
            g_game.look(spec)
        end
    end
end

schedule(500, function()
    checkPlayers()
end)

-- onPlayerPositionChange(function(x, y)

--     if x.z ~= y.z then
--         schedule(20, function()
--             checkPlayers()
--         end)
--     end
-- end)

onCreatureAppear(function(creature)
    if creature:isPlayer() and creature ~= player and #creature:getText() < 1 and creature:getPosition().z == posz() then
        g_game.look(creature)
        found = now
    end
end)

macro(5000, function()
    checkPlayers()
end)

-- local regex = [[You see ([^\(]*) \(Level ([0-9]*)\)((?:.)* of the ([\w ]*),|)]]
local regex = [[You see ([^\(]*) \(Level ([0-9]*)\)((?:.)* of the ([\w ]*),|)]]
onTextMessage(function(mode, text)

  local re = regexMatch(text, regex)
  if #re ~= 0 then
      local name = re[1][2]
      local level = re[1][3]
      local guild = re[1][5] or ""

        if guild:len() > 10 then
            guild = guild:sub(1, 10) -- change to proper (last) values
            guild = guild .. "..."
        end
        local voc
        local vocp = 5
        if text:lower():find("sorcerer") then
            voc = "MS"
            vocp = 1
        elseif text:lower():find("druid") then
            voc = "ED"
            vocp = 1
        elseif text:lower():find("knight") then
            voc = "EK"
            vocp = 3
        elseif text:lower():find("paladin") then
            voc = "RP"
            vocp = 2
        end
        local creature = getCreatureByName(name)
        if creature then
            creature.lvl = level
            creature.vocp = vocp
            creature.voc = voc
            creature.guild = guild
            creature:setText("\n" .. level .. voc .. "\n" .. guild)
        end
    end
end)

addCheckBox("highlightTarget", "Highlight Current Target", true, rightPanel,
    "Additionaly hightlight current target with red glow")
if true then
    local function forceMarked(creature)
        if target() == creature then
            creature:setMarked("red")
            return schedule(333, function()
                forceMarked(creature)
            end)
        end
    end

    onAttackingCreatureChange(function(newCreature, oldCreature)
        if not settings.highlightTarget then
            return
        end
        if oldCreature then
            oldCreature:setMarked('')
        end
        if newCreature then
            forceMarked(newCreature)
        end
    end)
end

setDefaultTab("Main")

if not storage.oberon then
    storage.oberon = false
end

local switch = addSwitch("oberon", "Oberon", function(widget)
    widget:setOn(not widget:isOn())
    storage.oberon = widget:isOn()
end)

switch:setOn(storage.oberon)

onTalk(function(name, level, mode, text, channelId, pos)
    if not storage.oberon then
        return
    end
    if mode == 34 then
        if string.find(text, "The world will suffer for its iddle laziness!") then
            say("Are you ever going to fight or do you prefer talking!")
        elseif string.find(text, "You appear like a worm among men!") then
            say("How appropriate, you look like something worms already got the better of!")
        elseif string.find(text, "People fall at my feet when they see me coming!") then
            say("Even before they smell your breath?")
        elseif string.find(text, "This will be the end of mortal man!") then
            say("Then let me show you the concept of mortality before it!")
        elseif string.find(text, "I will remove you from this plane of existence!") then
            say("Too bad you barely exist at all!")
        elseif string.find(text, "Dragons will soon rule this world, I am their herald!") then
            say("Excuse me but I still do not get the message!")
        elseif string.find(text, "The true virtue of chivalry are my belief!") then
            say("Dare strike up a Minnesang and you will receive your last accolade!")
        elseif string.find(text, "I lead the most honourable and formidable following of knights!") then
            say("Then why are we fighting alone right now?")
        elseif string.find(text, "ULTAH SALID'AR, ESDO LO!") then
            say("SEHWO ASIMO, TOLIDO ESD!")
        end
    end
end)
