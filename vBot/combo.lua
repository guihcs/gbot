setDefaultTab("Main")

local switch = addSwitch("combo", "Combo", function(widget)
    widget:setOn(not widget:isOn())
    storage.combo = widget:isOn()
end)

switch:setOn(storage.combo)

modules.combo = {}
modules.combo.switch = switch

local granCon = getSpellData("exori gran con")
local exoriCon = getSpellData("exori con")

function getSpellCoolDownData(data)

    if not data then
        return false
    end
    local icon = modules.game_cooldown.isCooldownIconActive(data.id)
    local group = false
    for groupId, duration in pairs(data.group) do
        if modules.game_cooldown.isGroupCooldownIconActive(groupId) then
            group = true
            break
        end
    end
    if icon or group then
        return true
    else
        return false
    end
end

onMissle(function(missile)
    if not storage.combo then
        return
    end
    local src = missile:getSource()

    local mid = missile:getId()

    if mid ~= 19 and mid ~= 58 then
        return
    end

    if src.x ~= posx() or src.y ~= posy() or src.z ~= posz() then
        return
    end



    if not getSpellCoolDownData(granCon) then
        say("exori gran con")
        return
    elseif not getSpellCoolDownData(exoriCon) then
        say("exori con")
        return
    end

end)

-- if config.enabled and config.onShootEnabled then 
--   if not config.shootLeader or config.shootLeader:len() == 0 then
--     return
--   end
--   local src = missle:getSource()
--   if src.z ~= posz() then
--     return
--   end
--   local from = g_map.getTile(src)
--   local to = g_map.getTile(missle:getDestination())
--   if not from or not to then
--     return
--   end
--   local fromCreatures = from:getCreatures()
--   local toCreatures = to:getCreatures()
--   if #fromCreatures ~= 1 or #toCreatures ~= 1 then
--     return
--   end
--   local c1 = fromCreatures[1]
--   local t1 = toCreatures[1]
--   leaderTarget = t1
--   if c1:getName():lower() == config.shootLeader:lower() then
--     if config.attackItemEnabled and config.item and config.item > 100 and findItem(config.item) then
--       useWith(config.item, t1)
--     end
--     if config.attackSpellEnabled and config.spell:len() > 1 then
--       say(config.spell)
--     end 
--   end
-- end
