Sun = Sun or {}
Sun.Players = Sun.Players or {}
Sun.Money = Sun.Money or {}
Sun.Money.Data = Sun.Money.Data or {}
Sun.Jobs = Sun.Jobs or {}
Sun.Jobs.Data = Sun.Jobs.Data or {}
Sun.PlayerMeta = Sun.PlayerMeta or {}
Sun.GroupData = Sun.GroupData or {}
Sun.Usable_Items = Sun.Usable_Items or {}

function Sun.Money:LoadingMoney(Identifier)
    local Result = nil
    pcall(function()
        Result = MySQL.single.await(
            'SELECT cash, bank, black_money FROM users WHERE identifier = ? LIMIT 1',
            { Identifier }
        )
    end)

    if not Result then
        return {
            Cash  = Sun.Config.Money.Default_Money_Liquid,
            Bank  = Sun.Config.Money.Default_Money_Bank,
            Black = Sun.Config.Money.Default_Money_Black,
        }
    end

    return {
        Cash  = tonumber(Result.cash) or 0,
        Bank  = tonumber(Result.bank) or 0,
        Black = tonumber(Result.black_money) or 0,
    }
end

function Sun.Money:SaveMoney(Identifier)
    local Data = Sun.Money.Data[Identifier]
    if not Data then return end

    MySQL.update.await(
        'UPDATE users SET cash = ?, bank = ?, black_money = ? WHERE identifier = ?',
        { Data.Cash or 0, Data.Bank or 0, Data.Black or 0, Identifier }
    )
end

function Sun.Money:Sync(Source, Identifier)
    local Data = Sun.Money.Data[Identifier] or {}

    TriggerClientEvent("Sun:PlayerData:Update", Source, "Money", {
        Cash  = tonumber(Data.Cash)  or 0,
        Bank  = tonumber(Data.Bank)  or 0,
        Black = tonumber(Data.Black) or 0,
    })
end

function Sun.Money:GetMoney(Source, Type)
    local Player = Sun.Players[Source]
    if not Player then return 0 end

    local Data = Sun.Money.Data[Player.identifier] or {}

    if Type then
        return tonumber(Data[Type]) or 0
    end

    return {
        Cash  = tonumber(Data.Cash)  or 0,
        Bank  = tonumber(Data.Bank)  or 0,
        Black = tonumber(Data.Black) or 0,
    }
end

function Sun.Money:AddMoney(Source, Type, Amount)
    local Player = Sun.Players[Source]
    if not Player then return false end

    local Identifier = Player.identifier
    Amount = tonumber(Amount) or 0

    if Amount <= 0 then return false end

    if not Sun.Money.Data[Identifier] then
        Sun.Money.Data[Identifier] = { Cash = 0, Bank = 0, Black = 0 }
    end

    Sun.Money.Data[Identifier][Type] = (tonumber(Sun.Money.Data[Identifier][Type]) or 0) + Amount

    Sun.Money:SaveMoney(Identifier)

    return true
end

function Sun.Money:RemoveMoney(Source, Type, Amount)
    local Player = Sun.Players[Source]
    if not Player then return false end

    local Identifier = Player.identifier
    Amount = tonumber(Amount) or 0

    if Amount <= 0 then return false end

    if not Sun.Money.Data[Identifier] then return false end

    local Current = tonumber(Sun.Money.Data[Identifier][Type]) or 0

    if Current < Amount then 
        return false 
    end

    Sun.Money.Data[Identifier][Type] = Current - Amount

    Sun.Money:SaveMoney(Identifier)

    return true
end

function Sun.Money:SetMoney(Source, Type, Amount)
    local Player = Sun.Players[Source]
    if not Player then return false end

    local Identifier = Player.identifier
    Amount = tonumber(Amount) or 0

    if not Sun.Money.Data[Identifier] then
        Sun.Money.Data[Identifier] = { Cash = 0, Bank = 0, Black = 0 }
    end

    Sun.Money.Data[Identifier][Type] = Amount

    Sun.Money:SaveMoney(Identifier)

    return true
end

function Sun.Jobs:LoadingJobs(Identifier)
    local Result = nil
    pcall(function()
        Result = MySQL.single.await(
            'SELECT job, job_grade, job_illegal, job_illegal_grade FROM users WHERE identifier = ? LIMIT 1',
            { Identifier }
        )
    end)

    if not Result then
        return {
            Legal = { name = "unemployed", grade = 0 },
            Illegal = { name = nil, grade = 0 },
        }
    end

    return {
        Legal = { name = Result.job or "unemployed", grade = tonumber(Result.job_grade) or 0 },
        Illegal = { name = Result.job_illegal  or nil, grade = tonumber(Result.job_illegal_grade) or 0 },
    }
end

function Sun.Jobs:Sync(Source, Identifier)
    local Data = Sun.Jobs.Data[Identifier] or {}
    local Legal = Data.Legal or {}
    local Illegal = Data.Illegal or {}

    TriggerClientEvent("Sun:PlayerData:Update", Source, "Job", {
        Legal = { name = Legal.name or "unemployed", grade = Legal.grade or 0 },
        Illegal = { name = Illegal.name or nil, grade = Illegal.grade or 0 },
    })
end

function Sun.Jobs:GetJobs(Source)
    local Player = Sun.Players[Source]
    if not Player then 
        return nil 
    end

    return Sun.Jobs.Data[Player.identifier]
end

function Sun.Jobs:SetLegalJob(Source, JobName, Grade)
    local Player = Sun.Players[Source]

    if not Player then 
        return false 
    end

    local Identifier = Player.identifier

    if not Sun.Jobs.Data[Identifier] then
        Sun.Jobs.Data[Identifier] = { Legal = {}, Illegal = {} }
    end

    Sun.Jobs.Data[Identifier].Legal = { name = JobName or "unemployed", grade = tonumber(Grade) or 0 }

    MySQL.update.await(
        'UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?',
        { JobName or "unemployed", tonumber(Grade) or 0, Identifier }
    )

    return true
end

function Sun.Jobs:SetIllegalJob(Source, JobName, Grade)
    local Player = Sun.Players[Source]

    if not Player then 
        return false 
    end

    local Identifier = Player.identifier

    if not Sun.Jobs.Data[Identifier] then
        Sun.Jobs.Data[Identifier] = { Legal = {}, Illegal = {} }
    end

    Sun.Jobs.Data[Identifier].Illegal = { name = JobName, grade = tonumber(Grade) or 0 }

    MySQL.update.await(
        'UPDATE users SET job_illegal = ?, job_illegal_grade = ? WHERE identifier = ?',
        { JobName, tonumber(Grade) or 0, Identifier }
    )

    return true
end


function Sun:GetGroup(Source, Refresh)
    if type(Source) ~= "number" or Source < 1 then
        return nil
    end

    local Identifier = self:GetPlayerIdentifier(Source)

    if not Identifier then
        return nil
    end

    if not Refresh and self.GroupData[Identifier] then
        return self.GroupData[Identifier]
    end

    local Result = nil
    local ok, err = pcall(function()
        Result = MySQL.single.await('SELECT `group` FROM users WHERE identifier = ? LIMIT 1', { Identifier })
    end)

    if not ok then
        return "user"
    end

    local Group = Result and Result.group or "user"
    self.GroupData[Identifier] = Group

    return Group
end

function Sun:SetGroup(Source, Group)
    if type(Source) ~= "number" or Source < 1 then
        return false
    end

    local Identifier = self:GetPlayerIdentifier(Source)

    if not Identifier then
        return false
    end

    local ok = pcall(function()
        MySQL.update.await('UPDATE users SET `group` = ? WHERE identifier = ?', { Group, Identifier })
    end)

    if ok then
        self.GroupData[Identifier] = Group
        return true
    end

    return false
end

function Sun:GetPlayerData(Source)
    if type(Source) ~= "number" or Source < 1 then
        return nil
    end

    local Player = self.Players[Source]
    
    if not Player then
        return nil
    end

    local Identifier = Player.identifier
    local MoneyData = self.Money.Data[Identifier] or {}
    local JobsData = self.Jobs.Data[Identifier] or {}
    local LegalJob = JobsData.Legal or {}
    local IllegalJob = JobsData.Illegal or {}

    return {
        Identifier = Identifier,
        Name = Player.name,
        Source = Source,
        Money = {
            Cash = tonumber(MoneyData.Cash) or 0,
            Bank = tonumber(MoneyData.Bank) or 0,
            Black = tonumber(MoneyData.Black) or 0,
        },
        Job = {
            Legal = {
                name = LegalJob.name or "unemployed",
                grade = LegalJob.grade or 0,
            },
            Illegal = {
                name = IllegalJob.name or nil,
                grade = IllegalJob.grade or 0,
            },
        },
        Meta = self.PlayerMeta[Identifier] or {},
    }
end

function Sun:SetPlayerMeta(Identifier, Index, Value)
    if type(Identifier) ~= "string" or Identifier == "" then
        return false
    end
    if type(Index) ~= "string" or Index == "" then
        return false
    end

    if not self.PlayerMeta[Identifier] then
        self.PlayerMeta[Identifier] = {}
    end

    self.PlayerMeta[Identifier][Index] = Value

    for Src, Plr in pairs(self.Players) do
        if Plr.identifier == Identifier then
            TriggerClientEvent("Sun:PlayerData:Update", Src, "Meta", { [Index] = Value })
            break
        end
    end

    return true
end

function Sun:GetPlayerMeta(Identifier, Index)
    if type(Identifier) ~= "string" or Identifier == "" then
        return nil
    end

    local Meta = self.PlayerMeta[Identifier]
    if not Meta then
        return nil
    end

    if Index ~= nil then
        return Meta[Index]
    end

    return Meta
end

function Sun:GetPlayerIdentifier(Source)
    if type(Source) ~= "number" then
        return nil
    end

    local Ok, Id = pcall(function()
        return Player(Source).state.Sun_identifier
    end)

    return (Ok and type(Id) == "string" and Id ~= "") and Id or nil
end

local function getIdentifier(Source)
    if type(Source) ~= "number" or Source < 1 then
        return nil
    end

    return Sun:GetPlayerIdentifier(Source)
end

local function createPlayer(Source)
    local Identifier = getIdentifier(Source)

    if not Identifier then
        return nil
    end

    local Player = {
        source = Source,
        identifier = Identifier,
        name = GetPlayerName(Source) or nil
    }

    function Player:getMoney(Type)
        if Type then
            return Sun.Money:GetMoney(self.source, Type)
        end

        return Sun.Money:GetMoney(self.source)
    end

    function Player:addMoney(Type, Amount)
        local Result = Sun.Money:AddMoney(self.source, Type, Amount)
        if Result then
            local MoneyData = Sun.Money.Data[self.identifier] or {}
            TriggerClientEvent("Sun:PlayerData:Update", self.source, "Money", {
                Cash = tonumber(MoneyData.Cash) or 0,
                Bank = tonumber(MoneyData.Bank) or 0,
                Black = tonumber(MoneyData.Black) or 0,
            })
        end
        return Result
    end

    function Player:removeMoney(Type, Amount)
        local Result = Sun.Money:RemoveMoney(self.source, Type, Amount)
        if Result then
            local MoneyData = Sun.Money.Data[self.identifier] or {}
            TriggerClientEvent("Sun:PlayerData:Update", self.source, "Money", {
                Cash = tonumber(MoneyData.Cash) or 0,
                Bank = tonumber(MoneyData.Bank) or 0,
                Black = tonumber(MoneyData.Black) or 0,
            })
        end
        return Result
    end

    function Player:setMoney(Type, Amount)
        local MoneyData = Sun.Money.Data[self.identifier] or {}
        local Result = Sun.Money:SetMoney(self.source, Type, Amount)
        local Updated_Money = {
            Cash = tonumber(MoneyData.Cash) or 0,
            Bank = tonumber(MoneyData.Bank) or 0,
            Black = tonumber(MoneyData.Black) or 0,
        }
        Updated_Money[Type] = tonumber(Amount) or 0
        TriggerClientEvent("Sun:PlayerData:Update", self.source, "Money", Updated_Money)
        return Result
    end

    function Player:getJob()
        local Jobs = Sun.Jobs:GetJobs(self.source)

        if not Jobs or not Jobs.Legal then
            return "unemployed", 0
        end

        return Jobs.Legal.name or "unemployed", Jobs.Legal.grade or 0
    end

    function Player:setJob(JobName, Grade)
        local Result = Sun.Jobs:SetLegalJob(self.source, JobName, Grade)
        TriggerClientEvent("Sun:PlayerData:Update", self.source, "Job", {
            name = JobName or "unemployed",
            grade = Grade or 0,
            type = "legal",
        })
        return Result
    end

    function Player:setIllegalJob(JobName, Grade)
        local Result = Sun.Jobs:SetIllegalJob(self.source, JobName, Grade)
        TriggerClientEvent("Sun:PlayerData:Update", self.source, "Job", {
            name = JobName or nil,
            grade = Grade or 0,
            type = "illegal",
        })
        return Result
    end

    function Player:getInventory()
        return Sun_GetPlayerInventory and Sun_GetPlayerInventory(self.identifier) or nil
    end

    function Player:hasItem(ItemName, Quantity)
        return Sun_HasItem and Sun_HasItem(self.identifier, ItemName, Quantity or 1) or false
    end

    function Player:addItem(ItemName, Quantity)
        local Result = Sun_AddItem and Sun_AddItem(self.identifier, ItemName, Quantity or 1) or false
        if Result then
            TriggerClientEvent("Sun:Client:RefreshInventory", self.source)
        end
        return Result
    end

    function Player:removeItem(ItemName, Quantity)
        local Result = Sun_RemoveItem and Sun_RemoveItem(self.identifier, ItemName, Quantity or 1) or false
        if Result then
            TriggerClientEvent("Sun:Client:RefreshInventory", self.source)
        end
        return Result
    end

    function Player:triggerEvent(Event_Name, ...)
        if type(Event_Name) ~= "string" or Event_Name == "" then
            return false
        end

        TriggerClientEvent(Event_Name, self.source, ...)

        return true
    end

    return Player
end

function Sun:GetPlayer(Source)
    if type(Source) ~= "number" or Source < 1 then
        return nil
    end

    return self.Players[Source]
end

function Sun:GetPlayerFromIdentifier(Identifier)
    if type(Identifier) ~= "string" or Identifier == "" then
        return nil
    end

    for _, Player in pairs(self.Players) do
        if Player.identifier == Identifier then
            return Player
        end
    end

    return nil
end

function Sun:GetPlayers()
    local Players_List = {}

    for _, Player in pairs(self.Players) do
        if Player then
            table.insert(Players_List, Player)
        end
    end

    return Players_List
end

function Sun:RegisterUsableItem(Item_Name, Callback)
    if type(Item_Name) ~= "string" or Item_Name == "" then
        return false
    end

    if type(Callback) ~= "function" then
        return false
    end

    self.Usable_Items[Item_Name] = Callback

    return true
end

function Sun:UseItem(Source, Item_Name)
    if type(Source) ~= "number" or Source < 1 then
        return false
    end

    if type(Item_Name) ~= "string" or Item_Name == "" then
        return false
    end

    local Player = self:GetPlayer(Source)

    if not Player then
        return false
    end

    local Callback = self.Usable_Items[Item_Name]

    if type(Callback) ~= "function" then
        return false
    end

    Callback(Source, Player)

    return true
end

AddEventHandler("Sun:LoadingCharacter", function(Source)
    if type(Source) ~= "number" then
        return
    end

    local Player = createPlayer(Source)

    if not Player then
        return
    end

    Sun.Players[Source] = Player

    local Identifier = Player.identifier

    Sun.Money.Data[Identifier] = Sun.Money:LoadingMoney(Identifier)
    Sun.Money:Sync(Source, Identifier)

    Sun.Jobs.Data[Identifier] = Sun.Jobs:LoadingJobs(Identifier)
    Sun.Jobs:Sync(Source, Identifier)

    Sun:GetGroup(Source, true)

    local MoneyData = Sun.Money.Data[Identifier] or {}
    local JobsData = Sun.Jobs.Data[Identifier] or {}
    local LegalJob = JobsData.Legal or {}
    local IllegalJob = JobsData.Illegal or {}

    TriggerClientEvent("Sun:PlayerData:Load", Source, {
        Identifier = Identifier,
        Name = Player.name,
        Money = {
            Cash = tonumber(MoneyData.Cash) or 0,
            Bank = tonumber(MoneyData.Bank) or 0,
            Black = tonumber(MoneyData.Black) or 0,
        },
        Job = {
            Legal = {
                name = LegalJob.name or "unemployed",
                grade = LegalJob.grade or 0,
            },
            Illegal = {
                name = IllegalJob.name or nil,
                grade = IllegalJob.grade or 0,
            },
        },
        Meta = Sun.PlayerMeta[Identifier] or {},
    })
end)

AddEventHandler("playerDropped", function()
    local Source = source
    local Player = Sun.Players[Source]

    if not Player then
        return
    end

    local Identifier = Player.identifier

    Sun.Money:SaveMoney(Identifier)
    Sun.Money.Data[Identifier] = nil

    Sun.Jobs.Data[Identifier] = nil
    Sun.PlayerMeta[Identifier] = nil
    Sun.GroupData[Identifier] = nil

    Sun.Players[Source] = nil
end)

RegisterNetEvent("Sun:ReloadRequest", function()
    local Source = source
    
    if type(Source) ~= "number" or Source < 1 then return end
    
    local player = Sun.GetPlayer(Source)
    if not player then return end
    
    if Sun.ReloadRateLimit and Sun.ReloadRateLimit[Source] and (GetGameTimer() - Sun.ReloadRateLimit[Source]) < 5000 then
        return
    end
    Sun.ReloadRateLimit = Sun.ReloadRateLimit or {}
    Sun.ReloadRateLimit[Source] = GetGameTimer()
    
    TriggerEvent("Sun:LoadingCharacter", Source)
end)

CreateThread(function()
    while true do
        Wait(30000)
        for Source, Player in pairs(Sun.Players) do
            if Player and Source then
                local Identifier = Player.identifier
                Sun.Money:Sync(Source, Identifier)
                Sun.Jobs:Sync(Source, Identifier)
            end
        end
    end
end)