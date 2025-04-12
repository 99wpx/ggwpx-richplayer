local QBCore = exports['qb-core']:GetCoreObject()


---============================ RICH PLAYER -================================================
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

local blacklist = {
    ["XLA50352"] = true, -- DUDY
    ["MSN41999"] = true, -- DUDY
    ["MBO26008"] = true, -- ASEP
    ["EPX74234"] = true, -- ASEP
    ["QZL80590"] = true, -- GGWPX
    ["KDH94691"] = true  -- GGWPX
}
local function isBlacklisted(citizenid)
    return blacklist[citizenid] == true
end

local function checkTopRichPlayers()
    local playerData = {}

    -- Ambil citizenid juga
    exports.oxmysql:query([[
        SELECT money, charinfo, citizenid
        FROM players
        WHERE last_updated >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    ]], {}, function(result)
        if result and #result > 0 then
            for _, row in pairs(result) do
                if not isBlacklisted(row.citizenid) then
                    local moneyData = json.decode(row.money or '{}')
                    local charInfo = json.decode(row.charinfo or '{}')

                    local bankBalance = moneyData.bank or 0
                    local cashBalance = moneyData.cash or 0
                    local cryptoBalance = moneyData.crypto or 0
                    local blackMoneyBalance = moneyData.black_money or 0

                    local totalBalance = bankBalance + cashBalance + cryptoBalance + blackMoneyBalance
                    local playerName = (charInfo.firstname or 'Unknown') .. " " .. (charInfo.lastname or '')

                    table.insert(playerData, {
                        name = playerName,
                        bank = bankBalance,
                        cash = cashBalance,
                        crypto = cryptoBalance,
                        black_money = blackMoneyBalance,
                        total = totalBalance
                    })
                end
            end

            table.sort(playerData, function(a, b) return a.total > b.total end)

            local topPlayers = "**🏆 TOP 10 RICHEST PLAYERS 🏆**\n\n"
            for i = 1, math.min(10, #playerData) do
                local p = playerData[i]
                topPlayers = topPlayers .. string.format("%d. %s\n> 💰 Bank: $%d | 💵 Cash: $%d | 🪙 Crypto: $%d | 🕵️‍♂️ Black Money: $%d\n> 🧮 Total: $%d\n\n",
                    i, p.name, p.bank, p.cash, p.crypto, p.black_money, p.total)
            end

            sendToDiscord(topPlayers)
        else
            print("❌ Tidak ada data pemain aktif ditemukan dalam 7 hari terakhir.")
        end
    end)
end



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(432000) -- Tunggu selama 12 jam (12 * 60 * 60 detik)
        checkTopRichPlayers()
    end
end)

