ESX = nil

-- Ensure ESX is loaded
TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

TriggerEvent('es:addAdminCommand', 'setwarn', 5, function(source, args, user)
    -- Validate input
    if not args[1] then
        return TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Usage: /setwarn [SteamHex] [Warn Text]")
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local steamHex = args[1]
    local warningText = table.concat(args, ' ', 2)

    -- Check Baraye Steam Hex Sahi
    if not string.find(steamHex, "steam:") then
        return TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Steam Bayad Ba steam: Shoro Shavad")
    end

    if not xPlayer then
        return TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Failed to get player data, try again later.")
    end

    -- Get Admin Name
    local adminName = GetPlayerName(source)
    if not adminName then
        return TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Failed to get admin's name, try again later.")
    end

    -- Database interaction
    Citizen.CreateThread(function()
        -- Check if player exists in users table
        MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
            ['@identifier'] = steamHex
        }, function(userData)
            if #userData == 0 then
                -- Player not found, send error
                return TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Steam Hex Eshtebah Ast !")
            end

            -- Check if warning exists
            MySQL.Async.fetchAll('SELECT * FROM setwarn WHERE identifier = @identifier', {
                ['@identifier'] = steamHex
            }, function(existingWarn)
                if warningText == "" then
                    if #existingWarn == 0 then
                        return TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Matn Nemitavanad Khali Bashad !")
                    else
                        -- Delete Kardane Warn
                        MySQL.Async.execute('DELETE FROM setwarn WHERE identifier = @identifier', {
                            ['@identifier'] = steamHex
                        }, function(affectedRows)
                            if affectedRows > 0 then
                                TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Warn Remove Shod")
                            else
                                TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Error #1")
                            end
                        end)
                    end
                else
                    if #existingWarn > 0 then
                        -- Update Kardane warning
                        MySQL.Async.execute('UPDATE setwarn SET note = @note, admin = @admin, created_at = @created_at WHERE identifier = @identifier', {
                            ['@identifier'] = steamHex,
                            ['@note'] = warningText,
                            ['@admin'] = adminName,
                            ['@created_at'] = os.date('%Y-%m-%d %H:%M:%S')
                        }, function(affectedRows)
                            if affectedRows > 0 then
                                TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Warn Set Shod")
                            else
                                TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Error #2")
                            end
                        end)
                    else
                        -- Set Kardane Warn Jadid
                        MySQL.Async.execute('INSERT INTO setwarn (identifier, note, admin, created_at) VALUES (@identifier, @note, @admin, @created_at)', {
                            ['@identifier'] = steamHex,
                            ['@note'] = warningText,
                            ['@admin'] = adminName,
                            ['@created_at'] = os.date('%Y-%m-%d %H:%M:%S')
                        }, function(affectedRows)
                            if affectedRows > 0 then
                                TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Warn Set Shod")
                            else
                                TriggerClientEvent('chatMessage', source, "[Setwarn]", {255, 0, 0}, "Error #3")
                            end
                        end)
                    end
                end
            end)
        end)
    end)
end, function(source, args, user)
    -- Permission denied handler
    TriggerClientEvent('chat:addMessage', source, { 
        color = {255, 0, 0},
        args = { '[System]', 'Permission Estefade Az In Command Ra Nadarid !' } 
    })
end, {
    help = "Setwarn a Player", 
    params = {
        {name = "SteamHex", help = "Player SteamHex"}, 
        {name = "Warning", help = "Matne Warn / Khalai Begzarid Baraye Remove"}
    }
})


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        MySQL.Async.fetchAll('SELECT identifier, note, admin FROM setwarn', {}, function(warnedPlayers)
            if warnedPlayers and #warnedPlayers > 0 then
                for _, xPlayerId in pairs(ESX.GetPlayers()) do
                    local xPlayer = ESX.GetPlayerFromId(xPlayerId)
                    if xPlayer and tonumber(xPlayer.permission_level) > 0 then
                        for _, warnData in pairs(warnedPlayers) do
                            local warnedPlayer = ESX.GetPlayerFromIdentifier(warnData.identifier)
                            if warnedPlayer then
                                TriggerClientEvent('chat:addMessage', xPlayer.source, {
                                    color = {255, 0, 0},
                                    args = {"[Setwarn]", GetPlayerName(warnedPlayer.source).. "(^5" ..warnedPlayer.source.. "^0) ^3" ..warnData.note.. "^0 (" ..warnData.admin.. "^0)"}
                                })
                            end
                        end
                    end
                end
            end
        end)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        MySQL.Async.fetchAll('SELECT hwid FROM banlist', {}, function(bannedHWIDs)
            if bannedHWIDs and #bannedHWIDs > 0 then
                local validHWIDs = {}

                for _, hwidData in pairs(bannedHWIDs) do
                    if hwidData and hwidData.hwid and hwidData.hwid ~= "" then
                        table.insert(validHWIDs, hwidData.hwid)
                    end
                end

                for _, playerId in pairs(ESX.GetPlayers()) do
                    local xPlayer = ESX.GetPlayerFromId(playerId)
                    if xPlayer then
                        local playerHWIDs = {}

                        for i = 0, 5 do
                            local hwid = GetPlayerToken(xPlayer.source, i)
                            if hwid then
                                table.insert(playerHWIDs, hwid)
                            end
                        end

                        local isBanned = false
                        for _, playerHWID in pairs(playerHWIDs) do
                            local formattedPlayerHWID = string.sub(playerHWID, 3)

                            for _, bannedHWID in pairs(validHWIDs) do
                                local formattedBannedHWID = string.sub(bannedHWID, 3)

                                if formattedPlayerHWID == formattedBannedHWID then
                                    isBanned = true
                                    break
                                end
                            end

                            if isBanned then
                                for _, adminId in pairs(ESX.GetPlayers()) do
                                    local admin = ESX.GetPlayerFromId(adminId)
                                    if admin and tonumber(admin.permission_level) > 0 then
                                        TriggerClientEvent('chat:addMessage', admin.source, {
                                            color = {255, 0, 0},
                                            args = {
                                                "[Anti Cheat]",
                                                GetPlayerName(xPlayer.source).. "(^5" ..xPlayer.source.. "^0) Mashkuk Be Spoofer"
                                            }
                                        })

                                        local alertMessage = GetPlayerName(xPlayer.source).. "(" ..xPlayer.source.. ") Mashkuk Be Spoofer"
                                        SendDiscordWebhook(alertMessage)

                                    end
                                end

                                break
                            end
                        end
                    end
                end
            else
                print("Arad AC : Spoofer = 0")
            end
        end)
    end
end)

function SendDiscordWebhook(message)
    local webhookURL = "Your_Discord_Webhook_URL_Here" -- Replace with your actual webhook URL

    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = "Arad AC",
        embeds = {{
            title = "Spoofer Alert 🚨",
            description = message,
            color = 16711680
        }}
    }), { ['Content-Type'] = 'application/json' })
end


-- Create Database 
-- ================================================================================
-- ================================================================================


-- CREATE TABLE IF NOT EXISTS `setwarn` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `identifier` varchar(255) NOT NULL,
--   `note` text DEFAULT NULL,
--   `admin` varchar(255) DEFAULT NULL,
--   `created_at` datetime DEFAULT NULL,
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;






-- Coded by Aяad : https://github.com/aradashkan