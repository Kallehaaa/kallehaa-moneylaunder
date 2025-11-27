ESX = exports["es_extended"]:getSharedObject()

local cfg = {
    laundering_percentage = {
        {threshold = 10000000, percentage = 0.326}, -- Over 10 millioner: 32.6%
        {threshold = 5000000, percentage = 0.382},  -- Op til 10 millioner: 38.2%
        {threshold = 2000000, percentage = 0.438},  -- Op til 5 millioner: 43.8%
        {threshold = 1000000, percentage = 0.48},   -- Op til 2 millioner: 48%
        {threshold = 500000, percentage = 0.508}    -- Op til 1 million: 50.8%
    }
}

local webhookUrl = "WEBHOOK"

local function getLaunderingPercentage(amount)
    for i = 1, #cfg.laundering_percentage do
        local v = cfg.laundering_percentage[i]
        if amount >= v.threshold then
            return v.percentage
        end
    end
    return cfg.laundering_percentage[#cfg.laundering_percentage].percentage
end

local function sendToDiscord(name, message)
    local data = {
        username = "Hvidvask",
        embeds = {{
            title = "Hvidvask",
            description = message,
            color = 15258703
        }}
    }
    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode(data), {['Content-Type'] = 'application/json'})
end

RegisterServerEvent('kallelaunder')
AddEventHandler('kallelaunder', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local dirty_money = exports.ox_inventory:Search(source, 'count', 'black_money') or 0

        if amount <= 0 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = "Fejl",
                description = "Ugyldig mængde.",
                type = "error",
                duration = 5000
            })
            return
        end

        if dirty_money >= amount then
            local percentage = getLaunderingPercentage(amount)
            local laundered_money = amount * (1 - percentage)
            exports.ox_inventory:RemoveItem(source, 'black_money', amount)
            xPlayer.addMoney(math.floor(laundered_money))

            sendToDiscord(xPlayer.getName(), string.format("%s hvidvaskede %d og modtog %d, hvilket svarer til en procent på %.2f%%", xPlayer.getName(), math.floor(amount), math.floor(laundered_money), percentage * 100))

            TriggerClientEvent('ox_lib:notify', source, {
                title = "Hvidvask Succes",
                description = "Du har hvidvasket " .. math.floor(laundered_money) .. " ud af " .. math.floor(amount),
                type = "success",
                duration = 5000
            })
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = "Fejl",
                description = "Du har ikke nok sorte penge til at hvidvaske dette beløb.",
                type = "error",
                duration = 5000
            })
            sendToDiscord(xPlayer.getName(), string.format("%s forsøgte at hvidvaske %d men havde kun %d sorte penge", xPlayer.getName(), math.floor(amount), dirty_money))
        end
    else
        sendToDiscord("Ukendt Spiller", "En ukendt spiller forsøgte at udføre en hvidvaskning.")
    end
end)
