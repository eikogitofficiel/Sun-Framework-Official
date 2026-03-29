exports("getSharedObject", function()
    return Sun
end)

exports("GetPlayer", function(Source)
    return Sun and Sun.GetPlayer and Sun:GetPlayer(Source) or nil
end)

exports("GetPlayerFromIdentifier", function(Identifier)
    return Sun and Sun.GetPlayerFromIdentifier and Sun:GetPlayerFromIdentifier(Identifier) or nil
end)

exports("GetPlayers", function()
    return Sun and Sun.GetPlayers and Sun:GetPlayers() or {}
end)

exports("GetPlayerIdentifier", function(Source)
    return Sun and Sun.GetPlayerIdentifier and Sun:GetPlayerIdentifier(Source) or nil
end)

exports("GetPlayerData", function(Source)
    return Sun and Sun.GetPlayerData and Sun:GetPlayerData(Source) or nil
end)

exports("GetGroup", function(Source, Refresh)
    return Sun and Sun.GetGroup and Sun:GetGroup(Source, Refresh) or nil
end)

exports("SetGroup", function(Source, Group)
    return Sun and Sun.SetGroup and Sun:SetGroup(Source, Group) or false
end)

exports("GetPlayerMeta", function(Identifier, Key)
    return Sun and Sun.GetPlayerMeta and Sun:GetPlayerMeta(Identifier, Key) or nil
end)

exports("SetPlayerMeta", function(Identifier, Key, Value)
    return Sun and Sun.SetPlayerMeta and Sun:SetPlayerMeta(Identifier, Key, Value) or false
end)

exports("RegisterCallback", function(Name, Callback)
    if Sun and Sun.Callbacks and Sun.Callbacks.Register then
        Sun.Callbacks:Register(Name, Callback)
        return true
    end
    return false
end)

exports("RegisterServerCallback", function(Name, Callback)
    if Sun and Sun.Callbacks and Sun.Callbacks.Register_Server then
        Sun.Callbacks:Register_Server(Name, Callback)
        return true
    end
    return false
end)

exports("TriggerCallback", function(Source, Name, Callback, ...)
    if Sun and Sun.Callbacks and Sun.Callbacks.TriggerClient then
        Sun.Callbacks:TriggerClient(Source, Name, Callback, ...)
        return true
    end
    return false
end)

exports("TriggerServerCallback", function(Name, Callback, ...)
    if Sun and Sun.Callbacks and Sun.Callbacks.Trigger_Server then
        Sun.Callbacks:Trigger_Server(Name, Callback, ...)
        return true
    end
    return false
end)

exports("RegisterUsableItem", function(Item_Name, Callback)
    return Sun and Sun.RegisterUsableItem and Sun:RegisterUsableItem(Item_Name, Callback) or false
end)

exports("UseItem", function(Source, Item_Name)
    return Sun and Sun.UseItem and Sun:UseItem(Source, Item_Name) or false
end)
