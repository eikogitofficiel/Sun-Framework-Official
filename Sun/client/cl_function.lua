local waitCallback = {}
local svCallback = {}
local requestingIdCallback = 0

function Sun:TriggerCallBack(Name, Cb, ...)
    requestingIdCallback = requestingIdCallback + 1
    waitCallback[requestingIdCallback] = Cb

    TriggerServerEvent("Sun:Callback:Trigger", {
        name = Name,
        RequestCallbackId = requestingIdCallback,
        args = { ... }
    })
end

function Sun:RegisterCallBack(Name, result)
    svCallback[Name] = result
end

-- Inventory

function Sun.RemoveItem(item, count)
    if not item or not count or count <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:RemoveItem", function(result)
        return result and result.success or false
    end, item, count)
end

function Sun.AddItem(item, count)
    if not item or not count or count <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:AddItem", function(result)
        return result and result.success or false
    end, item, count)
end

function Sun.GetInventoryWeight()
    Sun:TriggerCallBack("Sun:GetInventoryWeight", function(result)
        return result and result.weight or 0
    end)
end

function Sun.GetInventoryMaxWeight()
    Sun:TriggerCallBack("Sun:GetInventoryMaxWeight", function(result)
        return result and result.maxWeight or 0
    end)
end

function Sun.CanCarry(item, count)
    if not item or not count or count <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:CanCarry", function(result)
        return result and result.canCarry or false
    end, item, count)
end

-- Money

function Sun.AddAccountCash(amount)
    if not amount or amount <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:AddAccountCash", function(result)
        return result and result.success or false
    end, amount)
end

function Sun.AddAccountBank(amount)
    if not amount or amount <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:AddAccountBank", function(result)
        return result and result.success or false
    end, amount)
end

function Sun.AddAccountDirty(amount)
    if not amount or amount <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:AddAccountDirty", function(result)
        return result and result.success or false
    end, amount)
end

function Sun.RemoveAccountCash(amount)
    if not amount or amount <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:RemoveAccountCash", function(result)
        return result and result.success or false
    end, amount)
end

function Sun.RemoveAccountBank(amount)
    if not amount or amount <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:RemoveAccountBank", function(result)
        return result and result.success or false
    end, amount)
end

function Sun.RemoveAccountDirty(amount)
    if not amount or amount <= 0 then
        return false
    end

    Sun:TriggerCallBack("Sun:RemoveAccountDirty", function(result)
        return result and result.success or false
    end, amount)
end

function Sun.GetAccountCash()
    Sun:TriggerCallBack("Sun:GetAccountCash", function(result)
        return result and result.cash or 0
    end)
end
function Sun.GetAccountDirty()
    Sun:TriggerCallBack("Sun:GetAccountDirty", function(result)
        return result and result.dirty or 0
    end)
end

function Sun.GetAccountBank()
    Sun:TriggerCallBack("Sun:GetAccountBank", function(result)
        return result and result.bank or 0
    end)
end

-- Lifecycle events
RegisterNetEvent("Sun:OnPlayerLoaded", function()
    print("[Sun] The player has been loaded")
end)

RegisterNetEvent("Sun:Client:OnJobUpdated", function(job)
    Sun.PlayerData.job = job

    print("[Sun] The job has been updated : " .. (job.name or "unknown"))
end)

RegisterNetEvent("Sun:Client:OnGroupUpdated", function(group)
    Sun.PlayerData.group = group
    Sun.Permissions.group = group

    print("[Sun] the group of the player has been updated : " .. group)
end)

RegisterNetEvent("Sun:Callback:Response", function(responseId, result)
    if waitCallback[responseId] then
        waitCallback[responseId](result)
        waitCallback[responseId] = nil
    end
end)

RegisterNetEvent("Sun:Callback:Request", function(data)
    if type(data) ~= "table" then
        return
    end

    local name = data.name
    local callbackId = data.RequestCallbackId
    local handler = svCallback[name]
    local sending = function()
end)

function Sun.UpdatedPlayerJob(job)
    if not job then 
        return false
    end

    Sun:TriggerCallBack("Sun:SetJob", function(result)
        return result and result.success or false
    end, job)
end

function Sun.UpdatedPlayerGroup(group)
    if not group then
        return false
    end

    Sun:TriggerCallBack("Sun:SetGroup", function(result)
        return result and result.success or false
    end, group)
end

function Sun.GetPlayerJob()
    return Sun.PlayerData and Sun.PlayerData.job or nil
end

function Sun.GetPlayerGroup()
    return Sun.PlayerData and Sun.PlayerData.group or "user"
end