
-- local serverUrl = "ws://bot.trainorcreations.com:8000/"


-- BotServer.url = serverUrl
-- BotServer.init(name(), "UnholySouls")




-- BotServer.listen("targetcb", function(nm, message, topic)

--     if nm == name() and nm ~= "De Casada" then
--         return
    
--     end
--     print("targetcb")
--     local id = message.id

--     if id == nil then
--         print("cancelm")
--         targetID = nil  
--         g_game.cancelAttackAndFollow()
--         return
--     end

--     local creatures = g_map.getSpectatorsInRange(player:getPosition(), false, 10, 10)

--     for _, creature in ipairs(creatures) do
--         if creature:getId() == id then
--             g_game.attack(creature)
--             return
--         end
--     end

-- end)



-- UI.Button("Test target", function() 

    
--     -- BotServer.send("test", {name="hue"})

-- end)

-- local lastTarget = nil
-- local hasTarget = nil

-- macro(100, function()
--     if name() ~= "De Casada" then
--         return
--     end
--     if target() and target():getId() ~= lastTarget then
--         BotServer.send("targetcb", {id=target():getId()})
--         lastTarget = target():getId()
--         hasTarget = true
--     elseif not target() and hasTarget then
--         print("cancel")
--         BotServer.send("targetcb", {id=nil})
--         hasTarget = false      
--         lastTarget = nil
--     end
-- end)