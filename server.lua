local QBCore = exports['qb-core']:GetCoreObject()
local discordWebhookUrl = "CHANGEME"

local function sendToDiscord(message)
    local embed = {
        {
            ["color"] = 3447003, 
            ["title"] = "Richest Players Update",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "INI DUNIA ROLEPLAY",
            },
        }
    }

    PerformHttpRequest(discordWebhookUrl, function(err, text, headers) end, 'POST', json.encode({username = "OTT KPK", embeds = embed}), {['Content-Type'] = 'application/json'})
end

local function checkTopRichPlayers()
    local playerData = {}

    exports.oxmysql:query([[
        SELECT players.money, players.charinfo
        FROM players
    ]], {}, function(result)
        if result then
            for _, row in pairs(result) do
                local moneyData = json.decode(row.money) or {}
                local charInfo = json.decode(row.charinfo) or {}

                local bankBalance = moneyData.bank or 0
                local cashBalance = moneyData.cash or 0
                local cryptoBalance = moneyData.crypto or 0
                local blackMoneyBalance = moneyData.black_money or 0

                local totalBalance = bankBalance + cashBalance + cryptoBalance + blackMoneyBalance

                local playerName = (charInfo.firstname or '') .. " " .. (charInfo.lastname or '')

                table.insert(playerData, {
                    name = playerName,  
                    bank = bankBalance,
                    cash = cashBalance,
                    crypto = cryptoBalance,
                    black_money = blackMoneyBalance,
                    total = totalBalance
                })
            end

            table.sort(playerData, function(a, b)
                return a.total > b.total
            end)

            local topPlayers = "****\n"
            local count = math.min(10, #playerData)  
            for i = 1, count do
                topPlayers = topPlayers .. string.format("%d. %s - Bank: $%d, Cash: $%d, Crypto: $%d, Black Money: $%d, Total: $%d\n", 
                    i, 
                    playerData[i].name, 
                    playerData[i].bank, 
                    playerData[i].cash, 
                    playerData[i].crypto, 
                    playerData[i].black_money, 
                    playerData[i].total
                )
            end
            sendToDiscord(topPlayers)
        else
            print("Error: Tidak ada data pemain ditemukan!")
        end
    end)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Tunggu selama 1 menit
        checkTopRichPlayers()
    end
end)
