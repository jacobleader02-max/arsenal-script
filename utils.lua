local Utils = {}

Utils.C = {
    bg       = Color3.fromRGB(8,   8,   8),
    panel    = Color3.fromRGB(16,  16,  16),
    card     = Color3.fromRGB(20,  20,  20),
    border   = Color3.fromRGB(120, 60,  220),
    borderDim= Color3.fromRGB(55,  30,  100),
    accent   = Color3.fromRGB(140, 70,  255),
    accentHi = Color3.fromRGB(180, 110, 255),
    text     = Color3.fromRGB(210, 210, 210),
    textDim  = Color3.fromRGB(100, 100, 100),
    green    = Color3.fromRGB(80,  255, 120),
    red      = Color3.fromRGB(255, 60,  60),
    black    = Color3.new(0,0,0),
}

function Utils.newDraw(t, props)
    local ok, obj = pcall(Drawing.new, t)
    if not ok then return nil end
    for k,v in pairs(props) do pcall(function() obj[k]=v end) end
    return obj
end

return Utils
