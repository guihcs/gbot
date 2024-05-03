-- config

local keyUp = "="
local keyDown = "-"
local fullLock = "*"
setDefaultTab("Tools")

-- script

local lockedLevel = pos().z
local fullLockAtive = false

onPlayerPositionChange(function(newPos, oldPos)
    lockedLevel = pos().z
    if fullLockAtive then
        return
    end
    modules.game_interface.getMapPanel():unlockVisibleFloor()
end)

onKeyPress(function(keys)
    if keys == keyDown then
        lockedLevel = lockedLevel + 1
        modules.game_interface.getMapPanel():lockVisibleFloor(lockedLevel)
    elseif keys == keyUp then
        lockedLevel = lockedLevel - 1
        modules.game_interface.getMapPanel():lockVisibleFloor(lockedLevel)
    elseif keys == fullLock then
        fullLockAtive = not fullLockAtive
        modules.game_interface.getMapPanel():lockVisibleFloor(lockedLevel)
    end
end)