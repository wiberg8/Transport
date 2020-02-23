ESX = nil

Citizen.CreateThread(function()
	while not ESX do

		TriggerEvent("esx:getSharedObject", function(library) 
			ESX = library 
		end)

		Citizen.Wait(0)
	end

end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData)
	ESX.PlayerData = playerData
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
	ESX.PlayerData["job"] = newJob
end)

cached = {}

Citizen.CreateThread(function()
    Wait(500)
    while true do
        local Sleep = 500
        local Ped = GetPlayerPed(-1)
        local PlyCoords = GetEntityCoords(Ped)
        for index, value in pairs(Config.Start) do

            local DstCheck = GetDistanceBetweenCoords(PlyCoords, value["Pos"], true)
            local MarkerText = "~r~" .. value["Text"]

            if not cached["MissionAlreadyStarted"] then
                if DstCheck <= 5.5 then
                    Sleep = 5
                    if DstCheck <= 1.3 then
                       MarkerText =  "[~g~E~s~] " .. "~r~" .. value["Text"]
                        if IsControlJustReleased(0, 38) then
                            ESX.TriggerServerCallback("Wiberg_Transport:PoliserAntal", function(PoliserAntal) 
                                if PoliserAntal >= Config.AntalPoliser then
                                    ESX.TriggerServerCallback("Wiberg_Transport:GetCooldownTimer", function(ald) 
                                        if ald then
                                            TriggerServerEvent('Wiberg_Transport:SetCooldown:Server')
                                            StartaTracker(math.random(#Config.Transporter))
                                        else
                                            SkickaNotis("~r~Tiril", 'Det finns inga ~y~transporter~s~ tillgängliga')
                                        end
                                    end)
                                else
                                    SkickaNotis("~r~Tiril", 'Det är för lite polis aktivitet i staden')
                                end
                            end)
                            Wait(1000)
                        end
                    end
                    ESX.Game.Utils.DrawText3D(value["Pos"], MarkerText, 0.6)
					DrawMarker(6, value["Pos"]-vector3(0.0,0.0,0.975), 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 155, 0, false, false, 0, false, false, false, false)
                end
            end
        end
        Citizen.Wait(Sleep)
    end
end)

--Create local ped
Citizen.CreateThread(function()
	local PedConfig = Config.Start["Start"]["Ped"]
	if not HasModelLoaded(PedConfig["Model"]) then
		while not HasModelLoaded(PedConfig["Model"]) do
			RequestModel(PedConfig["Model"])
			Citizen.Wait(10)
		end
	end

	cached["Ped"] = CreatePed(5, PedConfig["Model"], PedConfig["Pos"], PedConfig["Heading"], false)

	SetEntityAsMissionEntity(cached["Ped"], true, true)

	SetPedCombatAttributes(cached["Ped"], 46, true)                     
	SetPedFleeAttributes(cached["Ped"], 0, 0)                      
	SetBlockingOfNonTemporaryEvents(cached["Ped"], true)
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(3500)
        if cached["TransportOnGoing"] then
            if DoesEntityExist(cached["TransportVehicle"]) then
		    	local coords = GetEntityCoords(cached["TransportVehicle"])
                TriggerServerEvent('Wiberg_Transport:UpdateBlip:Server', coords) 
            end
        end
    end
end)

RegisterNetEvent('Wiberg_Transport:TransportBlipRemove')
AddEventHandler('Wiberg_Transport:TransportBlipRemove', function()
	if DoesBlipExist(cached['TransportVehicleBlip']) then
		RemoveBlip(cached["TransportVehicleBlip"])
   	end
end)

RegisterNetEvent('Wiberg_Transport:SkickaTillPolis')
AddEventHandler('Wiberg_Transport:SkickaTillPolis', function(message)
    TriggerServerEvent('esx_phone:send', "police", message, true, false)
end)

RegisterNetEvent('Wiberg_Transport:UpdateBlip')
AddEventHandler('Wiberg_Transport:UpdateBlip', function(coords)
	RemoveBlip(cached["TransportVehicleBlip"])
    cached["TransportVehicleBlip"] = AddBlipForCoord(coords)
    SetBlipSprite(cached["TransportVehicleBlip"], 161)
    SetBlipScale(cached["TransportVehicleBlip"], 2.0)
	SetBlipColour(cached["TransportVehicleBlip"], 1)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('GPS-Sändare')
    EndTextCommandSetBlipName(cached["TransportVehicleBlip"])
	PulseBlip(cached["TransportVehicleBlip"])
end)
