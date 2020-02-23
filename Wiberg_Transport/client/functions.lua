--Functions

StartaTracker = function(TransportIdentifier)
    --Screen fade and fadeout
    DoScreenFadeOut(1200)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    Wait(1500)
    DoScreenFadeIn(1200)

    cached["MissionAlreadyStarted"] = true
    
    local TransportData = Config.Transporter[TransportIdentifier]
    local VehicleModel = TransportData['Vehicle']['Models'][math.random(#TransportData['Vehicle']['Models'])]
    cached["TransportVehicle"] = SpawnVehicle(VehicleModel, TransportData['Vehicle']['Pos'], TransportData['Vehicle']['Heading'])

    local Targets = {}
    table.insert(Targets, cached["TransportVehicle"])
    TriggerEvent('mtracker:settargets', Targets)
    TriggerEvent('mtracker:start')

    local TimerCarFind = Config.TimerCarFind
    local RTimer = true
    
    Citizen.CreateThread( function()
        while RTimer do 
            TimerCarFind = TimerCarFind - 1
            Citizen.Wait(1000)
        end
    end)

    local CarFindFail = true

    while true do
        local Ped = GetPlayerPed(-1)
        local PlyCoords = GetEntityCoords(Ped)
        
        if TimerCarFind <= 0 then
            RTimer = false
            CarFindFail = true
            break
        end

        if IsControlJustReleased(0, 57) then
            TriggerEvent('mtracker:start')
        end

        if IsPedInVehicle(Ped, cached["TransportVehicle"], false) then
            RTimer = false
            CarFindFail = false
            break
        else
            local VehicleCoords = GetEntityCoords(cached['TransportVehicle'])
            local DstCheck = GetDistanceBetweenCoords(PlyCoords, VehicleCoords, true)
            if DstCheck < 30 then
                drawTxt(0.97, 0.6, 1.0, 1.0, 0.5, "Sätt dig i fordonet", 255, 255, 255, 255)
                DrawMarker(20, VehicleCoords.x, VehicleCoords.y, VehicleCoords.z + 3, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200, true, false, 2, true, false, false, false)
            else
                drawTxt(0.8, 0.6, 1.0, 1.0, 0.5, "Ta hjälp av GPS mottagaren för att ta dig till fordonet. Du har ~r~" .. TimerCarFind .." ~s~sekunder kvar ~g~", 255, 255, 255, 255)
            end
        end
        drawTxt(1.1, 0.5, 1.0, 1.0, 0.25, "Tryck [~o~F10~s~] för att ta fram GPS mottagare", 255, 255, 255, 255)
        Citizen.Wait(0)
    end
    TriggerEvent('mtracker:stop')
    TriggerEvent('mtracker:removealltargets')

    if CarFindFail then
        if DoesEntityExist(cached["TransportVehicle"]) then
            DeleteVehicle(cached["TransportVehicle"])
        end
        SkickaNotis("~o~Tiril", "~r~Uppdraget misslyckades")
    else
        StartaTransport(TransportIdentifier)
    end

end

StartaTransport = function(TransportIdentifier)
    local TransportData = Config.Transporter[TransportIdentifier]
    cached["TransportOnGoing"] = true
   
    cached["TransportBlip"] = AddBlipForCoord(TransportData["Delivery"]["Pos"])
    SetBlipRoute(cached["TransportBlip"], true)
    SetBlipColour(cached["TransportBlip"], 46)
    SetBlipRouteColour(cached["TransportBlip"], 46)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('GPS destination!')
    EndTextCommandSetBlipName(cached["TransportBlip"])

    local TimerDeliveryTid = Config.DeliveryTid
    local RnTimer = true
    
    Citizen.CreateThread( function()
        while RnTimer do 
            TimerDeliveryTid = TimerDeliveryTid - 1
            Citizen.Wait(1000)
        end
    end)
    
    while cached["TransportOnGoing"] do
        local Ped = GetPlayerPed(-1)
        local PlyCoords = GetEntityCoords(Ped)
        local DstCheck = GetDistanceBetweenCoords(PlyCoords, TransportData['Delivery']['Pos'], true)
        local TransportVehicle = cached['TransportVehicle']
        local VehicleCoords = GetEntityCoords(TransportVehicle)
        local MarkerText = ""

        if TimerDeliveryTid <= 0 then
            TransportFailed()
        end

        if DoesEntityExist(TransportVehicle) then
            if not IsPedInVehicle(Ped, TransportVehicle, false) then
                drawTxt(0.97, 0.6, 1.0, 1.0, 0.5, "Sätt dig i bilen igen", 255, 255, 255, 255) 
                if GetDistanceBetweenCoords(PlyCoords, VehicleCoords, true) < 30 then
                    DrawMarker(20, VehicleCoords.x, VehicleCoords.y, VehicleCoords.z + 3, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200, true, false, 2, true, false, false, false)
                end
            else
                drawTxt(0.86, 0.6, 1.0, 1.0, 0.5, "Kör och leverera bilen till leverans punkten ~r~" .. TimerDeliveryTid .. " ~s~Sekunder", 255, 255, 255, 255)
            end

            if DstCheck < 6 then
                MarkerText = "~r~" .. TransportData['Delivery']['Text'] 
                if DstCheck < 1.3 then
                    MarkerText = "[~g~E~s~]" .. "~r~" .. TransportData['Delivery']['Text'] 
                    if IsControlJustReleased(0, 38) and IsPedInVehicle(Ped, cached['TransportVehicle'], false) then
                        TransportenKlart(TransportIdentifier)
                        RnTimer = false
                        break
                    end
                    ESX.Game.Utils.DrawText3D(TransportData['Delivery']['Pos'], MarkerText, 0.6)
                    DrawMarker(6, TransportData['Delivery']['Pos']-vector3(0.0,0.0,0.975), 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 155, 0, false, false, 0, false, false, false, false)
                end
                DrawMarker(20, TransportData['Delivery']["Pos"].x, TransportData['Delivery']["Pos"].y, TransportData['Delivery']["Pos"].z + 3, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0, 200, true, false, 2, true, false, false, false)
            end
        else
            TransportFailed()
        end
        Citizen.Wait(0)
    end 
end

TransportenKlart = function(TransportIdentifier)
    RemoveBlip(cached['TransportBlip'])

    local TransportData = Config.Transporter[TransportIdentifier]
    local RndItmCompensation = TransportData['Compensation'][math.random(#TransportData['Compensation'])]

    TaskLeaveVehicle(PlayerPedId(), cached["TransportVehicle"], 0)

    Wait(1200)

    DoScreenFadeOut(1200)
    Wait(2000)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    DeleteVehicle(cached["TransportVehicle"])
    cached["TransportOnGoing"] = false
    cached["MissionAlreadyStarted"] = false
    TriggerServerEvent('Wiberg_Transport:TransportBlipRemove:Server')
    DoScreenFadeIn(1200)

    TriggerServerEvent('Wiberg_Transport:GiveItem:Server',  RndItmCompensation)
end

TransportFailed = function()
    RemoveBlip(cached['TransportBlip'])

    DoScreenFadeOut(1200)
    Wait(2000)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    RnTimer = false
    DoScreenFadeIn(1200)
    SkickaNotis("~o~Tiril", "~r~Uppdraget misslyckades")
    cached["TransportOnGoing"] = false
    cached["MissionAlreadyStarted"] = false
    TriggerServerEvent('Wiberg_Transport:TransportBlipRemove:Server')
end

SpawnVehicle = function(Model, Pos, Heading)
    local RetVehicle = nil
    
    while not HasModelLoaded(GetHashKey(Model)) do
        Wait(0)
        RequestModel(GetHashKey(Model))
    end

    RetVehicle = CreateVehicle(GetHashKey(Model), Pos, Heading, true)
    SetVehicleOnGroundProperly(RetVehicle)

    return RetVehicle
end

SkickaNotis = function(Titel, Msg)
    ESX.ShowAdvancedNotification(Config.TitelServer,  Titel, Msg, 'CHAR_MP_FM_CONTACT', 1)
end

drawTxt = function(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end