repeat wait() until game:IsLoaded()

task.wait(15)

local teamArgs = { [1] = "Sheriff" }
game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events"):WaitForChild("TeamChanger"):FireServer(unpack(teamArgs))

wait(1)
local spawnArgs = { [1] = "SpawnChar", [2] = "Sheriff Station" }
game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events"):WaitForChild("SpawnCharacter"):InvokeServer(unpack(spawnArgs))

wait(1)
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
local mainMenu = playerGui:WaitForChild('MainMenu')
local mainUIHolder = playerGui.MainUIHolder

mainMenu.Enabled = false
mainUIHolder.Enabled = true

workspace.Camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
workspace.Camera.CameraType = Enum.CameraType.Custom

wait(1)
game.Players.LocalPlayer.Character.Humanoid:EquipTool(game:GetService("Players").LocalPlayer.Backpack["Equip Items"])

local equipArgs = { [1] = game.Players.LocalPlayer.Character["Equip Items"] }
game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events"):WaitForChild("JobItemGiver"):FireServer(unpack(equipArgs))

wait(1)
game.Players.LocalPlayer.Character.Humanoid:EquipTool(game:GetService("Players").LocalPlayer.Backpack:WaitForChild("Baton"))

local cashEarned = 0
local cashEarnedLabel = Instance.new("TextLabel")
cashEarnedLabel.Text = "Cash Earned: $" .. cashEarned
cashEarnedLabel.Size = UDim2.new(0, 200, 0, 50)
cashEarnedLabel.Position = UDim2.new(0, 10, 0, 10)
cashEarnedLabel.BackgroundTransparency = 0.5
cashEarnedLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
cashEarnedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cashEarnedLabel.TextSize = 18
cashEarnedLabel.Parent = mainUIHolder

for i, v in pairs(workspace.Entities:GetChildren()) do
    if v.Name == "Hotwired Printer" or v.Name == "Simple Printer" then
        if v:FindFirstChild("BGPart") then
            local x = 0
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 2, v.PrimaryPart.CFrame.z)
            repeat
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 1, v.PrimaryPart.CFrame.z)
                wait(0.1)
                local destroyArgs = { [1] = "DestroyPrinter", [2] = v, [3] = game:GetService("Players").LocalPlayer.Character.Baton }
                game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events"):WaitForChild("ToolEvent"):FireServer(unpack(destroyArgs))
                x = x + 1
                cashEarned = cashEarned + 100
                cashEarnedLabel.Text = "Cash Earned: $" .. cashEarned
            until x > 20 or not v:FindFirstChild("BGPart")
        end
    end
end

local Player = game.Players.LocalPlayer
local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local Api = "https://games.roblox.com/v1/games/"

local _place, _id = game.PlaceId, game.JobId
local _servers = Api .. _place .. "/servers/Public?sortOrder=Desc&limit=100"

function ListServers(cursor)
    local Raw = game:HttpGet(_servers .. ((cursor and "&cursor=" .. cursor) or ""))
    return Http:JSONDecode(Raw)
end

local Next
repeat
    local Servers = ListServers(Next)
    for i, v in next, Servers.data do
        if v.playing < v.maxPlayers and v.id ~= _id then
            local s, r = pcall(TPS.TeleportToPlaceInstance, TPS, _place, v.id, Player)
            if s then break end
        end
    end
    Next = Servers.nextPageCursor
until not Next
