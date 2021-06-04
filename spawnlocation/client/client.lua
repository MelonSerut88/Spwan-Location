ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local new           = false
local k             = 270.0
local FirstSpawn    = true
local PlayerLoaded  = false
local cam
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerLoaded = true
end)

AddEventHandler('playerSpawned', function()
    Citizen.CreateThread(function()
        while not PlayerLoaded do
            DoScreenFadeIn(2000)
            Citizen.Wait(500)
        end

        if FirstSpawn then
            DoScreenFadeIn(500)
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                if skin ~= nil then
                    pos = GetEntityCoords(PlayerPedId())
                    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z + 200.0, 270.00, 0.00, 0.00, 80.00, 0, 0)
                    SetCamActive(cam, true)
                    RenderScriptCams(true, false, 1, true, true)
                    FreezeEntityPosition(PlayerPedId(), true)
                    SetEntityVisible(PlayerPedId(), false, false)
                    
                    SetNuiFocus(true, true)
                    SendNUIMessage({ display = true })
                else
                    print("first-spawn , not displaying spawner choice")
                end
            end)
            FirstSpawn = false
        end
    end)
end)

RegisterNUICallback("spawn", function(data)
    
    if data.choice == "spawn" then
        new = false
        SetNuiFocus(false)
        SendNUIMessage({ display = false })
        
        DoScreenFadeOut(500)
        Citizen.Wait(2000)

        PlaySoundFrontend(-1, "Zoom_In", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
        RenderScriptCams(false, true, 500, true, true)
        PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
        Citizen.Wait(0)
        
        SetEntityVisible(PlayerPedId(), true, 0)
        FreezeEntityPosition(PlayerPedId(), false)
        SetPlayerInvisibleLocally(PlayerPedId(), false)
        SetPlayerInvincible(PlayerPedId(), false)
        
        -- RenderScriptCams(false, false, 0, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)

        DoScreenFadeIn(500)

    elseif data.choice == "last" then  
        new = false
        speed = 0.7
        
        --print(ESX.PlayerData.coords.x)
        --print(ESX.PlayerData.coords.y)
        --print(ESX.PlayerData.coords.z)
        DoScreenFadeOut(500)
        Citizen.Wait(500)
        SetCamRot(cam, 270.0)
        SetCamActive(cam, true)
        new = true
        k = 270.0
        DoScreenFadeIn(500)
        SetEntityCoords(PlayerPedId(), ESX.PlayerData.coords.x, ESX.PlayerData.coords.y, ESX.PlayerData.coords.z, 0, 0, 0, 0)
        pos = GetEntityCoords(PlayerPedId())
        print(pos)
        SetCamCoord(cam, pos.x, pos.y, pos.z + 200.0)
        i = pos.z + 200.0
        while i > ESX.PlayerData.coords.z + 1.5 do
            Citizen.Wait(5)
            i = i - speed
            SetCamCoord(cam, pos.x, pos.y, i)
            if i <= ESX.PlayerData.coords.z + 35.0 and k < 360.0 then
                if speed - 0.0078 >= 0.05 then
                    speed = speed - 0.0078
                end

                k = k + 0.75
                SetCamRot(cam, k)
            end
            if not new then break end
        end
    else
        new = false
        speed = 0.7

        DoScreenFadeOut(500)
        Citizen.Wait(500)
        SetCamRot(cam, 270.0)
        SetCamActive(cam, true)
        new = true
        k = 270.0
        DoScreenFadeIn(500)
        SetEntityCoords(PlayerPedId(), config.coords[data.choice].x, config.coords[data.choice].y, config.coords[data.choice].z, 0, 0, 0, 0)
        pos = GetEntityCoords(PlayerPedId())
        SetCamCoord(cam, pos.x, pos.y, pos.z + 200.0)
        i = pos.z + 200.0
        while i > config.coords[data.choice].z + 1.5 do
            Citizen.Wait(5)
            i = i - speed
            SetCamCoord(cam, pos.x, pos.y, i)
            if i <= config.coords[data.choice].z + 35.0 and k < 360.0 then
                if speed - 0.0078 >= 0.05 then
                    speed = speed - 0.0078
                end

                k = k + 0.75
                SetCamRot(cam, k)
            end
            if not new then break end
        end
    end
end)

SpawnPlayer = function(Location)
    local pos = Location
    SetNuiFocus(false, false)
    SetCamActiveWithInterp(cam, cam2, 3700, true, true)
    --callback("ok")
    Citizen.Wait(0)

    PlaySoundFrontend(-1, "Zoom_In", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
    RenderScriptCams(false, true, 500, true, true)
    PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
    Citizen.Wait(0)

    SetEntityVisible(PlayerPedId(), true, 0)
    FreezeEntityPosition(PlayerPedId(), false)
    SetPlayerInvisibleLocally(PlayerPedId(), false)
    SetPlayerInvincible(PlayerPedId(), false)

end


RegisterNetEvent("spawnlocation:setNui")
AddEventHandler("spawnlocation:setNui", function()
	SetNuiFocus(true, true)

	SendNUIMessage({
		["Action"] = "OPEN_SPAWNMENU"
	})
end)