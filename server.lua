local Inventory = {}
TriggerEvent("redemrp_inventory:getData",function(table)
	Inventory = table
end)

RegisterServerEvent("RegisterUsableItem:brush")
AddEventHandler("RegisterUsableItem:brush", function(source)
	TriggerClientEvent('cryptos_horses:Brush', source)
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.FeedItems) do
        RegisterServerEvent("RegisterUsableItem:"..v)
        AddEventHandler("RegisterUsableItem:"..v, function(source)
            TriggerClientEvent('cryptos_horses:Feed', source, false, Config.FeedPercentage, v)
        end)
    end
end)

RegisterServerEvent("cryptos_horses:Consume")
AddEventHandler("cryptos_horses:Consume", function(item)
    local _source = source
    if item then
        if Config.Redemrp_inventory2 == true then
            local ItemData = Inventory.getItem(_source, item)
            if ItemData.ItemAmount > 0 then
                local ItemData = Inventory.getItem(_source, item)
                ItemData.RemoveItem(1)
            end
        else
            local amount = Inventory.checkItem(_source, item)
            if amount > 0 then
                Inventory.delItem(_source, item, 1)
            end
        end
    else
        for k,FeedItem in pairs(Config.FeedItems) do
            if Config.Redemrp_inventory2 == true then
                local ItemData = Inventory.getItem(_source, FeedItem)
                if ItemData.ItemAmount > 0 then
                    local ItemData = Inventory.getItem(_source, FeedItem)
                    ItemData.RemoveItem(1)
                    break
                end
            else
                local amount = Inventory.checkItem(_source, FeedItem)
                if amount > 0 then
                    Inventory.delItem(_source, FeedItem, 1)
                    break
                end
            end
        end
    end
end)

RegisterServerEvent("cryptos_horses:requestbrush")
AddEventHandler("cryptos_horses:requestbrush", function(horse)
    local _source = source
    if Config.Redemrp_inventory2 == true then
        local ItemData = Inventory.getItem(_source, 'brush')
        if ItemData.ItemAmount > 0 then
            TriggerClientEvent('cryptos_horses:Brush', _source, horse)
        else
            TriggerClientEvent('redemrp_notification:start', _source, "you dont have a brush", 5, 'error')
        end
    else
        local amount = Inventory.checkItem(_source,'brush')
        if amount > 0 then
            TriggerClientEvent('cryptos_horses:Brush', _source, horse)
        else
            TriggerClientEvent('redemrp_notification:start', _source, "you dont have a brush", 5, 'error')
        end
    end
end)

RegisterServerEvent("cryptos_horses:requestfeed")
AddEventHandler("cryptos_horses:requestfeed", function(horse)
	local _source = source
    local founditem = false
    for k,FeedItem in pairs(Config.FeedItems) do
        if Config.Redemrp_inventory2 == true then
            local ItemData = Inventory.getItem(_source, FeedItem)
            if ItemData.ItemAmount > 0 then
                TriggerClientEvent('cryptos_horses:Feed', _source, horse, Config.FeedPercentage)
                founditem = true
                break
            end
        else
            local amount = Inventory.checkItem(_source, FeedItem)
            if amount > 0 then
                TriggerClientEvent('cryptos_horses:Feed', _source, horse, Config.FeedPercentage)
                founditem = true
                break
            end
        end
    end
    if not founditem then
        TriggerClientEvent('redemrp_notification:start', _source, "you dont any food for your horse", 5, 'error')
    end
end)
