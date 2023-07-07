local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vSERVER = Tunnel.getInterface('wnHud')
src = {}
Tunnel.bindInterface('wnHud', src)


local sBuffer = {}
local vBuffer = {}
local CintoSeguranca = false
local ExNoCarro = false
local hunger = 100
local thirst = 100

RegisterNetEvent("statusFome")
AddEventHandler("statusFome",function(number)
	hunger = parseInt(number)
end)

RegisterNetEvent("statusSede")
AddEventHandler("statusSede",function(number)
	thirst = parseInt(number)
end)

Citizen.CreateThread( function()
	while true do
		thirst,hunger = vSERVER.getStats()
		Citizen.Wait(500)
	end
end)

function GetTimeToDisplay()
	hour = GetClockHours()
	minute = GetClockMinutes()
	if hour <= 9 then
		hour = "0" .. hour
	end
	if minute <= 9 then
		minute = "0" .. minute
	end

	return hour .. ":" .. minute
end

inCar = false
Citizen.CreateThread(function()
	while true do
		local sleep = 300
		local ped = PlayerPedId()
		inCar = IsPedInAnyVehicle(ped, false)

		if inCar then 
			local x,y,z = table.unpack(GetEntityCoords(ped,false))
			
			vehicle = GetVehiclePedIsIn(ped, false)
			local health = (GetEntityHealth(GetPlayerPed(-1))-100)/config_vida*100
			local armour = GetPedArmour(ped)
			local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
			SendNUIMessage({
				action = "inCar",
				streetName = streetName,
				time = GetTimeToDisplay(),
				health = health,
				armour = armour,
				hunger = parseInt(hunger),
				thirst = parseInt(thirst),
			})	
		end

		Citizen.Wait(sleep)	
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 200
		if inCar then 
			sleep = 50
			local speed = math.ceil(GetEntitySpeed(vehicle) * 3.605936)
			local fuel = GetVehicleFuelLevel(vehicle)
			
			rpm = GetVehicleCurrentRpm(vehicle)
            rpm = math.ceil(rpm * 10000, 2)
			gear = GetVehicleCurrentGear(vehicle)

            if speed == 0 then 
                gear = 'N'
            elseif gear == 0 then 
                gear = 'R'
            end 

			locked = GetVehicleDoorLockStatus(vehicle)

            vehicleNailRpm = 280 - math.ceil( math.ceil((rpm-2000) * 140) / 10000)
			SendNUIMessage({
				only = "updateSpeed",
				speed = speed,
				fuel = parseInt(fuel),
				rpmnail = vehicleNailRpm,
				fome = parseInt(hunger),
				sede = parseInt(thirst),
                rpm = rpm/100,
				gear = gear,
				locked = locked,
				cinto = CintoSeguranca,
			})			
		end
		Citizen.Wait(sleep)	
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 250
		if not inCar then 
			DisplayRadar(false)
					
			local ped = PlayerPedId()
			local health = (GetEntityHealth(GetPlayerPed(-1))-100)/config_vida*100
			local armour = GetPedArmour(ped)
			local x,y,z = table.unpack(GetEntityCoords(ped,false))
			local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
	
			SendNUIMessage({
				action = "update",
				streetName = streetName,
				time = GetTimeToDisplay(),
				health = vida,
				armour = armour,
				hunger = parseInt(hunger),
				thirst = parseInt(thirst),
			})			

		else
				RequestStreamedTextureDict("circlemap",false)
				while not HasStreamedTextureDictLoaded("circlemap") do
					Citizen.Wait(100)
				end
				AddReplaceTexture("platform:/textures/graphics","radarmasksm","circlemap","radarmasksm")
				SetMinimapClipType(1)
				SetMinimapComponentPosition("minimap","L","B",0.009,-0.0125,0.16,0.28)
				SetMinimapComponentPosition("minimap_mask","L","B",0.155,0.12,0.080,0.15)
				SetMinimapComponentPosition("minimap_blur","L","B",0.0095,0.015,0.229,0.311)
				SetBigmapActive(false,false)
				DisplayRadar(true)
		end
		Citizen.Wait(sleep)	
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)

		if car ~= 0 and (ExNoCarro or IsCar(car)) then
			ExNoCarro = true
			if CintoSeguranca then
				DisableControlAction(0,75)
			end

			timeDistance = 4
			sBuffer[2] = sBuffer[1]
			sBuffer[1] = GetEntitySpeed(car)

			if sBuffer[2] ~= nil and not CintoSeguranca and GetEntitySpeedVector(car,true).y > 1.0 and sBuffer[1] > 10.25 and (sBuffer[2] - sBuffer[1]) > (sBuffer[1] * 0.255) then
				SetEntityHealth(ped,GetEntityHealth(ped)-10)
				TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
			end

			if IsControlJustReleased(1,47) then
				if CintoSeguranca then
					TriggerEvent("vrp_sound:source","unbelt",0.5)
					CintoSeguranca = false
				else
					TriggerEvent("vrp_sound:source","belt",0.5)
					CintoSeguranca = true
				end
			end
		elseif ExNoCarro then
			ExNoCarro = false
			CintoSeguranca = false
			sBuffer[1],sBuffer[2] = 0.0,0.0
		end
		Citizen.Wait(timeDistance)
	end
end)

RegisterCommand("cr",function(source,args)
	local veh = GetVehiclePedIsIn(PlayerPedId(),false)
	local maxspeed = GetVehicleMaxSpeed(GetEntityModel(veh))
	local vehspeed = GetEntitySpeed(veh)*3.605936
	if GetPedInVehicleSeat(veh,-1) == PlayerPedId() and math.ceil(vehspeed) >= 0 and GetEntityModel(veh) ~= -2076478498 and not IsEntityInAir(veh) then
		if args[1] == nil then
			SetEntityMaxSpeed(veh,maxspeed)
			TriggerEvent("Notify","sucesso","Limitador de Velocidade desligado com sucesso.")
		else
			SetEntityMaxSpeed(veh,0.45*args[1]-0.45)
			TriggerEvent("Notify","sucesso","Velocidade máxima travada em <b>"..args[1].." KM/H</b>.")
		end
	end
end)

RegisterCommand("hud",function(source,args)
	SendNUIMessage({
		action = "changeVisibility",
	})
end)




alertmaxfome = false
alertmaxsede = false

alertfome = false
alertsede = false


 Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        local ped = GetPlayerPed(-1)
        local health = GetEntityHealth(ped)
        local newhealth = health - 1

        if thirst >= 95 then
            TransitionToBlurred(1000)
            alertmaxfome = true
            SetEntityHealth(ped, newhealth)
        end
        if hunger >= 95 then 
            TransitionToBlurred(1000)
            alertmaxsede = true
            SetEntityHealth(ped, newhealth)
        end
            
        if hunger <= 95 and thirst <= 95 and GetEntityHealth(PlayerPedId()) >= 102 then
            TransitionFromBlurred(1000)
            alertmaxsede = false
            alertmaxfome = false
        end

    end
end)
AddEventHandler("hud:talkingState", function(number)
    SendNUIMessage({action = "proximity", number = number})
end)

RegisterNetEvent("hud:talknow")
AddEventHandler("hud:talknow", function(boolean)
    SendNUIMessage({action = "talking", falando = boolean})
end)


RegisterNetEvent("hud:channel")
AddEventHandler("hud:channel", function(text)
    SendNUIMessage({action = "channel", text = text})
end)
