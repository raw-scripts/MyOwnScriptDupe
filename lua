-- 🤖 DUPE SYSTEM - Minimal UI (Updated: Dupes manatili pag trade, mawawala lang pag destroyed/sold)
-- Hindi na mawawala dupes pag na-trade yung original
-- Para sa Roblox exploits

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()

local dupeRecords = setmetatable({}, {__mode = "k"})  -- weak keys para sa originals

-- ======================= GUI SETUP (same as before, di ko na ulitin lahat) =======================
-- ... (copy paste yung GUI code mula sa previous messages mo, yung frame, button, animations, etc.)

-- ===================== CLEANUP LOGIC (adjusted para sa trade) =====================
local function cleanupDupes(original)
    if not dupeRecords[original] then return end

    for _, clone in ipairs(dupeRecords[original]) do
        if clone and clone.Parent then
            pcall(clone.Destroy, clone)
        end
    end

    dupeRecords[original] = nil
    print("ORIGINAL DESTROYED/SOLD → sabay-sabay tinanggal dupes")
end

-- Connect sa Destroying event lang (para sa sold/deleted cases)
-- Hindi na natin icoconnect sa ChildRemoved para hindi ma-trigger sa trade/drop

-- ===================== DUPE FUNCTION (with Destroying hook) =====================
local function duplicateItem()
    local char = player.Character
    if not char then return end

    local tool = char:FindFirstChildWhichIsA("Tool") or backpack:FindFirstChildWhichIsA("Tool")
    if not tool then return end

    local clone = tool:Clone()
    clone.Parent = backpack

    if not dupeRecords[tool] then
        dupeRecords[tool] = {}
        
        -- Hook sa pag-destroy ng original (sold or game delete)
        local conn
        conn = tool.Destroying:Connect(function()
            conn:Disconnect()
            if dupeRecords[tool] then
                cleanupDupes(tool)
            end
        end)
    end

    table.insert(dupeRecords[tool], clone)

    print("Dupe: " .. tool.Name .. " (" .. #dupeRecords[tool] .. " clones)")

    -- Optional: track clone removal
    local cloneConn = clone.AncestryChanged:Connect(function()
        if not clone.Parent then
            cloneConn:Disconnect()
            -- alisin lang sa list, wag tanggalin iba
            for i, c in ipairs(dupeRecords[tool] or {}) do
                if c == clone then table.remove(dupeRecords[tool], i) break end
            end
        end
    end)
end

DupeButton.MouseButton1Click:Connect(duplicateItem)

-- ... (close button code same as before)

print("🤖 DUPE SYSTEM • Dupes mananatili kahit i-trade mo yung original")
