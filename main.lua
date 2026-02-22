--// Config Loader //--
local config = getgenv().config or getgenv().Config

local targetId    = config.victim
local helperName  = config.helper
local level       = config.level
local streak      = config.streak
local elo         = config.elo
local keys        = config.keys
local premium     = config.premium
local verified    = config.verified
local unlockAll   = config.unlockall
local owner       = config.owner
local platform    = tostring(config.platform):upper()



--// Optional Notification //--
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🍌 BANANALYZE",
    Text = "Made by BANANALYZE",
    Duration = 6
})

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local activePlayer =
    helperName ~= "" and Players:WaitForChild(helperName)
    or Players.LocalPlayer

--// Basic Join Check //--
if joinTag ~= "MADE-BY-BANANALYZE" then
    Players.LocalPlayer:Kick("Error loading config.owner : Did you perhaps remove owner = \"MADE-BY-BANANALYZE\"?")
    return
end

--// Fetch Target User Data //--
local rawData = game:HttpGet(
    "https://users.roblox.com/v1/users/" .. tostring(targetId),
    true
)

local userData = game:GetService("HttpService"):JSONDecode(rawData)

--// Apply Identity //--
activePlayer.Name = userData.name
activePlayer.UserId = userData.id
activePlayer.CharacterAppearanceId = userData.id
activePlayer.DisplayName = userData.displayName

repeat task.wait() until activePlayer.Character
activePlayer.Character:WaitForChild("Humanoid")

activePlayer.Character.Name = userData.name
activePlayer.Character.Humanoid.DisplayName = userData.displayName

local spoofed = Players:WaitForChild(userData.name)

spoofed:SetAttribute("Level", tonumber(level))
spoofed:SetAttribute("StatisticDuelsWinStreak", tonumber(streak))

spoofed:WaitForChild("leaderstats").Level.Value = tonumber(level)
spoofed.leaderstats:FindFirstChild("Win Streak").Value = tonumber(streak)

if tonumber(elo) > 0 then
    spoofed:SetAttribute("DisplayELO", tonumber(elo))
end

--// Character Sync //--
local function ApplyAppearance()
    local plr = Players:FindFirstChild(userData.name)
    if not plr or not plr.Character then return end

    local appearance = Players:GetCharacterAppearanceAsync(userData.id)

    for _, v in pairs(plr.Character:GetChildren()) do
        if v:IsA("Accessory")
        or v:IsA("Shirt")
        or v:IsA("Pants")
        or v:IsA("BodyColors") then
            v:Destroy()
        end
    end

    for _, v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v.Parent = plr.Character
        elseif v:IsA("Accessory") then
            plr.Character.Humanoid:AddAccessory(v)
        end
    end
end

ApplyAppearance()

Players:FindFirstChild(userData.name).CharacterAdded:Connect(function()
    ApplyAppearance()
end)

--// Premium / Badge Spoof //--
local spoofedPlayer = Players:FindFirstChild(userData.name) or activePlayer

local oldHook
oldHook = hookmetamethod(game, "__index", function(self, key)
    if self == spoofedPlayer then
        if key == "MembershipType" and premium then
            return Enum.MembershipType.Premium
        end
        if key == "HasVerifiedBadge" and verified then
            return true
        end
    end
    return oldHook(self, key)
end)

--// Platform Icons //--
local icons = {
    DESKTOP = "rbxassetid://17136633356",
    MOBILE  = "rbxassetid://17136633510",
    CONSOLE = "rbxassetid://17136633629",
    VR      = "rbxassetid://17136765745"
}

game:GetService("RunService").RenderStepped:Connect(function()
    local plr = Players:FindFirstChild(userData.name)
    if not plr or not plr.Character then return end

    local tag = plr.Character:FindFirstChild("HumanoidRootPart")
    if tag and tag:FindFirstChild("Nametag") then
        local controls = tag.Nametag.Frame.Player.Controls
        if controls then
            controls.Image = icons[platform]
        end
    end
end)

--// Unlock Everything //--
if unlockAll then
    task.wait(3)
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/WEFGQERQEGWGE/a/refs/heads/main/yashitcrack.lua"
    ))()
end
