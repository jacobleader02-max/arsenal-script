local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

local Aimbot = {}
local CFG, sameTeam

function Aimbot.init(cfg, playersMod)
    CFG      = cfg
    sameTeam = playersMod.sameTeam
end

function Aimbot.isHeld()
    if CFG.AimKeyType == "mouse" then
        return UserInputService:IsMouseButtonPressed(CFG.AimKeyMouse)
    else
        return CFG.AimKeyCode ~= nil and UserInputService:IsKeyDown(CFG.AimKeyCode) or false
    end
end

function Aimbot.getTarget(camera)
    local vp     = camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local best   = CFG.FOV
    local bPart  = nil

    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if CFG.AimTeamCheck and sameTeam(player) then continue end
        local char = player.Character if not char then continue end
        local part = char:FindFirstChild(CFG.AimPart) or char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health<=0 then continue end
        local sp,on = camera:WorldToViewportPoint(part.Position)
        if not on or sp.Z<0 then continue end
        local d = (Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<best then best=d bPart=part end
    end
    return bPart
end

function Aimbot.apply(target, camera)
    if not target then return end
    local vp     = camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local sp     = camera:WorldToViewportPoint(target.Position)
    local delta  = Vector2.new(sp.X,sp.Y) - center
    local s      = 1 - (CFG.Smoothness/100)
    camera.CFrame = camera.CFrame * CFrame.Angles(
        math.rad(-delta.Y*s*0.1),
        math.rad(-delta.X*s*0.1), 0)
end

return Aimbot
