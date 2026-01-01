-- OVERDOORS HARD MODE + CARTOON SHADER (COMBINED)
-- Hardcore + Entities + Candle + Cartoon shader (low-lag dark variant)
-- Giữ Hardcore caption (trừ "Impossible"), Guiding Light Candle, Speed=20
-- Bằng: chu be te liet + fix

if getgenv().OVERDOORS_COMBINED_LOADED then return end
getgenv().OVERDOORS_COMBINED_LOADED = true

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- Safe http/load helpers
local function safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 10 then return res end
    return nil
end

local function safeLoad(url)
    local src = safeHttpGet(url)
    if not src then return end
    pcall(function() loadstring(src)() end)
end

-- ===========================
-- Remove existing post effects to reduce lag (and atmospheres)
-- ===========================
pcall(function()
    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            v:Destroy()
        end
    end
end)

-- ===========================
-- Load Hardcore V4 (attempt)
-- ===========================
pcall(function()
    safeLoad("https://raw.githubusercontent.com/localplayerr/Doors-stuff/refs/heads/main/Hardcore%20v4%20recreate/main%20code")
end)

-- ===========================
-- Ambience sound (cave)
-- ===========================
pcall(function()
    if not Workspace:FindFirstChild("OVERDOORS_AMB") then
        local amb = Instance.new("Sound")
        amb.Name = "OVERDOORS_AMB"
        amb.SoundId = "rbxassetid://8734471313"
        amb.Volume = 3
        amb.Looped = true
        amb.Parent = Workspace
        pcall(function() amb:Play() end)
    end
end)

-- ===========================
-- Lighting: dark + cartoon-ish color correction + light bloom (tuned for dark mood)
-- ===========================
pcall(function()
    -- Dark environment baseline (hardcore mood)
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.FogColor = Color3.new(0, 0, 0)
    Lighting.FogStart = 25
    Lighting.FogEnd = 55
    Lighting.Brightness = 0.08        -- keep scene dark
    Lighting.GlobalShadows = true
    Lighting.ShadowSoftness = 0.4
    Lighting.ExposureCompensation = -0.15  -- slightly darker

    -- Set night time for ambience
    pcall(function() Lighting.ClockTime = 2 end)

    -- Cartoon-style Color Correction (subtle, preserves darkness)
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "OVERDOORS_CC"
    cc.Contrast = 0.28      -- subtle
    cc.Saturation = 0.25    -- slightly desaturated so it's moody cartoon
    cc.Brightness = 0.02    -- tiny bump, but overall lighting stays dark
    cc.Parent = Lighting

    -- Bloom (light, to soften highlights)
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "OVERDOORS_BLOOM"
    bloom.Intensity = 0.45
    bloom.Size = 24
    bloom.Threshold = 1.1
    bloom.Parent = Lighting
end)

-- ===========================
-- Keep player speed stable at 20
-- ===========================
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if LP and LP.Character then
                local h = LP.Character:FindFirstChildOfClass("Humanoid")
                if h then
                    h.WalkSpeed = 20
                    -- optional: keep JumpPower safe
                    if h.JumpPower and type(h.JumpPower) == "number" then
                        h.JumpPower = 32
                    end
                end
            end
        end)
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    pcall(function()
        local hum = char:WaitForChild("Humanoid",3)
        if hum then hum.WalkSpeed = 20 end
    end)
end)

-- ===========================
-- Screech/Hide/Spider fix (no UI break)
-- ===========================
pcall(function()
    local gui = LP:WaitForChild("PlayerGui", 5)
    if gui and gui:FindFirstChild("MainUI") then
        local ok, G = pcall(function()
            return gui.MainUI.Initiator.Main_Game.RemoteListener.Modules
        end)
        if ok and G then
            pcall(function()
                if G.Screech and G.Screech.Caught then
                    G.Screech.Caught.SoundId = "rbxassetid://7492033495"
                    G.Screech.Caught.PlaybackSpeed = 1.6
                end
                if G.Screech and G.Screech.Attack then
                    G.Screech.Attack.SoundId = "rbxassetid://8080941676"
                end
                if G.HideMonster and G.HideMonster.Scare then
                    G.HideMonster.Scare.SoundId = "rbxassetid://9126213741"
                end
                if G.SpiderJumpscare and G.SpiderJumpscare.Scare then
                    G.SpiderJumpscare.Scare.SoundId = "rbxassetid://8080941676"
                end
            end)
        end
    end
end)

-- ===========================
-- Caption filter: block only "impossible" texts; keep other captions (like Hardcore)
-- ===========================
task.spawn(function()
    local gui = LP:WaitForChild("PlayerGui", 10)
    if not gui then return end
    local function onDescAdded(obj)
        pcall(function()
            if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
            local txt = tostring(obj.Text or "")
            if string.find(string.lower(txt), "impossible") then
                obj.Visible = false
            end
        end)
    end
    for _,v in pairs(gui:GetDescendants()) do
        onDescAdded(v)
    end
    gui.DescendantAdded:Connect(onDescAdded)
end)

-- ===========================
-- Entity spawn helper (safe)
-- ===========================
local function spawnLoop(delayTime, url, waitRoom)
    task.spawn(function()
        while true do
            task.wait(delayTime)
            if waitRoom and RS:FindFirstChild("GameData") and RS.GameData:FindFirstChild("LatestRoom") then
                RS.GameData.LatestRoom.Changed:Wait()
            end
            pcall(function() safeLoad(url) end)
        end
    end)
end

-- ===========================
-- Entities (same schedule as before)
-- ===========================
spawnLoop(90,  "https://raw.githubusercontent.com/Junbbinopro/Depth-entity/refs/heads/main/Depth", true)
spawnLoop(150, "https://raw.githubusercontent.com/Junbbinopro/Guardian-entity/refs/heads/main/Guardian", true)
spawnLoop(190, "https://raw.githubusercontent.com/Junbbinopro/Wh1t3/refs/heads/main/Entity", true)
spawnLoop(215, "https://raw.githubusercontent.com/trungdepth-dot/Entity-greance/refs/heads/main/Greance-20", true)
spawnLoop(250, "https://raw.githubusercontent.com/trungdepth-dot/Entity-surge/refs/heads/main/Surge-20", true)
spawnLoop(280, "https://raw.githubusercontent.com/trungdepth-dot/Him-entity-doors/refs/heads/main/Him", true)
spawnLoop(325, "https://pastefy.app/ofutwkjb/raw", true)
spawnLoop(35,  "https://raw.githubusercontent.com/vct0721/Doors-Stuff/refs/heads/main/Entities/Shocker", false)
spawnLoop(350, "https://github.com/PABMAXICHAC/doors-monsters-scripts/raw/main/blinkcrux", true)
spawnLoop(550, "https://raw.githubusercontent.com/trungdepth-dot/Entity-greed/refs/heads/main/Greed-update", true)
spawnLoop(320, "https://raw.githubusercontent.com/Junbbinopro/Black-smile/refs/heads/main/Black", true)
spawnLoop(600, "https://raw.githubusercontent.com/Junbbinopro/Munci-entity/refs/heads/main/Munci-20", true)
spawnLoop(440, "https://raw.githubusercontent.com/Junbbinopro/Blue-face/refs/heads/main/Entity", true)
spawnLoop(620, "https://raw.githubusercontent.com/Junbbinopro/Hungerd/refs/heads/main/Entity", true)
spawnLoop(210, "https://raw.githubusercontent.com/Junbbinopro/200-entity/refs/heads/main/Entity", true)
spawnLoop(290, "https://raw.githubusercontent.com/trungdepth-dot/Entity-bluyer/refs/heads/main/Entity-20", true)
spawnLoop(230, "https://raw.githubusercontent.com/Junbbinopro/Trauma-entity/refs/heads/main/Trauma", true)

-- ===========================
-- Sprint + Guiding Light Candle (safe load)
-- ===========================
safeLoad("https://raw.githubusercontent.com/Junbbinopro/Sprint-stamina-v2/refs/heads/main/Sprint")
safeLoad("https://raw.githubusercontent.com/Junbbinopro/Guiding-light-candle/refs/heads/main/Candle")

-- ===========================
-- Final log
-- ===========================
warn("[OVERDOORS COMBINED] Loaded. Hardcore caption retained (except 'Impossible'). Candle OK. Speed=20. Dark cartoon shader applied.")
