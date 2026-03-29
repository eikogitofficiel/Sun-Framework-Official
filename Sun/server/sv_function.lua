Sun = Sun or {}
Sun.Callbacks = Sun.Callbacks or {}
Sun.Callbacks.Registry = Sun.Callbacks.Registry or {}
Sun.Callbacks.Server_Registry = Sun.Callbacks.Server_Registry or {}
Sun.Callbacks.Data = Sun.Callbacks.Data or {}
Sun.Callbacks.Data_Source = Sun.Callbacks.Data_Source or {}
Sun.Callbacks.Request_Callback_Id = Sun.Callbacks.Request_Callback_Id or 0

function Sun.Callbacks:Register(Name, Callback)
    if type(Name) ~= "string" or Name == "" then
        return
    end

    if type(Callback) ~= "function" then
        return
    end

    self.Registry[Name] = Callback
end

function Sun.Callbacks:Register_Server(Name, Callback)
    if type(Name) ~= "string" or Name == "" then
        return
    end

    if type(Callback) ~= "function" then
        return
    end

    self.Server_Registry[Name] = Callback
end

function Sun.Callbacks:Trigger_Server(Name, Callback, ...)
    if type(Name) ~= "string" or Name == "" then
        return
    end

    local Handler = self.Server_Registry[Name]

    if type(Handler) ~= "function" then
        if type(Callback) == "function" then
            Callback(nil)
        end
        return
    end

    local Args = { ... }

    local function Send(Result)
        if type(Callback) == "function" then
            Callback(Result)
        end
    end

    Handler(Send, table.unpack(Args))
end

function Sun.Callbacks:TriggerClient(Source, Name, Callback, ...)
    if type(Source) ~= "number" or Source < 1 then
        return
    end

    if type(Name) ~= "string" then
        return
    end

    self.Request_Callback_Id = self.Request_Callback_Id + 1

    local Request_Callback_Id = self.Request_Callback_Id
    local Args = { ... }

    self.Data[Request_Callback_Id] = function(Result)
        self.Data[Request_Callback_Id] = nil
        self.Data_Source[Request_Callback_Id] = nil

        if type(Callback) == "function" then
            Callback(Result)
        end
    end

    self.Data_Source[Request_Callback_Id] = Source

    TriggerClientEvent("Sun:Callback:Request", Source, {
        Request_Callback_Id = Request_Callback_Id,
        name = Name,
        args = Args
    })
end

Sun.Callbacks:Register("Sun:RemoveItem", function(source, callback, item, count)
    local player = Sun.GetPlayer(source)
    local success = player and player:removeItem(item, count)

    if not player then
        callback({success = false})
        return
    end

    if not item or not count or count <= 0 or count > 1000 then
        print("[Sun] Security System - a tentative of remove item is invalid - by : " .. source .. "the item is : " .. tostring(item) .. " the count is : " .. tostring(count))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:AddItem", function(source, callback, item, count)
    local player = Sun.GetPlayer(source)
    local success = player and player:addItem(item, count)

    if not player then
        callback({success = false})
        return
    end

    if not item or not count or count <= 0 or count > 1000 then
        print("[Sun] Security System - a tentative of add item is invalid - by : " .. source .. "the item is : " .. tostring(item) .. " the count is : " .. tostring(count))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:GetInventoryWeight", function(source, callback)
    local player = Sun.GetPlayer(source)
    
    if not player then
        callback({weight = 0})
        return
    end

    local inventory = Sun.Config.Inventory.Inventory_Resource_Name

    if inventory and GetResourceState(resourceName) == "started" then
        local weight = exports[inventory]:GetInventoryWeight(source)
        callback({weight = weight or 0})
    else
        callback({weight = 0})
        return
    end
end)

Sun.Callbacks:Register("Sun:GetInventoryMaxWeight", function(source, callback)
    local playerId = source

    if not Sun.PlayerData[playerId] then
        callback({maxWeight = 0})
        return
    end

    local inventory = Sun.Config.Inventory.Inventory_Resource_Name

    if inventory and GetResourceState(inventory) == "started" then
        local maxWeight = exports[inventory]:GetInventoryMaxWeight(playerId)

        callback({maxWeight = maxWeight or 0})
    else
        callback({maxWeight = 0})
    end
end)

Sun.Callbacks:Register("Sun:CanCarry", function(source, callback, item, count)
    local playerId = source

    if not item or not count or count <= 0 then
        callback({canCarry = false})
        return
    end

    if not Sun.PlayerData[playerId] then
        callback({canCarry = false})
        return
    end

    local inventory = Sun.Config.Inventory.Inventory_Resource_Name

    if inventory and GetResourceState(inventory) == "started" then
        local canCarry = exports[inventory]:CanCarryItem(playerId, item, count)

        callback({canCarry = canCarry or false})
    else
        callback({canCarry = false})
    end
end)

-- Money
Sun.Callbacks:Register("Sun:AddAccountCash", function(source, callback, amount)
    local player = Sun.GetPlayer(source)
    local success = player and player:addMoney("Cash", amount)

    if not player then
        callback({success = false})
        return
    end

    if not amount or amount <= 0 or amount > 100000 then
        print("[Sun] Security System - a tentative of give cash money is invalid - by : " .. source .. "the amount is : " .. tostring(amount))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:AddAccountBank", function(source, callback, amount)
    local player = Sun.GetPlayer(source)
    local success = player and player:addMoney("Bank", amount)

    if not player then
        callback({success = false})
        return
    end

    if not amount or amount <= 0 or amount > 100000 then
        print("[Sun] Security System - a tentative of give bank money is invalid - by : " .. source .. "the amount is : " .. tostring(amount))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:AddAccountDirty", function(source, callback, amount)
    local player = Sun.GetPlayer(source)
    local success = player and player:addMoney("Black", amount)

    if not player then
        callback({success = false})
        return
    end

    if not amount or amount <= 0 or amount > 100000 then
        print("[Sun] Security System - a tentative of give dirty money is invalid - by : " .. source .. "the amount is : " .. tostring(amount))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:RemoveAccountCash", function(source, callback, amount)
    local player = Sun.GetPlayer(source)
    local success = player and player:removeMoney("Cash", amount)

    if not player then
        callback({success = false})
        return
    end

    if not amount or amount <= 0 or amount > 100000 then
        print("[Sun] Security System - a tentative of remove cash money is invalid - by : " .. source .. "the amount is : " .. tostring(amount))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:RemoveAccountBank", function(source, callback, amount)
    local player = Sun.GetPlayer(source)
    local success = player and player:removeMoney("Bank", amount)

    if not player then
        callback({success = false})
        return
    end

    if not amount or amount <= 0 or amount > 100000 then
        print("[Sun] Security System - a tentative of remove bank money is invalid - by : " .. source .. "the amount is : " .. tostring(amount))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:RemoveAccountDirty", function(source, callback, amount)
    local player = Sun.GetPlayer(source)
    local success = player and player:removeMoney("Black", amount)

    if not player then
        callback({success = false})
        return
    end

    if not amount or amount <= 0 or amount > 100000 then
        print("[Sun] Security System - a tentative of remove dirty money is invalid - by : " .. source .. "the amount is : " .. tostring(amount))
        callback({success = false})
    end

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:GetAccountBank", function(source, callback)
    local player = Sun.GetPlayer(source)
    local bank = player and player:getMoney("Bank") or 0

    callback({bank = bank})
end)

Sun.Callbacks:Register("Sun:GetAccountCash", function(source, callback)
    local player = Sun.GetPlayer(source)
    local cash = player and player:getMoney("Cash") or 0

    callback({cash = cash})
end)

Sun.Callbacks:Register("Sun:GetAccountDirty", function(source, callback)
    local player = Sun.GetPlayer(source)
    local dirty = player and player:getMoney("Black") or 0

    callback({dirty = dirty})
end)

-- Lifecycle Events
RegisterNetEvent("Sun:PlayerLoaded", function()
    local playerId = source

    if type(playerId) ~= "number" or playerId < 1 then
        return
    end

    if Sun.Players[playerId] then
        return
    end

    if not Sun.PlayerData[playerId] then
        Sun.PlayerData[playerId] = {}
    end

    Sun.PlayerData[playerId].money = Sun.PlayerData[playerId].money or {
        cash = Sun.Config.Money.Default_Money_Liquid,
        bank = Sun.Config.Money.Default_Money_Bank,
        dirty = Sun.Config.Money.Default_Money_Black
    }

    TriggerEvent("Sun:OnPlayerLoaded", playerId)
    TriggerClientEvent("Sun:Client:OnPlayerLoaded", playerId)

    print("[Sun] Player " .. playerId .. "load")
end)

AddEventHandler("playerDropped", function(reason)
    local playerId = source

    if Sun.PlayerData[playerId] then
        TriggerEvent("Sun:OnPlayerDropped", source, reason)

        Sun.PlayerData[playerId] = nil

        print("[Sun] The player " .. playerId .. "disconnect for " .. reason)
    end
end)

function Sun.SetPlayerJob(source, job)
    if not Sun.PlayerData[source] then
        return false
    end

    Sun.PlayerData[source].job = job

    TriggerEvent("Sun:OnJobUpdated", source, job)
    TriggerClientEvent("Sun:Client:OnJobUpdated", source, job)

    return true
end

function Sun.SetPlayerGroup(source, group)
    if not Sun.PlayerData[source] then
        return false
    end

    Sun.PlayerData[source].group = group

    TriggerEvent("Sun:OnGroupUpdated", source, group)
    TriggerClientEvent("Sun:Client:OnGroupUpdated", source, group)

    return true
end

Sun.Callbacks:Register("Sun:SetJob", function(source, callback, job)
    local player = Sun.GetPlayer(source)
    local success = player and player:setJob(job.name, job.grade)

    callback({success = success})
end)

Sun.Callbacks:Register("Sun:SetGroup", function(source, callback, group)
    local player = Sun.GetPlayer(source)
    local success = Sun:SetGroup(source, group)

    callback({success = success})
end)

RegisterNetEvent("Sun:Callback:ServerResponse", function(Request_Callback_Id, Result)
    local Source = source

    if type(Source) ~= "number" or Source < 1 then
        return
    end

    Request_Callback_Id = tonumber(Request_Callback_Id)

    if not Request_Callback_Id then
        return
    end

    if Sun.Callbacks.Data_Source[Request_Callback_Id] ~= Source then
        return
    end

    if not Sun.Callbacks.Data[Request_Callback_Id] then
        return
    end

    if type(Result) == "function" then
        return
    end

    if type(Result) == "table" then
        for k, v in pairs(Result) do
            if type(v) == "function" then
                return
            end
        end
    end

    if Sun.Callbacks.Data[Request_Callback_Id] then
        Sun.Callbacks.Data[Request_Callback_Id](Result)
    end
end)

RegisterNetEvent("Sun:Callback:Trigger", function(Data)
    local Source = source

    if type(Source) ~= "number" or Source < 1 then
        return
    end

    if Sun.CallbackRateLimit and Sun.CallbackRateLimit[Source] and (GetGameTimer() - Sun.CallbackRateLimit[Source]) < 100 then
        return
    end
    Sun.CallbackRateLimit = Sun.CallbackRateLimit or {}
    Sun.CallbackRateLimit[Source] = GetGameTimer()

    if type(Data) ~= "table" then
        return
    end

    local Name = Data.name
    local Request_Callback_Id = Data.Request_Callback_Id
    local Args = Data.args or {}

    if type(Name) ~= "string" then
        return
    end

    if string.len(Name) > 50 or not string.match(Name, "^[%w_:%-]+$") then
        return
    end

    if type(Request_Callback_Id) ~= "number" then
        return
    end

    if type(Args) ~= "table" then
        return
    end

    if #Args > 10 then
        return
    end

    for i, arg in ipairs(Args) do
        if type(arg) == "function" then
            return
        end
        if type(arg) == "table" then
            for k, v in pairs(arg) do
                if type(v) == "function" then
                    return
                end
            end
        end
    end

    local Callback = Sun.Callbacks.Registry[Name]

    local function Send(Result)
        if type(Result) == "function" then
            return
        end
        if type(Result) == "table" then
            for k, v in pairs(Result) do
                if type(v) == "function" then
                    return
                end
            end
        end
        TriggerClientEvent("Sun:Callback:Response", Source, Request_Callback_Id, Result)
    end

    if type(Callback) == "function" then
        Callback(Source, Send, table.unpack(Args))
    else
        Send(nil)
    end
end)