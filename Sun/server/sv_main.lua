local List_Players = {}
local List_Player_Identifier = {}

local function RegisterPlayerIdentifiers(Source)
    local Ok, Identifier = pcall(function()
        return Player(Source).state.Sun_identifier
    end)

    if Ok and type(Identifier) == "string" and Identifier ~= "" then
        List_Players[Source] = Identifier
        List_Player_Identifier[Identifier] = Source
    end
end

function Sun:GetIdentifier(Source)
    if type(Source) ~= "number" or Source < 1 then
        return nil
    end

    if List_Players[Source] then
        return List_Players[Source]
    end

    local Ok, Identifier = pcall(function()
        return Player(Source).state.Sun_identifier
    end)

    if Ok and type(Identifier) == "string" and Identifier ~= "" then
        List_Players[Source] = Identifier
        List_Player_Identifier[Identifier] = Source
        return Identifier
    end

    return nil
end

function Sun:GetSourceFromIdentifier(Identifier)
    if type(Identifier) ~= "string" or Identifier == "" then
        return nil
    end

    local Source = List_Player_Identifier[Identifier]

    if type(Source) == "number" and Source > 0 then
        return Source
    end

    return nil
end

AddEventHandler("Sun:LoadingCharacter", function(Source)
    if type(Source) == "number" and Source > 0 then
        RegisterPlayerIdentifiers(Source)
    end
end)

AddEventHandler("playerDropped", function()
    local Source = source
    local Identifier = List_Players[Source]

    if Identifier then
        List_Player_Identifier[Identifier] = nil
    end

    List_Players[Source] = nil
end)