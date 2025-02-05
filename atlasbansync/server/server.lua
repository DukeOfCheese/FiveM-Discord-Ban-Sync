local function GetDiscordID(player)
    local playerDiscord = GetPlayerIdentifierByType(player, 'discord')
    if playerDiscord then
        local id = playerDiscord:match('discord:(%d+)')
        return id or nil
    end
    return nil
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update('[Atlas Ban Sync] Checking if you are banned in the linked Discord...')
    local src = source
    local discordId = GetDiscordID(src)
    if not discordId then
        if Config.RequireDiscordToJoin then
            deferrals.done()
        else
            deferrals.done('[Atlas Ban Sync] You are required to have a connected Discord account to join this server!')
        end
    else
        PerformHttpRequest('https://discord.com/api/v10/guilds/' .. Config.GuildID .. '/bans/' .. discordId, function(errorCode, resultData, resultHeaders)
            print("Error Code: ".. errorCode)
            if errorCode == 200 then
                deferrals.done('[Atlas Ban Sync] ' .. Config.BanMessage)
            else
                deferrals.done()
            end
        end,
        'GET',
        '',
        {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bot " .. Config.Token
        })
    end
end)
