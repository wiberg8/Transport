---------Esx-----------
local ESX

TriggerEvent("esx:getSharedObject", function(library) 
	ESX = library 
end)



local showed = false

cached = {}

---------Kod----------

---ServerEvent---
RegisterServerEvent('Wiberg_Transport:GiveItem:Server')
AddEventHandler('Wiberg_Transport:GiveItem:Server', function(ItemName)
    local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	for i=1, #ItemName do
		xPlayer.addInventoryItem(ItemName[i], 1)
	end
	TriggerClientEvent('esx:showAdvancedNotification', source, Config.TitelServer, '~r~Tiril', 'Tjenare hörde att min kollega fått sina saker. De gav dig förhoppningsvis en ' .. ESX.GetItemLabel(ItemName[1]) .. ' som tack', 'CHAR_MP_FM_CONTACT', 1)
end)

RegisterServerEvent('Wiberg_Transport:UpdateBlip:Server') 
AddEventHandler('Wiberg_Transport:UpdateBlip:Server', function(coords)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('Wiberg_Transport:UpdateBlip', xPlayers[i], coords)
			if not showed then
				TriggerClientEvent('Wiberg_Transport:SkickaTillPolis', source, 'Tjenare såg en kille köra iväg med en bil med en massa vapen. Det finns en Gps sändare på den som jag satt ditt')
				showed = true
			end
		else
			TriggerClientEvent('Wiberg_Transport:TransportBlipRemove', xPlayers[i])
		end
	end
end)

RegisterServerEvent('Wiberg_Transport:TransportBlipRemove:Server')
AddEventHandler('Wiberg_Transport:TransportBlipRemove:Server', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
            TriggerClientEvent('Wiberg_Transport:TransportBlipRemove', xPlayers[i])
		end
	end
end)

RegisterServerEvent('Wiberg_Transport:SetCooldown:Server')
AddEventHandler('Wiberg_Transport:SetCooldown:Server', function()
	--[[
	MySQL.Async.execute("UPDATE wiberg_cooldowns SET Tid=@Tid WHERE Unique='Transport'",
		{
			["@Tid"] = os.time()
		}
	)	
	]]--

	MySQL.Sync.execute("UPDATE wiberg_cooldowns SET Tid=@Tid WHERE Identifier=@Identifier", 
		{
			['@Tid'] = os.time(), 
			['@Identifier'] = 'Transport'
		}
	)
end)


---Callbacks---
ESX.RegisterServerCallback('Wiberg_Transport:PoliserAntal',function(source, cb)
	local Poliser = 0
	local Players = GetPlayers()
	for i=1, #Players, 1 do
		local _source = Players[i]
		local xPlayer = ESX.GetPlayerFromId(_source)
		local playerjob = xPlayer.job.name
		if playerjob == 'police' then
			Poliser = Poliser + 1
		end
	end
	cb(Poliser)
end)

ESX.RegisterServerCallback('Wiberg_Transport:GetCooldownTimer',function(source, cb)
	local source = source
	MySQL.Async.fetchAll("SELECT Tid FROM wiberg_cooldowns WHERE Identifier=@Identifier", 
	{
		["@Identifier"] = "Transport"
	}, 
	function(result) 
		if result ~= nil then
            local SenasteTid = result[1].Tid
            local NuvarandeTid = os.time()
			local SkillnadTid = NuvarandeTid - SenasteTid
            if SkillnadTid > Config.CooldownTid then
                cb(true)
            else
                cb(false)
			end	
		end

	end)
	
end)
