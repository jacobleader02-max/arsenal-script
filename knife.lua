local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

local Knife = {}
local CFG, sameTeam
local stalkTarget   = nil
local stalkActive   = false
local killCooldown  = false
local killAllActive = false
local killAllQueue  = {}
local killAllIndex  = 1

function Knife.init(cfg, playersMod)
    CFG      = cfg
    sameTeam = playersMod.sameTeam
end

function Knife.isActive() return stalkActive end
function Knife.getTarget() return stalkTarget end
function Knife.killAllIsActive() return killAllActive end

local function getRandomEnemies()
    local list = {}
    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if sameTeam(player) then continue end
        local char = player.Character if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then continue end
        if root.Position.Y < -10 then continue end
        table.insert(list, player)
    end
    for i=#list,2,-1 do
        local j = math.random(1,i)
        list[i],list[j] = list[j],list[i]
    end
    return list
end

local function nextTarget()
    while killAllIndex <= #killAllQueue do
        local p    = killAllQueue[killAllIndex]
        local char = p and p.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then return p end
        killAllIndex = killAllIndex + 1
    end
    local remaining = getRandomEnemies()
    if #remaining == 0 then return nil end
    killAllQueue = remaining
    killAllIndex = 1
    return killAllQueue[1]
end

local function getClosest()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil,nil end
    local bestDist = math.huge
    local bRoot,bChar,bPlayer = nil,nil,nil
    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if sameTeam(player) then continue end
        local char = player.Character if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then continue end
        if root.Position.Y < -10 then continue end
        local dist = (root.Position-myRoot.Position).Magnitude
        if dist<bestDist then bestDist=dist bRoot=root bChar=char bPlayer=player end
    end
    return bRoot,bChar,bPlayer
end

function Knife.teleport(targetRoot)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    if targetRoot.Position.Y < -10 then return end
    -- Face their back by looking from behind toward their position
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

local function startStalk(player)
    stalkTarget  = player
    stalkActive  = true
    killCooldown = false
end

function Knife.cancel()
    stalkActive  = false
    stalkTarget  = nil
    killCooldown = false
end

function Knife.cancelAll()
    killAllActive = false
    killAllQueue  = {}
    killAllIndex  = 1
    Knife.cancel()
end

function Knife.start()
    if not CFG.KnifeEnabled then return end
    local _,_,bPlayer = getClosest()
    if bPlayer then startStalk(bPlayer) end
end

function Knife.startKillAll()
    killAllActive = true
    killAllQueue  = getRandomEnemies()
    killAllIndex  = 1
    local target  = nextTarget()
    if target then startStalk(target) end
end

function Knife.onPlayerLeave(player)
    if stalkTarget == player then
        Knife.cancel()
        if killAllActive then
            killAllIndex = killAllIndex + 1
            local next = nextTarget()
            if next then
                task.delay(0.2, function() startStalk(next) end)
            else
                Knife.cancelAll()
            end
        end
    end
end

function Knife.update()
    if not stalkActive or not stalkTarget then return end

    local tarChar = stalkTarget.Character
    local tarRoot = tarChar and tarChar:FindFirstChild("HumanoidRootPart")
    local tarHum  = tarChar and tarChar:FindFirstChildOfClass("Humanoid")

    if not tarRoot or not tarHum or tarHum.Health <= 0 or tarRoot.Position.Y < -10 then
        Knife.cancel()
        if killAllActive then
            killAllIndex = killAllIndex + 1
            local next = nextTarget()
            if next then
                task.delay(0.2, function() startStalk(next) end)
            else
                Knife.cancelAll()
            end
        end
        return
    end

    Knife.teleport(tarRoot)

    if not killCooldown then
        killCooldown = true
        Knife.kill()
        task.delay(0.5, function()
            killCooldown = false
            local h = tarChar and tarChar:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then
                Knife.cancel()
                if killAllActive then
                    killAllIndex = killAllIndex + 1
                    local next = nextTarget()
                    if next then
                        task.delay(0.3, function() startStalk(next) end)
                    else
                        Knife.cancelAll()
                    end
                end
            end
        end)
    end
end

-- Input
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if CFG and CFG.KnifeEnabled and input.KeyCode == CFG.KnifeKey then
        if killAllActive then return end
        if stalkActive then Knife.cancel() else Knife.start() end
    end
    if CFG and input.KeyCode == CFG.KillAllKey then
        if killAllActive then
            Knife.cancelAll()
        else
            Knife.startKillAll()
        end
    end
end)

return Knife
