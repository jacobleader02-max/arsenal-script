local BASE = "https://raw.githubusercontent.com/jacobleader02-max/arsenal-script/main/"
local function req(file)
    return loadstring(game:HttpGet(BASE..file))()
end

local Utils      = req("utils.lua")
local CFG        = req("config.lua")
local PlrMod     = req("players.lua")
local ESP        = req("esp.lua")
local Aimbot     = req("aimbot.lua")
local Knife      = req("knife.lua")
local UI         = req("ui.lua")
local HttpService= game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players    = game:GetService("Players")
local LocalPlayer= Players.LocalPlayer
local Camera     = workspace.CurrentCamera

ESP.init(CFG, Utils, PlrMod)
Aimbot.init(CFG, PlrMod)
Knife.init(CFG, PlrMod)
UI.init(CFG, Utils)

local tabFrames = UI.getTabs()

-- Player hooks
Players.PlayerAdded:Connect(function(p) ESP.make(p) end)
Players.PlayerRemoving:Connect(function(p)
    Knife.onPlayerLeave(p)
    ESP.remove(p)
end)
for _,p in ipairs(Players:GetPlayers()) do ESP.make(p) end

-- Player mods
local function applyStats()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.WalkSpeed    = CFG.WalkSpeed
    hum.UseJumpPower = true
    hum.JumpPower    = CFG.JumpPower
end
RunService.Heartbeat:Connect(function()
    if CFG.WalkSpeed~=16 or CFG.JumpPower~=50 then applyStats() end
end)
LocalPlayer.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid") applyStats()
end)
RunService.Stepped:Connect(function()
    if not CFG.Noclip then return end
    local char = LocalPlayer.Character if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if not CFG.InfJump then return end
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- FOV circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible=false FOVCircle.Radius=CFG.FOV
FOVCircle.Color=Color3.fromRGB(140,70,255) FOVCircle.Thickness=1
FOVCircle.Filled=false FOVCircle.NumSides=64

-- Main loop
RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
    FOVCircle.Radius   = CFG.FOV
    FOVCircle.Visible  = CFG.AimbotEnabled

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos  = myRoot and myRoot.Position

    Knife.update()

    if CFG.AimbotEnabled and Aimbot.isHeld() then
        local target = Aimbot.getTarget(Camera)
        Aimbot.apply(target, Camera)
    end

    ESP.update(Camera, myPos)
end)

-- Config system
local DEFAULTS = req("config.lua")
local SERIALISABLE={
    "ESPEnabled","ShowBoxes","ShowNames","ShowDistance","ShowHealth","ESPTeamCheck",
    "AimbotEnabled","FOV","Smoothness","AimPart","AimTeamCheck",
    "KnifeEnabled","WalkSpeed","JumpPower","Noclip","InfJump",
}
local widgetRefs={}
local function reg(key,ref) if ref then widgetRefs[key]=ref end end

local function exportCFG()
    local t={} for _,k in ipairs(SERIALISABLE) do t[k]=CFG[k] end
    local ok,str=pcall(function() return HttpService:JSONEncode(t) end)
    return ok and str or "ERROR"
end
local function importCFG(str)
    local ok,t=pcall(function() return HttpService:JSONDecode(str) end)
    if not ok or type(t)~="table" then return false end
    for _,k in ipairs(SERIALISABLE) do
        if t[k]~=nil then
            CFG[k]=t[k]
            local ref=widgetRefs[k]
            if ref then
                if ref.setState then ref.setState(CFG[k]) end
                if ref.setValue then ref.setValue(CFG[k]) end
            end
        end
    end
    applyStats() return true
end
local function resetCFG()
    for _,k in ipairs(SERIALISABLE) do
        CFG[k]=DEFAULTS[k]
        local ref=widgetRefs[k]
        if ref then
            if ref.setState then ref.setState(CFG[k]) end
            if ref.setValue then ref.setValue(CFG[k]) end
        end
    end
    applyStats()
end

-- ESP tab
local espTab=tabFrames["ESP"]
UI.mkSection(espTab,"Visibility")
reg("ESPEnabled",   UI.mkToggle(espTab,"ESP Enabled",    CFG.ESPEnabled,   function(v) CFG.ESPEnabled=v end))
reg("ShowBoxes",    UI.mkToggle(espTab,"Boxes",          CFG.ShowBoxes,    function(v) CFG.ShowBoxes=v end))
reg("ShowNames",    UI.mkToggle(espTab,"Names",          CFG.ShowNames,    function(v) CFG.ShowNames=v end))
reg("ShowDistance", UI.mkToggle(espTab,"Distance",       CFG.ShowDistance, function(v) CFG.ShowDistance=v end))
reg("ShowHealth",   UI.mkToggle(espTab,"Health",         CFG.ShowHealth,   function(v) CFG.ShowHealth=v end))
UI.mkSection(espTab,"Team")
reg("ESPTeamCheck", UI.mkToggle(espTab,"Skip Teammates", CFG.ESPTeamCheck, function(v) CFG.ESPTeamCheck=v end))

-- Aimbot tab
local aimTab=tabFrames["Aimbot"]
UI.mkSection(aimTab,"Aimbot")
reg("AimbotEnabled",UI.mkToggle(aimTab,"Aimbot Enabled", CFG.AimbotEnabled,function(v) CFG.AimbotEnabled=v end))
reg("FOV",          UI.mkNumInput(aimTab,"FOV",       CFG.FOV,       1,500,function(v) CFG.FOV=v end))
reg("Smoothness",   UI.mkNumInput(aimTab,"Smoothness",CFG.Smoothness,0,100,function(v) CFG.Smoothness=v end))
UI.mkDropdown(aimTab,"Aim Part",{"Head","HumanoidRootPart","Torso"},"Head",function(v) CFG.AimPart=v end)
UI.mkSection(aimTab,"Team")
reg("AimTeamCheck", UI.mkToggle(aimTab,"Skip Teammates",CFG.AimTeamCheck,function(v) CFG.AimTeamCheck=v end))
UI.mkSection(aimTab,"Keybind")
UI.mkKeybind(aimTab,"Aim Key","E",function(input,label)
    if input.UserInputType==Enum.UserInputType.MouseButton2 then
        CFG.AimKeyType="mouse" CFG.AimKeyMouse=Enum.UserInputType.MouseButton2
    elseif input.UserInputType==Enum.UserInputType.MouseButton3 then
        CFG.AimKeyType="mouse" CFG.AimKeyMouse=Enum.UserInputType.MouseButton3
    elseif input.KeyCode~=Enum.KeyCode.Unknown then
        CFG.AimKeyType="key" CFG.AimKeyCode=input.KeyCode
    end
    CFG.AimKeyLabel=label
end)
UI.mkSection(aimTab,"Knife Stalk")
reg("KnifeEnabled", UI.mkToggle(aimTab,"Knife Enabled",CFG.KnifeEnabled,function(v) CFG.KnifeEnabled=v end))
UI.mkKeybind(aimTab,"Stalk Key  [press=start  press again=cancel]","F",function(input,_)
    if input.KeyCode~=Enum.KeyCode.Unknown then
        CFG.KnifeKey=input.KeyCode
        CFG.KnifeKeyLabel=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
    end
end)

-- Player tab
local plrTab=tabFrames["Player"]
UI.mkSection(plrTab,"Movement")
reg("WalkSpeed",UI.mkNumInput(plrTab,"Walk Speed",CFG.WalkSpeed,16,500,function(v) CFG.WalkSpeed=v applyStats() end))
reg("JumpPower",UI.mkNumInput(plrTab,"Jump Power",CFG.JumpPower,50,500,function(v) CFG.JumpPower=v applyStats() end))
UI.mkSection(plrTab,"Modifiers")
reg("InfJump",UI.mkToggle(plrTab,"Inf Jump",false,function(v) CFG.InfJump=v end))
reg("Noclip", UI.mkToggle(plrTab,"Noclip",  false,function(v)
    CFG.Noclip=v
    if not v then
        local char=LocalPlayer.Character
        if char then for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true end
        end end
    end
end))

-- Config tab
local cfgTab=tabFrames["Config"]
UI.mkSection(cfgTab,"Export")
local exportBox=UI.mkTextBox(cfgTab,"// click Export")
UI.mkButton(cfgTab,"> Export Config",function() exportBox.Text=exportCFG() end)
UI.mkSection(cfgTab,"Import")
local importBox=UI.mkTextBox(cfgTab,"// paste config here")
UI.mkButton(cfgTab,"> Import Config",function()
    if not importCFG(importBox.Text) then importBox.Text="ERROR: bad json" end
end)
UI.mkSection(cfgTab,"Reset")
UI.mkButton(cfgTab,"> Reset to Default",function() resetCFG() end)

-- Show ESP tab by default
tabFrames["ESP"].Visible = true
