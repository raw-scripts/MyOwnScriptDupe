-- 🤖 DUPE SYSTEM - Final Fix: Dupes manatili pag TRADE, mawawala SABAY pag SOLD/DESTROYED
-- Clean Minimal UI + Green Button + Draggable + Close

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()

local dupeRecords = setmetatable({}, {__mode = "k"})  -- weak keys auto-GC

-----------------------------------------------------------------
--                  UI (same as before, clean minimal)
-----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinimalDupeUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 140)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.65
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 45)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(15, 15, 25))
}
UIGradient.Rotation = 90
UIGradient.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.Text = "🤖 DUPE SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local DupeButton = Instance.new("TextButton")
DupeButton.Size = UDim2.new(0.88, 0, 0, 60)
DupeButton.Position = UDim2.new(0.06, 0, 0, 60)
DupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
DupeButton.BorderSizePixel = 0
DupeButton.Font = Enum.Font.GothamBold
DupeButton.Text = "DUPE"
DupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DupeButton.TextSize = 24
DupeButton.AutoButtonColor = false
DupeButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 12)
ButtonCorner.Parent = DupeButton

local ButtonGlow = Instance.new("UIStroke")
ButtonGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ButtonGlow.Color = Color3.fromRGB(0, 255, 130)
ButtonGlow.Thickness = 2.5
ButtonGlow.Transparency = 0.4
ButtonGlow.Parent = DupeButton

-- Animations
local function hoverIn()
    TweenService:Create(DupeButton, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(0, 210, 110),
        Size = UDim2.new(0.90, 0, 0, 63)
    }):Play()
    TweenService:Create(ButtonGlow, TweenInfo.new(0.25), {Thickness = 3.5, Transparency = 0.2}):Play()
end

local function hoverOut()
    TweenService:Create(DupeButton, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(0, 180, 90),
        Size = UDim2.new(0.88, 0, 0, 60)
    }):Play()
    TweenService:Create(ButtonGlow, TweenInfo.new(0.25), {Thickness = 2.5, Transparency = 0.4}):Play()
end

DupeButton.MouseEnter:Connect(hoverIn)
DupeButton.MouseLeave:Connect(hoverOut)

DupeButton.MouseButton1Down:Connect(function()
    TweenService:Create(DupeButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(0, 140, 70)}):Play()
end)

DupeButton.MouseButton1Up:Connect(function()
    TweenService:Create(DupeButton, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(0, 210, 110)}):Play()
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-----------------------------------------------------------------
--                  DUPE LOGIC - TRADE SAFE (dupes survive trade)
-----------------------------------------------------------------
local function cleanupDupes(original)
    local clones = dupeRecords[original]
    if not clones then return end

    for _, clone in ipairs(clones) do
        if clone and clone.Parent then
            pcall(function() clone:Destroy() end)
        end
    end

    dupeRecords[original] = nil
    print("ORIGINAL SOLD/DESTROYED → sabay tinanggal dupes")
end

local function duplicateItem()
    local char = player.Character
    if not char then return end

    local tool = char:FindFirstChildWhichIsA("Tool") or backpack:FindFirstChildWhichIsA("Tool")
    if not tool then 
        print("Walang tool!")
        return 
    end

    local clone = tool:Clone()
    clone.Parent = backpack

    if not dupeRecords[tool] then
        dupeRecords[tool] = {}

        -- Hook SA .Destroying LANG → ito nagti-trigger pag sold/deleted, HINDI sa trade
        local conn
        conn = tool.Destroying:Connect(function()
            conn:Disconnect()
            cleanupDupes(tool)
        end)
    end

    table.insert(dupeRecords[tool], clone)
    print("Dupe success: " .. tool.Name .. " (" .. #dupeRecords[tool] .. "x)")
end

DupeButton.MouseButton1Click:Connect(duplicateItem)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
end)

print("🤖 DUPE SYSTEM • Dupes MANANATILI pag na-TRADE yung original!")
print("Mawawala lang sabay pag na-SOLD / DESTROYED yung real item")
