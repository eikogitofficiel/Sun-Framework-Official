local function isAdmin(source)
    if source == 0 then
        return true
    end

    local group = Sun:GetGroup(source)

    return group == "admin" or group == "dev"
end

RegisterCommand("givemoney", function(source, args)
    if not isAdmin(source) then
        print("[Sun] You have not the permission for execute this command")
        return
    end

    local targetId = tonumber(args[1])
    local type = args[2]
    local amount = tonumber(args[3])

    if targetId and type and amount then
        local player = Sun.GetPlayer(targetId)

        if player then
            player:addMoney(type, amount)

            print("[Sun] " .. GetPlayerName(source) .. " give $" .. amount .. " " .. type .. " to " .. GetPlayerName(targetId))
        end
    end
end, false)

RegisterCommand("car", function(source, args)
    if isAdmin(source) then
        print("[Sun] You have not the permission for execute this command")
        return
    end

    local model = args[1]

    if not model then
        print("error")
        return
    end

    print("spawn")

    TriggerClientEvent('spawnVehicle', source, model)
end)