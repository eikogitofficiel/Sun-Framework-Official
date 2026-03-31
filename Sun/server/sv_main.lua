local listPlayers = {}
local listPlayerIdentifier = {}

local function registerPlayerIdentifiers(source)
    local ok, identifier = pcall(function()
        return Player(source).state.Sun_identifier
    end)

    if ok and type(identifier) == "string" and identifier ~= "" then
        listPlayers[source] = identifier
        listPlayerIdentifier[identifier] = source

        Sun.IdentifierData = Sun.IdentifierData or {}
        Sun.IdentifierData[source] = {}
        local idData = Sun.IdentifierData[source]
        for i = 0, GetNumPlayerIdentifiers(source) - 1 do
            local id = GetPlayerIdentifier(source, i)
            if id then
                local idType = id:match("^(.-):")
                if idType then
                    idData[idType] = id
                end
            end
        end
    end
end

function Sun:getIdentifier(source)
    if type(source) ~= "number" or source < 1 then
        return nil
    end

    if listPlayers[source] then
        return listPlayers[source]
    end

    local ok, identifier = pcall(function()
        return Player(source).state.Sun_identifier
    end)

    if ok and type(identifier) == "string" and identifier ~= "" then
        listPlayers[source] = identifier
        listPlayerIdentifier[identifier] = source
        return identifier
    end

    return nil
end

function Sun:getSourceFromIdentifier(identifier)
    if type(identifier) ~= "string" or identifier == "" then
        return nil
    end

    local src = listPlayerIdentifier[identifier]

    if type(src) == "number" and src > 0 then
        return src
    end

    return nil
end

AddEventHandler("Sun:LoadingCharacter", function(source)
    if type(source) == "number" and source > 0 then
        registerPlayerIdentifiers(source)
    end
end)

RegisterNetEvent("Sun:CallBack:Connexion", function()
    local src = source
    if type(src) ~= "number" or src < 1 then return end
    if Sun.Players and Sun.Players[src] then return end

    local identifier = Sun:getIdentifier(src)
    if not identifier then return end

    local ban = nil
    pcall(function()
        ban = MySQL.single.await(
            'SELECT reason FROM sun_bans WHERE identifier = ? AND (expire IS NULL OR expire > UNIX_TIMESTAMP()) LIMIT 1',
            { identifier }
        )
    end)

    if ban then
        DropPlayer(src, "You are banned: " .. (ban.reason or "No reason given"))
        return
    end

    TriggerEvent("Sun:LoadingCharacter", src)
end)

AddEventHandler("playerDropped", function()
    local src = source
    local identifier = listPlayers[src]

    if identifier then
        listPlayerIdentifier[identifier] = nil
    end

    listPlayers[src] = nil
end)