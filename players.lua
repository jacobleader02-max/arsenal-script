local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local M = {}

function M.sameTeam(player)
    return player.Team ~= nil and player.Team == LocalPlayer.Team
end

return M
