setDefaultTab("HP")


UI.Label("SS Burraile")

local ssaLabel = setupUI([[
Label
  height: 26
  width: 120
  anchors.bottom: parent.bottom
  anchors.left: parent.left
  margin-left: 300
  margin-bottom: 64
  !text: tr('SSA Mode ON')
  font: verdana-11px-rounded
  text-horizontal-auto-resize: true
  text-auto-resize: true


]], modules.game_interface.getMapPanel())

ssaLabel:setVisible(false)

if type(storage[name()]) ~= "table" then
    storage[name()] = {}
end


if type(storage[name()].ssitem) ~= "table" then
    storage[name()].ssitem = {
        on = false,
        title = "HP%",
        item = 3081,
        min = 0,
        max = 85
    }
end

local healingmacro = macro(100, function()
    local hp = player:getHealthPercent()
    if storage[name()].ssitem.max >= hp and hp >= storage[name()].ssitem.min then
        if getNeck() == nil or getNeck():getId() ~= storage[name()].ssitem.item then
            g_game.equipItemId(storage[name()].ssitem.item)
        end
        if getFinger() == nil or getFinger():getId() ~= 3048 and hp >= 70 then
            g_game.equipItemId(3048)
        elseif getFinger() == nil or getFinger():getId() ~= 3051 and hp <= 50 then
            g_game.equipItemId(3051)
        end
            
            
    end
end)

healingmacro.setOn(storage[name()].ssitem.on)

hotkey("6", function()

    if modules.game_console and modules.game_console.isChatEnabled() then
        return
    end

    storage[name()].ssitem.on = not storage[name()].ssitem.on
    healingmacro.setOn(storage[name()].ssitem.on)
    ssaLabel:setVisible(storage[name()].ssitem.on)
end)

UI.DualScrollItemPanel(storage[name()].ssitem, function(widget, newParams)
    storage[name()].ssitem = newParams
    healingmacro.setOn(storage[name()].ssitem.on and storage[name()].ssitem.item > 100)
end)