local UserInputService = game:GetService("UserInputService")

local UI        = {}
local CFG, C
local WIN_W     = 260
local FULL_H    = 360
local MINI_H    = 26
local minimized = false
local SG, Root
local tabFrames = {}
local tabs      = {}

function UI.init(cfg, utils)
    CFG = cfg
    C   = utils.C
    UI._build()
end

local function makeTabFrame(parent)
    local sf=Instance.new("ScrollingFrame")
    sf.Size=UDim2.new(1,0,1,-50) sf.Position=UDim2.new(0,0,0,50)
    sf.BackgroundTransparency=1 sf.BorderSizePixel=0
    sf.ScrollBarThickness=2 sf.ScrollBarImageColor3=C.borderDim
    sf.CanvasSize=UDim2.new(0,0,0,0) sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.ScrollingDirection=Enum.ScrollingDirection.Y
    sf.Visible=false sf.ZIndex=3 sf.Parent=parent
    local l=Instance.new("UIListLayout")
    l.Padding=UDim.new(0,0) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=sf
    return sf
end

local function switchTab(name)
    for n,f in pairs(tabFrames) do f.Visible=(n==name) end
    for n,b in pairs(tabs) do
        b.BackgroundColor3=(n==name) and C.accent or C.panel
        b.TextColor3=(n==name) and C.black or C.textDim
    end
end

function UI.mkSection(parent,text)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,20) f.BackgroundColor3=C.panel
    f.BorderSizePixel=0 f.Parent=parent
    local stripe=Instance.new("Frame")
    stripe.Size=UDim2.new(0,2,1,0) stripe.BackgroundColor3=C.accent
    stripe.BorderSizePixel=0 stripe.Parent=f
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-8,1,0) lbl.Position=UDim2.new(0,6,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=text:upper()
    lbl.TextColor3=C.accent lbl.TextSize=10 lbl.Font=Enum.Font.Code
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=f
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.borderDim line.BorderSizePixel=0 line.Parent=f
end

function UI.mkToggle(parent,text,default,callback)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,28) row.BackgroundColor3=C.bg
    row.BorderSizePixel=0 row.Parent=parent
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.borderDim line.BorderSizePixel=0 line.Parent=row
    local box=Instance.new("Frame")
    box.Size=UDim2.new(0,14,0,14) box.Position=UDim2.new(1,-22,0.5,-7)
    box.BackgroundColor3=default and C.accent or C.bg
    box.BorderSizePixel=0 box.Parent=row
    local bs=Instance.new("UIStroke") bs.Color=C.border bs.Thickness=1 bs.Parent=box
    local check=Instance.new("TextLabel")
    check.Size=UDim2.new(1,0,1,0) check.BackgroundTransparency=1
    check.Text=default and "✓" or "" check.TextColor3=C.black
    check.TextSize=11 check.Font=Enum.Font.GothamBold check.Parent=box
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-38,1,0) lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=text lbl.TextColor3=C.text
    lbl.TextSize=12 lbl.Font=Enum.Font.Code
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=row
    local state=default
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.Parent=row
    btn.MouseButton1Click:Connect(function()
        state=not state
        box.BackgroundColor3=state and C.accent or C.bg
        check.Text=state and "✓" or ""
        callback(state)
    end)
    return {setState=function(v)
        state=v box.BackgroundColor3=v and C.accent or C.bg check.Text=v and "✓" or ""
    end}
end

function UI.mkNumInput(parent,text,default,minVal,maxVal,callback)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,46) card.BackgroundColor3=C.bg
    card.BorderSizePixel=0 card.Parent=parent
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.borderDim line.BorderSizePixel=0 line.Parent=card
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,0,16) lbl.Position=UDim2.new(0,10,0,2)
    lbl.BackgroundTransparency=1 lbl.Text=text lbl.TextColor3=C.textDim
    lbl.TextSize=10 lbl.Font=Enum.Font.Code
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=card
    local BW=30 local TBW=WIN_W-BW*4-20
    local function makeBtn(xOff,label)
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0,BW,0,20) b.Position=UDim2.new(0,xOff,0,22)
        b.BackgroundColor3=C.panel b.BorderSizePixel=0
        b.Text=label b.TextColor3=C.accentHi b.TextSize=11 b.Font=Enum.Font.Code b.Parent=card
        local bs=Instance.new("UIStroke") bs.Color=C.borderDim bs.Thickness=1 bs.Parent=b
        return b
    end
    local b10m=makeBtn(10,"-10") local b5m=makeBtn(10+BW,"-5")
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(0,TBW,0,20) tb.Position=UDim2.new(0,10+BW*2,0,22)
    tb.BackgroundColor3=C.card tb.BorderSizePixel=0
    tb.Text=tostring(default) tb.TextColor3=C.text
    tb.TextSize=12 tb.Font=Enum.Font.Code
    tb.TextXAlignment=Enum.TextXAlignment.Center tb.ClearTextOnFocus=false tb.Parent=card
    local tbs=Instance.new("UIStroke") tbs.Color=C.borderDim tbs.Thickness=1 tbs.Parent=tb
    local b5p=makeBtn(10+BW*2+TBW,"+5") local b10p=makeBtn(10+BW*2+TBW+BW,"+10")
    local current=default
    local function apply(v)
        v=math.clamp(math.floor(v),minVal,maxVal)
        current=v tb.Text=tostring(v) callback(v)
    end
    tb.FocusLost:Connect(function()
        local n=tonumber(tb.Text) if n then apply(n) else tb.Text=tostring(current) end
    end)
    b10m.MouseButton1Click:Connect(function() apply(current-10) end)
    b5m.MouseButton1Click:Connect(function()  apply(current-5)  end)
    b5p.MouseButton1Click:Connect(function()  apply(current+5)  end)
    b10p.MouseButton1Click:Connect(function() apply(current+10) end)
    return {setValue=function(v) apply(v) end}
end

function UI.mkDropdown(parent,text,options,default,callback)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,42) card.BackgroundColor3=C.bg
    card.BorderSizePixel=0 card.Parent=parent
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.borderDim line.BorderSizePixel=0 line.Parent=card
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-12,0,16) lbl.Position=UDim2.new(0,10,0,3)
    lbl.BackgroundTransparency=1 lbl.Text=text lbl.TextColor3=C.textDim
    lbl.TextSize=10 lbl.Font=Enum.Font.Code
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=card
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,18) btn.Position=UDim2.new(0,10,0,20)
    btn.BackgroundColor3=C.panel btn.BorderSizePixel=0
    btn.Text="> "..default btn.TextColor3=C.accentHi
    btn.TextSize=12 btn.Font=Enum.Font.Code
    btn.TextXAlignment=Enum.TextXAlignment.Left btn.Parent=card
    local bs=Instance.new("UIStroke") bs.Color=C.borderDim bs.Thickness=1 bs.Parent=btn
    local opt=Instance.new("Frame")
    opt.Size=UDim2.new(0,220,0,#options*22+4)
    opt.BackgroundColor3=C.panel opt.BorderSizePixel=0
    opt.Visible=false opt.ZIndex=50 opt.Parent=SG
    local os=Instance.new("UIStroke") os.Color=C.border os.Thickness=1 os.Parent=opt
    local ol=Instance.new("UIListLayout") ol.Padding=UDim.new(0,0) ol.Parent=opt
    for _,o in ipairs(options) do
        local ob=Instance.new("TextButton")
        ob.Size=UDim2.new(1,0,0,22) ob.BackgroundTransparency=1
        ob.Text="  "..o ob.TextColor3=C.text ob.TextSize=12 ob.Font=Enum.Font.Code
        ob.TextXAlignment=Enum.TextXAlignment.Left ob.ZIndex=50 ob.Parent=opt
        ob.MouseEnter:Connect(function() ob.BackgroundTransparency=0 ob.BackgroundColor3=C.accent ob.TextColor3=C.black end)
        ob.MouseLeave:Connect(function() ob.BackgroundTransparency=1 ob.TextColor3=C.text end)
        ob.MouseButton1Click:Connect(function() btn.Text="> "..o opt.Visible=false callback(o) end)
    end
    local open=false
    btn.MouseButton1Click:Connect(function()
        open=not open
        if open then
            local a=btn.AbsolutePosition local s=btn.AbsoluteSize
            opt.Position=UDim2.new(0,a.X,0,a.Y+s.Y+2)
        end
        opt.Visible=open
    end)
end

function UI.mkKeybind(parent,text,default,callback)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,42) card.BackgroundColor3=C.bg
    card.BorderSizePixel=0 card.Parent=parent
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.borderDim line.BorderSizePixel=0 line.Parent=card
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-12,0,16) lbl.Position=UDim2.new(0,10,0,3)
    lbl.BackgroundTransparency=1 lbl.Text=text lbl.TextColor3=C.textDim
    lbl.TextSize=10 lbl.Font=Enum.Font.Code
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=card
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,18) btn.Position=UDim2.new(0,10,0,20)
    btn.BackgroundColor3=C.panel btn.BorderSizePixel=0
    btn.Text="["..default.."]" btn.TextColor3=C.accentHi
    btn.TextSize=12 btn.Font=Enum.Font.Code
    btn.TextXAlignment=Enum.TextXAlignment.Left btn.Parent=card
    local bs=Instance.new("UIStroke") bs.Color=C.borderDim bs.Thickness=1 bs.Parent=btn
    local listening=false local lc2=nil
    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true btn.Text="[...]" btn.TextColor3=C.red
        lc2=UserInputService.InputBegan:Connect(function(input,gpe)
            if gpe then return end
            if input.UserInputType==Enum.UserInputType.MouseButton1 then return end
            lc2:Disconnect() listening=false
            local label
            if input.UserInputType==Enum.UserInputType.MouseButton2 then label="RMB"
            elseif input.UserInputType==Enum.UserInputType.MouseButton3 then label="MMB"
            elseif input.KeyCode~=Enum.KeyCode.Unknown then
                label=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
            else label=default end
            btn.Text="["..label.."]" btn.TextColor3=C.accentHi
            callback(input,label)
        end)
    end)
end

function UI.mkButton(parent,text,callback)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,28) btn.BackgroundColor3=C.panel
    btn.BorderSizePixel=0 btn.Text=text btn.TextColor3=C.accentHi
    btn.TextSize=12 btn.Font=Enum.Font.Code
    btn.TextXAlignment=Enum.TextXAlignment.Left btn.Parent=parent
    local bs=Instance.new("UIStroke") bs.Color=C.border bs.Thickness=1 bs.Parent=btn
    local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,10) pad.Parent=btn
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.borderDim line.BorderSizePixel=0 line.Parent=btn
    btn.MouseButton1Click:Connect(callback)
end

function UI.mkTextBox(parent,placeholder)
    local frame=Instance.new("Frame")
    frame.Size=UDim2.new(1,0,0,60) frame.BackgroundColor3=C.card
    frame.BorderSizePixel=0 frame.Parent=parent
    local fs=Instance.new("UIStroke") fs.Color=C.borderDim fs.Thickness=1 fs.Parent=frame
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.borderDim line.BorderSizePixel=0 line.Parent=frame
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(1,-8,1,-8) tb.Position=UDim2.new(0,4,0,4)
    tb.BackgroundTransparency=1 tb.Text="" tb.PlaceholderText=placeholder
    tb.TextColor3=C.text tb.PlaceholderColor3=C.textDim
    tb.TextSize=11 tb.Font=Enum.Font.Code
    tb.MultiLine=true tb.TextWrapped=true
    tb.TextXAlignment=Enum.TextXAlignment.Left
    tb.TextYAlignment=Enum.TextYAlignment.Top
    tb.ClearTextOnFocus=false tb.Parent=frame
    return tb
end

function UI._build()
    SG=Instance.new("ScreenGui")
    SG.Name="AnderdingusCheats" SG.ResetOnSpawn=false
    SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    SG.IgnoreGuiInset=true SG.Parent=game:GetService("CoreGui")

    Root=Instance.new("Frame")
    Root.Size=UDim2.new(0,WIN_W,0,FULL_H) Root.Position=UDim2.new(0,40,0,40)
    Root.BackgroundColor3=C.bg Root.BorderSizePixel=0
    Root.Active=true Root.Draggable=true Root.ZIndex=2
    Root.ClipsDescendants=true Root.Parent=SG
    local rs=Instance.new("UIStroke")
    rs.Color=C.border rs.Thickness=1
    rs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border rs.Parent=Root

    local Shadow=Instance.new("Frame")
    Shadow.Size=UDim2.new(1,8,1,8) Shadow.Position=UDim2.new(0,-4,0,4)
    Shadow.BackgroundColor3=C.black Shadow.BackgroundTransparency=0.45
    Shadow.BorderSizePixel=0 Shadow.ZIndex=1 Shadow.Parent=Root

    local TBar=Instance.new("Frame")
    TBar.Size=UDim2.new(1,0,0,MINI_H) TBar.BackgroundColor3=C.panel
    TBar.BorderSizePixel=0 TBar.ZIndex=3 TBar.Parent=Root
    local TAccent=Instance.new("Frame")
    TAccent.Size=UDim2.new(0,3,1,0) TAccent.BackgroundColor3=C.accent
    TAccent.BorderSizePixel=0 TAccent.ZIndex=4 TAccent.Parent=TBar
    local TText=Instance.new("TextLabel")
    TText.Size=UDim2.new(1,-30,1,0) TText.Position=UDim2.new(0,10,0,0)
    TText.BackgroundTransparency=1 TText.Text="anderdingus cheats"
    TText.TextColor3=C.accent TText.TextSize=12 TText.Font=Enum.Font.Code
    TText.TextXAlignment=Enum.TextXAlignment.Left TText.ZIndex=4 TText.Parent=TBar
    local MinBtn=Instance.new("TextButton")
    MinBtn.Size=UDim2.new(0,26,1,0) MinBtn.Position=UDim2.new(1,-26,0,0)
    MinBtn.BackgroundColor3=C.panel MinBtn.BorderSizePixel=0
    MinBtn.Text="—" MinBtn.TextColor3=C.accentHi
    MinBtn.TextSize=12 MinBtn.Font=Enum.Font.Code MinBtn.ZIndex=5 MinBtn.Parent=TBar
    MinBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        Root.Size=UDim2.new(0,WIN_W,0,minimized and MINI_H or FULL_H)
        MinBtn.Text=minimized and "+" or "—"
    end)
    local TBorder=Instance.new("Frame")
    TBorder.Size=UDim2.new(1,0,0,1) TBorder.Position=UDim2.new(0,0,1,-1)
    TBorder.BackgroundColor3=C.border TBorder.BorderSizePixel=0 TBorder.ZIndex=4 TBorder.Parent=TBar

    local TabBar=Instance.new("Frame")
    TabBar.Size=UDim2.new(1,0,0,24) TabBar.Position=UDim2.new(0,0,0,MINI_H)
    TabBar.BackgroundColor3=C.panel TabBar.BorderSizePixel=0
    TabBar.ZIndex=3 TabBar.ClipsDescendants=true TabBar.Parent=Root
    local TabBorder=Instance.new("Frame")
    TabBorder.Size=UDim2.new(1,0,0,1) TabBorder.Position=UDim2.new(0,0,1,-1)
    TabBorder.BackgroundColor3=C.borderDim TabBorder.BorderSizePixel=0 TabBorder.ZIndex=4 TabBorder.Parent=TabBar

    local TAB_NAMES={"ESP","Aimbot","Player","Config"}
    local TAB_W=WIN_W/#TAB_NAMES

    for i,name in ipairs(TAB_NAMES) do
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(0,TAB_W,1,0) btn.Position=UDim2.new(0,(i-1)*TAB_W,0,0)
        btn.BackgroundColor3=C.panel btn.BorderSizePixel=0
        btn.Text=name btn.TextColor3=C.textDim
        btn.TextSize=11 btn.Font=Enum.Font.Code btn.ZIndex=4 btn.Parent=TabBar
        if i<#TAB_NAMES then
            local div=Instance.new("Frame")
            div.Size=UDim2.new(0,1,1,0) div.Position=UDim2.new(1,-1,0,0)
            div.BackgroundColor3=C.borderDim div.BorderSizePixel=0 div.ZIndex=5 div.Parent=btn
        end
        tabs[name]=btn
        tabFrames[name]=makeTabFrame(Root)
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end

    return tabFrames, SG
end

function UI.getTabs() return tabFrames end
function UI.getSG() return SG end

return UI
