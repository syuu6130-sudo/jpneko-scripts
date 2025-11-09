-- Avatar Background Script with Rayfield UI
-- Author: @jpneko03016
-- ゲームの背景を自分のアバターにして全員に反映

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
    BackgroundType = "Sky" -- Sky, ScreenGui, Both
}

-- サービス
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
                Content = "アバター背景を適用しました",
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

-- 背景タイプ選択
local TypeDropdown = MainTab:CreateDropdown({
    Name = "背景タイプ",
    Options = {"スカイボックス", "画面オーバーレイ", "両方"},
    CurrentOption = "両方",
    Flag = "BackgroundType",
    Callback = function(Option)
        if Option == "スカイボックス" then
            Settings.BackgroundType = "Sky"
        elseif Option == "画面オーバーレイ" then
            Settings.BackgroundType = "ScreenGui"
        else
            Settings.BackgroundType = "Both"
        end
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
            Content = "背景を適用しました",
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
    Content = "このスクリプトはゲームの背景をあなたのアバターに変更します。全てのプレイヤーに表示されます。\n\n1. ユーザー名を入力\n2. 背景タイプを選択\n3. 「背景を有効化」をオン"
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

-- 画面オーバーレイ背景を適用
function ApplyScreenBackground(imageUrl)
    -- 既存のScreenGuiを削除
    local existingGui = PlayerGui:FindFirstChild("AvatarBackgroundGui")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- 新しいScreenGuiを作成
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AvatarBackgroundGui"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = -100
    screenGui.Parent = PlayerGui
    
    -- 背景画像
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "BackgroundImage"
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = imageUrl
    imageLabel.ImageTransparency = 0.3
    imageLabel.ScaleType = Enum.ScaleType.Crop
    imageLabel.Parent = screenGui
end

-- アバター背景を適用
function ApplyAvatarBackground()
    if not Settings.Enabled then return end
    
    local imageUrl, userId = GetAvatarImageUrl(Settings.Username)
    if not imageUrl then return end
    
    -- 高解像度の画像URLを使用
    local fullImageUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
    
    if Settings.BackgroundType == "Sky" or Settings.BackgroundType == "Both" then
        ApplySkyBackground(imageUrl)
    end
    
    if Settings.BackgroundType == "ScreenGui" or Settings.BackgroundType == "Both" then
        ApplyScreenBackground(imageUrl)
    end
end

-- 背景を削除
function RemoveAvatarBackground()
    -- Skyを削除
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") and obj.Name == "AvatarSky" then
            obj:Destroy()
        end
    end
    
    -- ScreenGuiを削除
    local existingGui = PlayerGui:FindFirstChild("AvatarBackgroundGui")
    if existingGui then
        existingGui:Destroy()
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
print("ゲームの背景があなたのアバターに変更されます（全員に表示）")
