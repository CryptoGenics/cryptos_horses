local Horses = {}
local BrushPrompt
local LeadPrompt
local FeedPrompt

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local itemSet = CreateItemset(true)
        local size = Citizen.InvokeNative(0x59B57C4B06531E1E, GetEntityCoords(PlayerPedId()), 3.5, itemSet, 1, Citizen.ResultAsInteger())
        if size > 0 then
            for index = 0, size - 1 do
                local entity = GetIndexedItemInItemset(index, itemSet)  
                if Horses[entity] == nil then
                    if GetPedType(entity) == 28 then
                        Horses[entity] = 0
                        AddPrompts(entity)
                    end
                end
            end
        end
        
        if IsItemsetValid(itemSet) then
           DestroyItemset(itemSet)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if PromptHasStandardModeCompleted(BrushPrompt) then -- 0x4CC0E2FE
            local result, entity = GetPlayerTargetEntity(PlayerId())
            local coords = GetEntityCoords(PlayerPedId())
            local coordshorse = GetEntityCoords(entity)
            local distance = #(coords - coordshorse)
            if distance < 1.75 then
                TriggerServerEvent('cryptos_horses:requestbrush', entity)
            end
        end
        if PromptHasStandardModeCompleted(LeadPrompt) then -- 0xE30CD707
            local player = PlayerPedId()
            local result, entity = GetPlayerTargetEntity(PlayerId())
            local coords = GetEntityCoords(player)
            local coordshorse = GetEntityCoords(entity)
            local distance = #(coords - coordshorse)
            if distance < 1.75 then
                Citizen.InvokeNative(0x9A7A4A54596FE09D, player, entity)
            end
        end
        if PromptHasStandardModeCompleted(FeedPrompt) then -- 0xE30CD707
            local result, entity = GetPlayerTargetEntity(PlayerId())
            local coords = GetEntityCoords(PlayerPedId())
            local coordshorse = GetEntityCoords(entity)
            local distance = #(coords - coordshorse)
            if distance < 1.75 then
                TriggerServerEvent('cryptos_horses:requestfeed', entity)
            end
        end
    end
end)

function AddPrompts(entity)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong()) -- PromptGetGroupIdForTargetEntity

    local str = 'Brush'
    BrushPrompt = PromptRegisterBegin()
    PromptSetControlAction(BrushPrompt, 0x63A38F2C)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(BrushPrompt, str)
    PromptSetEnabled(BrushPrompt, 1)
    PromptSetVisible(BrushPrompt, 1)
    PromptSetStandardMode(BrushPrompt, 1)
    PromptSetGroup(BrushPrompt, group)
    PromptRegisterEnd(BrushPrompt)
    
    local str2 = 'Lead'
    LeadPrompt = PromptRegisterBegin()
    PromptSetControlAction(LeadPrompt, 0x17D3BFF5)
    str = CreateVarString(10, 'LITERAL_STRING', str2)
    PromptSetText(LeadPrompt, str)
    PromptSetEnabled(LeadPrompt, 1)
    PromptSetVisible(LeadPrompt, 1)
    PromptSetStandardMode(LeadPrompt, 1)
    PromptSetGroup(LeadPrompt, group)
    PromptRegisterEnd(LeadPrompt)

    local str3 = 'Feed'
    FeedPrompt = PromptRegisterBegin()
    PromptSetControlAction(FeedPrompt, 0x0D55A0F0)
    str = CreateVarString(10, 'LITERAL_STRING', str3)
    PromptSetText(FeedPrompt, str)
    PromptSetEnabled(FeedPrompt, 1)
    PromptSetVisible(FeedPrompt, 1)
    PromptSetStandardMode(FeedPrompt, 1)
    PromptSetGroup(FeedPrompt, group)
    PromptRegisterEnd(FeedPrompt)
end

RegisterNetEvent('cryptos_horses:Brush')
AddEventHandler('cryptos_horses:Brush', function (horse)
    local player = PlayerPedId()
    if horse == nil then
        if IsPedOnMount(player) then
            local horse = GetMount(player)
            Citizen.InvokeNative(0xCD181A959CFDD7F4, player, horse, GetHashKey("INTERACTION_BRUSH"), 0, 0)
            if Horses[horse] == 0 then
                Wait(8000)
                ClearPedEnvDirt(horse)
                brushcount = 1
            elseif Horses[horse] > 0 then
                Wait(8000)
                Citizen.InvokeNative(0xE3144B932DFDFF65, horse, 0.0, -1, 1, 1)
                ClearPedEnvDirt(horse)
                ClearPedDamageDecalByZone(horse ,10 ,"ALL")
                ClearPedBloodDamage(horse)
                Citizen.InvokeNative(0xD8544F6260F5F01E, horse, 10)
                Horses[horse] = 0
            end
        end
    else        
        local coords = GetEntityCoords(player)
        local coordshorse = GetEntityCoords(horse)
        local distance = #(coords - coordshorse)
        if distance < 1.5 then
            Citizen.InvokeNative(0xCD181A959CFDD7F4, player, horse, GetHashKey("INTERACTION_BRUSH"), 0, 0)
            if Horses[horse] == 0 then
                Wait(8000)
                ClearPedEnvDirt(horse)
                brushcount = 1
            elseif Horses[horse] > 0 then
                Wait(8000)
                Citizen.InvokeNative(0xE3144B932DFDFF65, horse, 0.0, -1, 1, 1)
                ClearPedEnvDirt(horse)
                ClearPedDamageDecalByZone(horse ,10 ,"ALL")
                ClearPedBloodDamage(horse)
                Citizen.InvokeNative(0xD8544F6260F5F01E, horse, 10)
                Horses[horse] = 0
            end
        end
    end
end)

RegisterNetEvent('cryptos_horses:Feed')
AddEventHandler('cryptos_horses:Feed', function(horse)
    local player = PlayerPedId()
    if horse == nil then
        if IsPedOnMount(player) then
            local horse = GetMount(player)
            TriggerServerEvent("cryptos_horses:Consume")
            Citizen.InvokeNative(0xCD181A959CFDD7F4, player, horse, -224471938, 0, 0)
            Wait(5000)
            PlaySoundFrontend("Core_Fill_Up", "Consumption_Sounds", true, 0)
            local Health = GetAttributeCoreValue(horse, 0)
            local newHealth = Health + 25
            local Stamina = GetAttributeCoreValue(horse, 0)
            local newStamina = Stamina + 25
            Citizen.InvokeNative(0xC6258F41D86676E0, horse, 0, newHealth) --core
            Citizen.InvokeNative(0xC6258F41D86676E0, horse, 1, newStamina) --core
        end
    else
        TriggerServerEvent("cryptos_horses:Consume")
        Citizen.InvokeNative(0xCD181A959CFDD7F4, player, horse, -224471938, 0, 0)
        Wait(5000)
        PlaySoundFrontend("Core_Fill_Up", "Consumption_Sounds", true, 0)
        local Health = GetAttributeCoreValue(horse, 0)
        local newHealth = Health + 25
        local Stamina = GetAttributeCoreValue(horse, 0)
        local newStamina = Stamina + 25
        Citizen.InvokeNative(0xC6258F41D86676E0, horse, 0, newHealth) --core
        Citizen.InvokeNative(0xC6258F41D86676E0, horse, 1, newStamina) --core
    end
end)