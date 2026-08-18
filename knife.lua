local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

local Knife = {}
local CFG, sameTeam
local stalkTarget  = nil
local stalkActive  = false
local killCooldown = false

function Knife.init(cfg, playersMod)
    CFG      = cfg
    sameTeam = playersMod.sameTeam
end

function Knife.isActive() return stalkActive end
function Knife.getTarget() return stalkTarget end

local function getClosest()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil,nil end
    local bestDist = math.huge
    local bRoot,bChar = nil,nil
    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if CFG.AimTeamCheck and sameTeam(player) then continue end
        local char = player.Character if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then continue end
        if root.Position.Y < -10 then continue end
        local dist = (root.Position-myRoot.Position).Magnitude
        if dist<bestDist then bestDist=dist bRoot=root bChar=char end
    end
    return bRoot,bChar
end

function Knife.teleport(targetRoot)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    if targetRoot.Position.Y < -10 then return end
    local look   = targetRoot.CFrame.LookVector
    local behind = targetRoot.Position - (look * 2)
    myRoot.CFrame = CFrame.new(behind, targetRoot.Position)
end

function Knife.kill()
    for i=0,5 do
        task.delay(i*0.06, function()
            pcall(function() mouse1press() end)
            task.delay(0.03, function() pcall(function() mouse1release() end) end)
        end)
    end
end

function Knife.start()
    if not CFG.KnifeEnabled then return end
    local bRoot,bChar = getClosest()
    if not bRoot then return end
    for _,player in ipairs(Players:GetPlayers()) do
        if player.Character == bChar then
            stalkTarget = player
            break
        end
    end
    stalkActive = true
end

function Knife.cancel()
    stalkActive  = false
    stalkTarget  = nil
    killCooldown = false
end

function Knife.onPlayerLeave(player)
    if stalkTarget == player then Knife.cancel() end
end

function Knife.update()
    if not stalkActive or not stalkTarget then return end

    local tarChar = stalkTarget.Character
    local tarRoot = tarChar and tarChar:FindFirstChild("HumanoidRootPart")
    local tarHum  = tarChar and tarChar:FindFirstChildOfClass("Humanoid")

    if not tarRoot or not tarHum or tarHum.Health <= 0 then
        -- target died — cancel stalk immediately
        Knife.cancel()
        return
    end

    if tarRoot.Position.Y < -10 then
        -- underground — cancel stalk
        Knife.cancel()
        return
    end

    Knife.teleport(tarRoot)
    if not killCooldown then
        killCooldown = true
        Knife.kill()
        task.delay(0.6, function()
            killCooldown = false
            local h = tarChar and tarChar:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then
                Knife.cancel()
            end
        end)
    end
end

-- Key listener
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if CFG and CFG.KnifeEnabled and input.KeyCode == CFG.KnifeKey then
        if stalkActive then
            Knife.cancel()
        else
            Knife.start()
        end
    end
end)

return Knife
