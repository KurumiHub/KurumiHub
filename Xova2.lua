--[[
local generateUUID = function()
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format('%x', v)
	end)
end]]
local getreload = function()
    local descendants = game:GetService("CoreGui"):GetDescendants()
    for index, value in pairs(descendants) do
        if value:IsA("ScreenGui") then
            if value:GetAttribute("enabled") or value:GetAttribute("protected") then
                value:Destroy()
            end
        end
    end
end

local getrandomparent = function(args)
    getreload()
    local descendants = game:GetService("CoreGui"):GetDescendants()
    local num_descendants = #descendants
    local random_index = math.random(1, num_descendants)
    args.Parent = descendants[random_index]
    args:SetAttribute("enabled", true)
end

local tween = function(object, waits, Style, ...)
    game:GetService("TweenService"):Create(object, TweenInfo.new(waits, Style), ...):Play()
end

pcall(
    function()
        local check_dupe_acrylic = function()
            if game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons") then
                game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons"):Destroy()
            end
        end
        check_dupe_acrylic()
    end
)

local Acrylic = function(v)
    local Camera = game:GetService("Workspace").CurrentCamera
    local Root = Instance.new("Folder", Camera)
    Root.Name = "Addons"
    local binds = {}

    local Token = math.random(1, 99999999)

    local DepthOfField = Instance.new("DepthOfFieldEffect", game:GetService("Lighting"))
    DepthOfField.FarIntensity = 0
    DepthOfField.FocusDistance = 51.6
    DepthOfField.InFocusRadius = 50
    DepthOfField.NearIntensity = 1
    DepthOfField.Name = "Addons_" .. Token

    local Frame = Instance.new("Frame")
    Frame.Parent = v
    Frame.Size = UDim2.new(0.95, 0, 0.95, 0)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundTransparency = 1

    local Generate_UID
    do
        local ID = 0
        function Generate_UID()
            ID = ID + 1
            return "gen::" .. tostring(ID)
        end
    end

    do
        local isnot_nan = function(v)
            return v == v
        end
        local continue = isnot_nan(Camera:ScreenPointToRay(0, 0).Origin.x)
        while not continue do
            game:GetService("RunService").PreSimulation:wait()
            continue = isnot_nan(Camera:ScreenPointToRay(0, 0).Origin.x)
        end
    end

    local DrawQuad
    do
        local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
        local sz = 0.2

        local DrawTriangle = function(v1, v2, v3, p0, p1)
            local s1 = (v1 - v2).magnitude
            local s2 = (v2 - v3).magnitude
            local s3 = (v3 - v1).magnitude
            local smax = max(s1, s2, s3)
            local A, B, C
            if s1 == smax then
                A, B, C = v1, v2, v3
            elseif s2 == smax then
                A, B, C = v2, v3, v1
            elseif s3 == smax then
                A, B, C = v3, v1, v2
            end

            local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude
            local perp = sqrt((C - A).magnitude ^ 2 - para * para)
            local dif_para = (A - B).magnitude - para

            local st = CFrame.new(B, A)
            local za = CFrame.Angles(pi / 2, 0, 0)

            local cf0 = st

            local Top_Look = (cf0 * za).lookVector
            local Mid_Point = A + CFrame.new(A, B).lookVector * para
            local Needed_Look = CFrame.new(Mid_Point, C).lookVector
            local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z

            local ac = CFrame.Angles(0, 0, acos(dot))

            cf0 = cf0 * ac
            if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot))
            end
            cf0 = cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2))

            local cf1 = st * ac * CFrame.Angles(0, pi, 0)
            if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
            end
            cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2)

            if not p0 then
                p0 = Instance.new("Part")
                p0.FormFactor = "Custom"
                p0.TopSurface = 0
                p0.BottomSurface = 0
                p0.Anchored = true
                p0.CanCollide = false
                p0.CastShadow = false
                p0.Material = "Glass"
                p0.Size = Vector3.new(sz, sz, sz)
                local mesh = Instance.new("SpecialMesh", p0)
                mesh.MeshType = 2
                mesh.Name = "WedgeMesh"
            end
            p0.WedgeMesh.Scale = Vector3.new(0, perp / sz, para / sz)
            p0.CFrame = cf0

            if not p1 then
                p1 = p0:clone()
            end
            p1.WedgeMesh.Scale = Vector3.new(0, perp / sz, dif_para / sz)
            p1.CFrame = cf1

            return p0, p1
        end

        function DrawQuad(v1, v2, v3, v4, parts)
            parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
            parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
        end
    end

    if binds[Frame] then
        return binds[Frame].parts
    end

    local uid = Generate_UID()
    local parts = {}
    local f = Instance.new("Folder", Root)
    f.Name = Frame.Name

    local parents = {}
    do
        local function add(child)
            if child:IsA "GuiObject" then
                parents[#parents + 1] = child
                add(child.Parent)
            end
        end
        add(Frame)
    end

    local function UpdateOrientation(fetchProps)
        pcall(
            function()
                local properties = {
                    Transparency = 0.98,
                    BrickColor = BrickColor.new("Institutional white")
                }
                local zIndex = 1 - 0.05 * Frame.ZIndex

                local tl, br = Frame.AbsolutePosition, Frame.AbsolutePosition + Frame.AbsoluteSize
                local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
                do
                    local rot = 0
                    for _, v in ipairs(parents) do
                        rot = rot + v.Rotation
                    end
                    if rot ~= 0 and rot % 180 ~= 0 then
                        local mid = tl:lerp(br, 0.5)
                        local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
                        local vec = tl
                        tl =
                            Vector2.new(
                            c * (tl.x - mid.x) - s * (tl.y - mid.y),
                            s * (tl.x - mid.x) + c * (tl.y - mid.y)
                        ) + mid
                        tr =
                            Vector2.new(
                            c * (tr.x - mid.x) - s * (tr.y - mid.y),
                            s * (tr.x - mid.x) + c * (tr.y - mid.y)
                        ) + mid
                        bl =
                            Vector2.new(
                            c * (bl.x - mid.x) - s * (bl.y - mid.y),
                            s * (bl.x - mid.x) + c * (bl.y - mid.y)
                        ) + mid
                        br =
                            Vector2.new(
                            c * (br.x - mid.x) - s * (br.y - mid.y),
                            s * (br.x - mid.x) + c * (br.y - mid.y)
                        ) + mid
                    end
                end
                DrawQuad(
                    Camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
                    Camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
                    Camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
                    Camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
                    parts
                )
                if fetchProps then
                    for _, pt in pairs(parts) do
                        pt.Parent = f
                    end
                    for propName, propValue in pairs(properties) do
                        for _, pt in pairs(parts) do
                            pt[propName] = propValue
                        end
                    end
                end
            end
        )
    end

    UpdateOrientation(true)
    game:GetService("RunService"):BindToRenderStep(uid, 2000, UpdateOrientation)
end

local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

local check_ui = function()
    local descendants = game:GetService("CoreGui"):GetDescendants()
    for index, value in pairs(descendants) do
        if value:IsA("ScreenGui") then
            if value:GetAttribute("enabled") or value:GetAttribute("protected") then
                return value
            end
        end
    end
end

local check_acrylic = function()
    local descendants = game:GetService("Lighting"):GetDescendants()
    for index, value in pairs(descendants) do
        if value.Name:find("Addons") then
            return value
        end
    end
end

local check_acrylic2 = function(args)
    local descendants =
        game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons"):FindFirstChild("Frame"):GetDescendants(

    )
    for index, value in pairs(descendants) do
        if value:IsA("Part") then
            if args then
                value.Material = Enum.Material.ForceField
            else
                value.Material = Enum.Material.Glass
            end
        end
    end
end

pcall(
    function()
        local iconui =
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NightsTimeZ/mat/main/topbarplus.lua"))()

        local uidata
        if _G.ThisUiToMid then
            uidata = iconui.new():setLabel("Bind HUD"):setMid():bindToggleKey(Enum.KeyCode.Delete)
        else
            uidata = iconui.new():setLabel("Bind HUD"):setRight():bindToggleKey(Enum.KeyCode.Delete)
        end
        uidata.deselected:Connect(
            function()
                check_ui().Enabled = true
                check_acrylic().Enabled = true
                check_acrylic2(false)
            end
        )
        uidata.selected:Connect(
            function()
                check_ui().Enabled = false
                check_acrylic().Enabled = false
                check_acrylic2(true)
            end
        )
    end
)

local check_device = function()
    if game:GetService("UserInputService").TouchEnabled then
        return false
    elseif game:GetService("UserInputService").KeyboardEnabled then
        return true
    end
end

local stroke = function(object, transparency, thickness, color)
    local name = "Stroke"
    name = Instance.new("UIStroke", object)
    name.Thickness = thickness
    name.LineJoinMode = Enum.LineJoinMode.Round
    name.Color = color
    name.Transparency = transparency
end

local xova_library = {
    ["first_exec"] = false,
    ["layout"] = -1,
    ["bind"] = Enum.KeyCode.Delete
}

local function tablefound(ta, object)
    for i, v in pairs(ta) do
        if v == object then
            return true
        end
    end
    return false
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Tweeninfo = TweenInfo.new

local ActualTypes = {
    Shadow = "ImageLabel",
    Circle = "ImageLabel",
    Circle2 = "ImageLabel",
    Circle3 = "ImageLabel"
}

local Properties = {
    Shadow = {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=5554236805",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(-15, -15)
    },
    Circle = {
        BackgroundTransparency = 1,
--[[
local generateUUID = function()
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format('%x', v)
	end)
end]]
local getreload = function()
    local descendants = game:GetService("CoreGui"):GetDescendants()
    for index, value in pairs(descendants) do
        if value:IsA("ScreenGui") then
            if value:GetAttribute("enabled") or value:GetAttribute("protected") then
                value:Destroy()
            end
        end
    end
end

local getrandomparent = function(args)
    getreload()
    local descendants = game:GetService("CoreGui"):GetDescendants()
    local num_descendants = #descendants
    local random_index = math.random(1, num_descendants)
    args.Parent = descendants[random_index]
    args:SetAttribute("enabled", true)
end

local tween = function(object, waits, Style, ...)
    game:GetService("TweenService"):Create(object, TweenInfo.new(waits, Style), ...):Play()
end

pcall(
    function()
        local check_dupe_acrylic = function()
            if game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons") then
                game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons"):Destroy()
            end
        end
        check_dupe_acrylic()
    end
)

local Acrylic = function(v)
    local Camera = game:GetService("Workspace").CurrentCamera
    local Root = Instance.new("Folder", Camera)
    Root.Name = "Addons"
    local binds = {}

    local Token = math.random(1, 99999999)

    local DepthOfField = Instance.new("DepthOfFieldEffect", game:GetService("Lighting"))
    DepthOfField.FarIntensity = 0
    DepthOfField.FocusDistance = 51.6
    DepthOfField.InFocusRadius = 50
    DepthOfField.NearIntensity = 1
    DepthOfField.Name = "Addons_" .. Token

    local Frame = Instance.new("Frame")
    Frame.Parent = v
    Frame.Size = UDim2.new(0.95, 0, 0.95, 0)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundTransparency = 1

    local Generate_UID
    do
        local ID = 0
        function Generate_UID()
            ID = ID + 1
            return "gen::" .. tostring(ID)
        end
    end

    do
        local isnot_nan = function(v)
            return v == v
        end
        local continue = isnot_nan(Camera:ScreenPointToRay(0, 0).Origin.x)
        while not continue do
            game:GetService("RunService").PreSimulation:wait()
            continue = isnot_nan(Camera:ScreenPointToRay(0, 0).Origin.x)
        end
    end

    local DrawQuad
    do
        local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
        local sz = 0.2

        local DrawTriangle = function(v1, v2, v3, p0, p1)
            local s1 = (v1 - v2).magnitude
            local s2 = (v2 - v3).magnitude
            local s3 = (v3 - v1).magnitude
            local smax = max(s1, s2, s3)
            local A, B, C
            if s1 == smax then
                A, B, C = v1, v2, v3
            elseif s2 == smax then
                A, B, C = v2, v3, v1
            elseif s3 == smax then
                A, B, C = v3, v1, v2
            end

            local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude
            local perp = sqrt((C - A).magnitude ^ 2 - para * para)
            local dif_para = (A - B).magnitude - para

            local st = CFrame.new(B, A)
            local za = CFrame.Angles(pi / 2, 0, 0)

            local cf0 = st

            local Top_Look = (cf0 * za).lookVector
            local Mid_Point = A + CFrame.new(A, B).lookVector * para
            local Needed_Look = CFrame.new(Mid_Point, C).lookVector
            local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z

            local ac = CFrame.Angles(0, 0, acos(dot))

            cf0 = cf0 * ac
            if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot))
            end
            cf0 = cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2))

            local cf1 = st * ac * CFrame.Angles(0, pi, 0)
            if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
                cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
            end
            cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2)

            if not p0 then
                p0 = Instance.new("Part")
                p0.FormFactor = "Custom"
                p0.TopSurface = 0
                p0.BottomSurface = 0
                p0.Anchored = true
                p0.CanCollide = false
                p0.CastShadow = false
                p0.Material = "Glass"
                p0.Size = Vector3.new(sz, sz, sz)
                local mesh = Instance.new("SpecialMesh", p0)
                mesh.MeshType = 2
                mesh.Name = "WedgeMesh"
            end
            p0.WedgeMesh.Scale = Vector3.new(0, perp / sz, para / sz)
            p0.CFrame = cf0

            if not p1 then
                p1 = p0:clone()
            end
            p1.WedgeMesh.Scale = Vector3.new(0, perp / sz, dif_para / sz)
            p1.CFrame = cf1

            return p0, p1
        end

        function DrawQuad(v1, v2, v3, v4, parts)
            parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
            parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
        end
    end

    if binds[Frame] then
        return binds[Frame].parts
    end

    local uid = Generate_UID()
    local parts = {}
    local f = Instance.new("Folder", Root)
    f.Name = Frame.Name

    local parents = {}
    do
        local function add(child)
            if child:IsA "GuiObject" then
                parents[#parents + 1] = child
                add(child.Parent)
            end
        end
        add(Frame)
    end

    local function UpdateOrientation(fetchProps)
        pcall(
            function()
                local properties = {
                    Transparency = 0.98,
                    BrickColor = BrickColor.new("Institutional white")
                }
                local zIndex = 1 - 0.05 * Frame.ZIndex

                local tl, br = Frame.AbsolutePosition, Frame.AbsolutePosition + Frame.AbsoluteSize
                local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
                do
                    local rot = 0
                    for _, v in ipairs(parents) do
                        rot = rot + v.Rotation
                    end
                    if rot ~= 0 and rot % 180 ~= 0 then
                        local mid = tl:lerp(br, 0.5)
                        local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
                        local vec = tl
                        tl =
                            Vector2.new(
                            c * (tl.x - mid.x) - s * (tl.y - mid.y),
                            s * (tl.x - mid.x) + c * (tl.y - mid.y)
                        ) + mid
                        tr =
                            Vector2.new(
                            c * (tr.x - mid.x) - s * (tr.y - mid.y),
                            s * (tr.x - mid.x) + c * (tr.y - mid.y)
                        ) + mid
                        bl =
                            Vector2.new(
                            c * (bl.x - mid.x) - s * (bl.y - mid.y),
                            s * (bl.x - mid.x) + c * (bl.y - mid.y)
                        ) + mid
                        br =
                            Vector2.new(
                            c * (br.x - mid.x) - s * (br.y - mid.y),
                            s * (br.x - mid.x) + c * (br.y - mid.y)
                        ) + mid
                    end
                end
                DrawQuad(
                    Camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
                    Camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
                    Camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
                    Camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
                    parts
                )
                if fetchProps then
                    for _, pt in pairs(parts) do
                        pt.Parent = f
                    end
                    for propName, propValue in pairs(properties) do
                        for _, pt in pairs(parts) do
                            pt[propName] = propValue
                        end
                    end
                end
            end
        )
    end

    UpdateOrientation(true)
    game:GetService("RunService"):BindToRenderStep(uid, 2000, UpdateOrientation)
end

local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

local check_ui = function()
    local descendants = game:GetService("CoreGui"):GetDescendants()
    for index, value in pairs(descendants) do
        if value:IsA("ScreenGui") then
            if value:GetAttribute("enabled") or value:GetAttribute("protected") then
                return value
            end
        end
    end
end

local check_acrylic = function()
    local descendants = game:GetService("Lighting"):GetDescendants()
    for index, value in pairs(descendants) do
        if value.Name:find("Addons") then
            return value
        end
    end
end

local check_acrylic2 = function(args)
    local descendants =
        game:GetService("Workspace"):FindFirstChild("Camera"):FindFirstChild("Addons"):FindFirstChild("Frame"):GetDescendants(

    )
    for index, value in pairs(descendants) do
        if value:IsA("Part") then
            if args then
                value.Material = Enum.Material.ForceField
            else
                value.Material = Enum.Material.Glass
            end
        end
    end
end

pcall(
    function()
        local iconui =
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NightsTimeZ/mat/main/topbarplus.lua"))()

        local uidata
        if _G.ThisUiToMid then
            uidata = iconui.new():setLabel("Bind HUD"):setMid():bindToggleKey(Enum.KeyCode.Delete)
        else
            uidata = iconui.new():setLabel("Bind HUD"):setRight():bindToggleKey(Enum.KeyCode.Delete)
        end
        uidata.deselected:Connect(
            function()
                check_ui().Enabled = true
                check_acrylic().Enabled = true
                check_acrylic2(false)
            end
        )
        uidata.selected:Connect(
            function()
                check_ui().Enabled = false
                check_acrylic().Enabled = false
                check_acrylic2(true)
            end
        )
    end
)

local check_device = function()
    if game:GetService("UserInputService").TouchEnabled then
        return false
    elseif game:GetService("UserInputService").KeyboardEnabled then
        return true
    end
end

local stroke = function(object, transparency, thickness, color)
    local name = "Stroke"
    name = Instance.new("UIStroke", object)
    name.Thickness = thickness
    name.LineJoinMode = Enum.LineJoinMode.Round
    name.Color = color
    name.Transparency = transparency
end

local xova_library = {
    ["first_exec"] = false,
    ["layout"] = -1,
    ["bind"] = Enum.KeyCode.Delete
}

local function tablefound(ta, object)
    for i, v in pairs(ta) do
        if v == object then
            return true
        end
    end
    return false
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Tweeninfo = TweenInfo.new

local ActualTypes = {
    Shadow = "ImageLabel",
    Circle = "ImageLabel",
    Circle2 = "ImageLabel",
    Circle3 = "ImageLabel"
}

local Properties = {
    Shadow = {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=5554236805",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(-15, -15)
    },
    Circle = {
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=5554831670"
    },
    Circle2 = {
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=14970076293"
    },
    Circle3 = {
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=6082206725"
    }
}

local Types = {
    "Shadow",
    "Circle",
    "Circle3",
    "Circle3"
}

local FindType = function(String)
    for _, Type in next, Types do
        if Type:sub(1, #String):lower() == String:lower() then
            return Type
        end
    end
    return false
end

local Objects = {}

function Objects.new(Type)
    local TargetType = FindType(Type)
    if TargetType then
        local NewImage = Instance.new(ActualTypes[TargetType])
        if Properties[TargetType] then
            for Property, Value in next, Properties[TargetType] do
                NewImage[Property] = Value
            end
        end
        return NewImage
    else
        return Instance.new(Type)
    end
end

local GetXY = function(GuiObject)
    local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
    local Px, Py =
        math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max),
        math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
    return Px / Max, Py / May
end

local CircleAnim = function(Type, GuiObject, EndColour, StartColour)
    local PX, PY = GetXY(GuiObject)
    local Circle = Objects.new(Type)
    Circle.Size = UDim2.fromScale(0, 0)
    Circle.Position = UDim2.fromScale(PX, PY)
    Circle.ImageColor3 = StartColour or GuiObject.ImageColor3
    Circle.ZIndex = 200
    Circle.Parent = GuiObject
    local Size = GuiObject.AbsoluteSize.X
    game:GetService("TweenService"):Create(
        Circle,
        TweenInfo.new(0.5),
        {
            Position = UDim2.fromScale(PX, PY) - UDim2.fromOffset(Size / 2, Size / 2),
            ImageTransparency = 1,
            ImageColor3 = EndColour,
            Size = UDim2.fromOffset(Size, Size)
        }
    ):Play()
    spawn(
        function()
            wait(0.5)
            Circle:Destroy()
        end
    )
end￼Enter        Image = "http://www.roblox.com/asset/?id=5554831670"
    },
    Circle2 = {
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=14970076293"
    },
    Circle3 = {
        BackgroundTransparency = 1,
        Image = "http://www.roblox.com/asset/?id=6082206725"
    }
}

local Types = {
    "Shadow",
    "Circle",
    "Circle3",
    "Circle3"
}

local FindType = function(String)
    for _, Type in next, Types do
        if Type:sub(1, #String):lower() == String:lower() then
            return Type
        end
    end
    return false
ocal Objects = {}

function Objects.new(Type)
    local TargetType = FindType(Type)
    if TargetType then
        local NewImage = Instance.new(ActualTypes[TargetType])
        if Properties[TargetType] then
            for Property, Value in next, Properties[TargetType] do
                NewImage[Property] = Value
            end
        end
        return NewImage
    else
        return Instance.new(Type)
    end
end

local GetXY = function(GuiObject)
    local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
    local Px, Py =
        math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max),
        math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
    return Px / Max, Py / May
end
