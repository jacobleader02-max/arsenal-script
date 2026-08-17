local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESP   = {}
local store = {}
local CFG, C, newDraw, sameTeam

function ESP.init(cfg, utils, playersMod)
    CFG      = cfg
    C        = utils.C
    newDraw  = utils.newDraw
    sameTeam = playersMod.sameTeam
end

local function get(player)
    if store[player] then return store[player] end
    local e = {
        outline = newDraw("Square",{Thickness=2,Color=C.black, Filled=false,Visible=false}),
        box     = newDraw("Square",{Thickness=1,Color=C.accent,Filled=false,Visible=false}),
        name    = newDraw("Text",  {Size=13,Color=C.text,   Center=true,Outline=true,Visible=false,Text=player.Name}),
        dist    = newDraw("Text",  {Size=11,Color=C.textDim,Center=true,Outline=true,Visible=false,Text=""}),
        health  = newDraw("Text",  {Size=11,Color=C.green,  Center=true,Outline=true,Visible=false,Text=""}),
    }
    store[player] = e
    return e
end

local function hide(e)
    for _,obj in pairs(e) do if obj then pcall(function() obj.Visible=false end) end end
end

function ESP.make(player)
    if player == LocalPlayer then return end
    if store[player] then return end
    get(player)
end

function ESP.remove(player)
    local e = store[player]
    if not e then return end
    for _,obj in pairs(e) do if obj then pcall(function() obj:Remove() end) end end
    store[player] = nil
end

function ESP.update(camera, myPos)
    for player, e in pairs(store) do
        if not CFG.ESPEnabled then hide(e) continue end
        if CFG.ESPTeamCheck and sameTeam(player) then hide(e) continue end

        local char = player.Character
        if not char then hide(e) continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health<=0 then hide(e) continue end

        local dist = myPos and (root.Position-myPos).Magnitude or 0
        if dist>2000 then hide(e) continue end

        local head    = char:FindFirstChild("Head")
        local headPos = head and (head.Position+Vector3.new(0,0.6,0))
                               or (root.Position+Vector3.new(0,2.5,0))
        local feetPos = root.Position-Vector3.new(0,3,0)

        local tv,on = camera:WorldToViewportPoint(headPos)
        local bv    = camera:WorldToViewportPoint(feetPos)
        if not on or tv.Z<0 then hide(e) continue end

        local bh=math.abs(bv.Y-tv.Y) local bw=bh*0.5
        local bx=tv.X-bw/2          local by=tv.Y

        if e.outline then e.outline.Size=Vector2.new(bw+2,bh+2) e.outline.Position=Vector2.new(bx-1,by-1) e.outline.Visible=CFG.ShowBoxes end
        if e.box     then e.box.Size=Vector2.new(bw,bh) e.box.Position=Vector2.new(bx,by) e.box.Visible=CFG.ShowBoxes end
        if e.name    then e.name.Text=player.Name e.name.Position=Vector2.new(tv.X,by-15) e.name.Visible=CFG.ShowNames end
        if e.dist    then e.dist.Text=string.format("%.0fm",dist*0.28) e.dist.Position=Vector2.new(tv.X,by+bh+2) e.dist.Visible=CFG.ShowDistance end
        if e.health  then e.health.Text=string.format("♥ %d",math.floor(hum.Health)) e.health.Position=Vector2.new(bx-4,by+bh/2-5) e.health.Visible=CFG.ShowHealth end
    end
end

return ESP
