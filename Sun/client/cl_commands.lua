function Sun:Initialize_Commands()
    RegisterCommand("car", function(k, args)
        local modelVehicle = args and args[1] and tostring(args[1]):lower() or ""

        if modelVehicle == "" then
            return
        end

        local modelVehicleHash = GetHashKey(modelVehicle)

        if not IsModelInCdimage(modelVehicleHash) or not IsModelAVehicle(modelVehicleHash) then
            return
        end

        CreateThread(function()
            RequestModel(modelVehicleHash)
            while not HasModelLoaded(modelVehicleHash) do
                Wait(0)
            end

            local player = PlayerPedId()
            local playerCoord = GetEntityCoords(player)
            local playerCoordHeading = GetEntityHeading(player)
            local playerCoordForwardVector = GetEntityForwardVector(player)

            local Vehicle_To_Spawn = CreateVehicle(modelVehicleHash, playerCoord.x + playerCoordForwardVector.x * 3.0, playerCoord.y + playerCoordForwardVector.y * 3.0, playerCoord.z + 0.5,
                playerCoordHeading, true, false)

            SetVehicleOnGroundProperly(Vehicle_To_Spawn)
            SetEntityAsMissionEntity(Vehicle_To_Spawn, true, true)
            SetVehicleEngineOn(Vehicle_To_Spawn, true, true, false)
            TaskWarpPedIntoVehicle(player, Vehicle_To_Spawn, -1)

            SetModelAsNoLongerNeeded(modelVehicleHash)
        end)
    end, false)

    RegisterCommand("tp", function(k, args)
        if not args[1] or not args[2] or not args[3] then
            return
        end

        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if not x or not y or not z then
            return
        end

        SetEntityCoordsNoOffset(PlayerPedId(), x, y, z, false, false, false)
    end, false)

    RegisterCommand("dv", function(k, args)
        local distanceDv = args[1] and tonumber(args[1]) or 2.0

        local player = PlayerPedId()
        local playerCoord = GetEntityCoords(player)
        local vehicleToDv = GetVehiclePedIsIn(player, false)

        if vehicleToDv ~= 0 then
            SetEntityAsMissionEntity(vehicleToDv, true, false)
            DeleteVehicle(vehicleToDv)
            return
        end

        for _, vehicle in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(vehicle) then
                if #(playerCoord - GetEntityCoords(vehicle)) <= distanceDv then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                end
            end
        end
    end, false)
end

Sun:Initialize_Commands()