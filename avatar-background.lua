-- Avatar Background Script with Rayfield UI
-- Author: @jpneko03016
-- 空と地面を自分のアバターにして全員に反映

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
    SkySize = 5000,
    GroundSize = 10000
}

-- サービス
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
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
        if Settings.Enabled then
            ApplyAvatarBackground()
        end
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
            ApplyAvatarBackground()
            Rayfield:Notify({
                Title = "有効化",
                Content = "アバター背景を適用しました（全員に表示）",
                Duration = 3,
                Image = 4483362458
            })
        else
            RemoveAvatarBackground()
            Rayfield:Notify({
                Title = "無効化",
                Content = "アバター背景を削除しました",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- 空のサイズスライダー
local SkySizeSlider = MainTab:CreateSlider({
    Name = "空の背景サイズ",
    Range = {1000, 10000},
    Increment = 500,
    Suffix = "",
    CurrentValue = Settings.SkySize,
    Flag = "SkySize",
    Callback = function(Value)
        Settings.SkySize = Value
        if Settings.Enabled then
            ApplyAvatarBackground()
        end
    end
})

-- 地面のサイズスライダー
local GroundSizeSlider = MainTab:CreateSlider({
    Name = "地面の背景サイズ",
    Range = {5000, 20000},
    Increment = 1000,
    Suffix = "",
    CurrentValue = Settings.GroundSize,
    Flag = "GroundSize",
    Callback = function(Value)
        Settings.GroundSize = Value
        if Settings.Enabled then
            ApplyAvatarBackground()
        end
    end
})

-- ボタン
MainTab:CreateButton({
    Name = "今すぐ適用",
    Callback = function()
        ApplyAvatarBackground()
        Rayfield:Notify({
            Title = "適用完了",
            Content = "背景を適用しました（全員に表示）",
            Duration = 3,
            Image = 4483362458
        })
    end
})

MainTab:CreateButton({
    Name = "背景をリセット",
    Callback = function()
        RemoveAvatarBackground()
        Rayfield:Notify({
            Title = "リセット完了",
            Content = "背景を削除しました",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- 情報タブ
local InfoTab = Window:CreateTab("情報", 4483362458)

InfoTab:CreateParagraph({
    Title = "使い方",
    Content = "このスクリプトは空と地面の背景をあなたのアバターに変更します。サーバー内の全プレイヤーに表示されます。\n\n1. ユーザー名を入力\n2. サイズを調整\n3. 「背景を有効化」をオン"
})

-- アバター画像URLを取得
function GetAvatarImageUrl(username)
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if success and userId then
        return "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=420&h=420", userId
    else
        Rayfield:Notify({
            Title = "エラー",
            Content = "ユーザー名が見つかりません",
            Duration = 5,
            Image = 4483362458
        })
        return nil, nil
    end
end

-- スカイボックス背景を適用
function ApplySkyBackground(imageUrl)
    -- 既存のSkyを削除
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") and obj.Name == "AvatarSky" then
            obj:Destroy()
        end
    end
    
    -- 新しいSkyを作成
    local sky = Instance.new("Sky")
    sky.Name = "AvatarSky"
    sky.SkyboxBk = imageUrl
    sky.SkyboxDn = imageUrl
    sky.SkyboxFt = imageUrl
    sky.SkyboxLf = imageUrl
    sky.SkyboxRt = imageUrl
    sky.SkyboxUp = imageUrl
    sky.Parent = Lighting
end

-- ワークスペースに背景パーツを配置（全員に見える）
function ApplyWorkspaceBackground(imageUrl)
    -- 既存の背景パーツを削除
    local existingFolder = Workspace:FindFirstChild("AvatarBackgroundParts")
    if existingFolder then
        existingFolder:Destroy()
    end
    
    -- フォルダーを作成
    local folder = Instance.new("Folder")
    folder.Name = "AvatarBackgroundParts"
    folder.Parent = Workspace
    
    -- 6方向に巨大なパーツを配置（プレイヤーを囲む）
    local directions = {
        {name = "North", pos = Vector3.new(0, 0, -Settings.SkySize/2), size = Vector3.new(Settings.SkySize, Settings.SkySize, 1)},
        {name = "South", pos = Vector3.new(0, 0, Settings.SkySize/2), size = Vector3.new(Settings.SkySize, Settings.SkySize, 1)},
        {name = "East", pos = Vector3.new(Settings.SkySize/2, 0, 0), size = Vector3.new(1, Settings.SkySize, Settings.SkySize)},
        {name = "West", pos = Vector3.new(-Settings.SkySize/2, 0, 0), size = Vector3.new(1, Settings.SkySize, Settings.SkySize)},
        {name = "Top", pos = Vector3.new(0, Settings.SkySize/2, 0), size = Vector3.new(Settings.SkySize, 1, Settings.SkySize)},
        {name = "Bottom", pos = Vector3.new(0, -Settings.SkySize/2, 0), size = Vector3.new(Settings.GroundSize, 1, Settings.GroundSize)}
    }
    
    for _, dir in pairs(directions) do
        local part = Instance.new("Part")
        part.Name = "AvatarBG_" .. dir.name
        part.Size = dir.size
        part.Position = dir.pos
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Material = Enum.Material.SmoothPlastic
        
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Face = Enum.NormalId.Front
        surfaceGui.AlwaysOnTop = false
        surfaceGui.Parent = part
        
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Size = UDim2.new(1, 0, 1, 0)
        imageLabel.BackgroundTransparency = 1
        imageLabel.Image = imageUrl
        imageLabel.ScaleType = Enum.ScaleType.Fit
        imageLabel.Parent = surfaceGui
        
        part.Parent = folder
    end
end

-- アバター背景を適用
function ApplyAvatarBackground()
    if not Settings.Enabled then return end
    
    local imageUrl, userId = GetAvatarImageUrl(Settings.Username)
    if not imageUrl then return end
    
    -- スカイボックスを適用
    ApplySkyBackground(imageUrl)
    
    -- ワークスペースに背景パーツを配置
    ApplyWorkspaceBackground(imageUrl)
end

-- 背景を削除
function RemoveAvatarBackground()
    -- Skyを削除
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") and obj.Name == "AvatarSky" then
            obj:Destroy()
        end
    end
    
    -- ワークスペースの背景パーツを削除
    local existingFolder = Workspace:FindFirstChild("AvatarBackgroundParts")
    if existingFolder then
        existingFolder:Destroy()
    end
end

-- 初期化メッセージ
Rayfield:Notify({
    Title = "スクリプト読み込み完了",
    Content = "Avatar Background Script by @jpneko03016",
    Duration = 5,
    Image = 4483362458
})

print("Avatar Background Script loaded successfully!")
print("空と地面の背景があなたのアバターに変更されます（サーバー内全員に表示）")
