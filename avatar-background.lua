-- Avatar Background Script with Rayfield UI
-- Author: @jpneko03016
-- アバターを背景として表示し、敵にも反映

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Avatar Background Script",
    LoadingTitle = "アバター背景スクリプト",
    LoadingSubtitle = "by @jpneko03016",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "AvatarBG"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

-- 設定
local Settings = {
    Enabled = false,
    Username = "jpneko03016",
    ApplyToEnemies = true,
    BackgroundTransparency = 0.5,
    BackgroundSize = UDim2.new(2, 0, 2, 0)
}

-- プレイヤーとサービス
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- メインタブ
local MainTab = Window:CreateTab("メイン設定", 4483362458)

-- ユーザー名入力
local UsernameInput = MainTab:CreateInput({
    Name = "ユーザー名",
    PlaceholderText = "Robloxユーザー名を入力",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        Settings.Username = Text
        Rayfield:Notify({
            Title = "ユーザー名更新",
            Content = "ユーザー名: " .. Text,
            Duration = 3,
            Image = 4483362458
        })
    end
})

UsernameInput:Set(Settings.Username)

-- 有効化トグル
local EnableToggle = MainTab:CreateToggle({
    Name = "背景を有効化",
    CurrentValue = Settings.Enabled,
    Flag = "EnableBackground",
    Callback = function(Value)
        Settings.Enabled = Value
        if Value then
            ApplyBackgroundToAll()
            Rayfield:Notify({
                Title = "有効化",
                Content = "アバター背景を適用しました",
                Duration = 3,
                Image = 4483362458
            })
        else
            RemoveAllBackgrounds()
            Rayfield:Notify({
                Title = "無効化",
                Content = "アバター背景を削除しました",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- 敵に適用するトグル
local EnemyToggle = MainTab:CreateToggle({
    Name = "敵にも適用",
    CurrentValue = Settings.ApplyToEnemies,
    Flag = "ApplyToEnemies",
    Callback = function(Value)
        Settings.ApplyToEnemies = Value
    end
})

-- 透明度スライダー
local TransparencySlider = MainTab:CreateSlider({
    Name = "背景透明度",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = Settings.BackgroundTransparency,
    Flag = "BackgroundTransparency",
    Callback = function(Value)
        Settings.BackgroundTransparency = Value
        UpdateAllBackgroundTransparency()
    end
})

-- サイズスライダー
local SizeSlider = MainTab:CreateSlider({
    Name = "背景サイズ倍率",
    Range = {1, 5},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "BackgroundSize",
    Callback = function(Value)
        Settings.BackgroundSize = UDim2.new(Value, 0, Value, 0)
        UpdateAllBackgroundSizes()
    end
})

-- ボタン
MainTab:CreateButton({
    Name = "今すぐ適用",
    Callback = function()
        ApplyBackgroundToAll()
        Rayfield:Notify({
            Title = "適用完了",
            Content = "全プレイヤーに背景を適用しました",
            Duration = 3,
            Image = 4483362458
        })
    end
})

MainTab:CreateButton({
    Name = "背景をリセット",
    Callback = function()
        RemoveAllBackgrounds()
        Rayfield:Notify({
            Title = "リセット完了",
            Content = "全ての背景を削除しました",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- 背景適用関数
function ApplyBackground(player)
    if not Settings.Enabled then return end
    if not Settings.ApplyToEnemies and player ~= LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local existingBG = humanoidRootPart:FindFirstChild("AvatarBackground")
    if existingBG then
        existingBG:Destroy()
    end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "AvatarBackground"
    billboardGui.Size = Settings.BackgroundSize
    billboardGui.StudsOffset = Vector3.new(0, 0, 0)
    billboardGui.AlwaysOnTop = false
    billboardGui.Parent = humanoidRootPart
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ImageTransparency = Settings.BackgroundTransparency
    imageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Players:GetUserIdFromNameAsync(Settings.Username) .. "&w=420&h=420"
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = billboardGui
end

function ApplyBackgroundToAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            ApplyBackground(player)
        end
    end
end

function RemoveAllBackgrounds()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local bg = humanoidRootPart:FindFirstChild("AvatarBackground")
                if bg then
                    bg:Destroy()
                end
            end
        end
    end
end

function UpdateAllBackgroundTransparency()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local bg = humanoidRootPart:FindFirstChild("AvatarBackground")
                if bg then
                    local imageLabel = bg:FindFirstChildOfClass("ImageLabel")
                    if imageLabel then
                        imageLabel.ImageTransparency = Settings.BackgroundTransparency
                    end
                end
            end
        end
    end
end

function UpdateAllBackgroundSizes()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local bg = humanoidRootPart:FindFirstChild("AvatarBackground")
                if bg then
                    bg.Size = Settings.BackgroundSize
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.5)
        if Settings.Enabled then
            ApplyBackground(player)
        end
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        player.CharacterAdded:Connect(function(character)
            wait(0.5)
            if Settings.Enabled then
                ApplyBackground(player)
            end
        end)
    end
end

Rayfield:Notify({
    Title = "スクリプト読み込み完了",
    Content = "Avatar Background Script by @jpneko03016",
    Duration = 5,
    Image = 4483362458
})

print("Avatar Background Script loaded successfully!")
