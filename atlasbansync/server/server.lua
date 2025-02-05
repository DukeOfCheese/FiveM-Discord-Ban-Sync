local function GetDiscordID(player)
    local discord = GetPlayerIdentifierByType(player, 'discord')
    if discord then
        local id = discord:gsub('discord:', '')
        return id
    end

    return nil
end

local function IsBanned(discordId, callback)
    PerformHttpRequest('https://discord.com/api/v10/guilds/' .. Config.bot.guild .. '/bans/' .. discordId, function(errorCode, resultData, resultHeaders)
        callback(errorCode >= 200 and errorCode < 300)
    end, 'GET', '', {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bot " .. Config.bot.token
    })
end

AddEventHandler('playerConnecting', function(_, _, deferrals)
    deferrals.defer()
    deferrals.update('[Atlas Ban Sync] Checking if you are banned in the linked Discord...')
    local id = GetDiscordID(source)
    if not id then
        if not Config.misc.requireDiscordToJoin then
            deferrals.done()
        else
            deferrals.done('[Atlas Ban Sync] You are required to have a connected Discord account to join this server!')
        end
    else
        IsBanned(id, function(isBanned)
            if isBanned then
                deferrals.done('[Atlas Ban Sync] ' .. Config.misc.banMessage)
            else
                deferrals.done()
            end
        end)
    end
end)


