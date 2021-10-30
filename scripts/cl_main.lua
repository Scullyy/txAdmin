-- =============================================
--  ServerCtx Synchronization
-- =============================================
ServerCtx = false

-- NOTE: for now the ServerCtx is only being set when the menu tries to load (enabled or not)
--- Will update ServerCtx based on GlobalState and will send it to NUI
function updateServerCtx()
    _ServerCtx = GlobalState.txAdminServerCtx
    if _ServerCtx == nil then
        debugPrint('^3ServerCtx fallback support activated')
        TriggerServerEvent('txAdmin:events:getServerCtx')
    else
        ServerCtx = _ServerCtx
        ServerCtx.endpoint = GetCurrentServerEndpoint()
        debugPrint('^2ServerCtx updated from global state')
    end
end

RegisterNetEvent('txAdmin:events:setServerCtx', function(ctx)
    if type(ctx) ~= 'table' then return end
    ServerCtx = ctx
    ServerCtx.endpoint = GetCurrentServerEndpoint()
    debugPrint('^2ServerCtx updated from server event')
end)

RegisterNUICallback('getServerCtx', function(_, cb)
    CreateThread(function()
        updateServerCtx()
        while ServerCtx == false do Wait(0) end
        debugPrint('Server CTX:')
        debugPrint(json.encode(ServerCtx))
        cb(ServerCtx)
    end)
end)


-- =============================================
--  Warn & Announcement handling
-- =============================================
-- Dispatch Announcements
RegisterNetEvent('txAdmin:receiveAnnounce', function(message)
    sendMenuMessage('addAnnounceMessage', { message = message })
end)

-- TODO: remove [SPACE] holding requirement?
local isRDR = not TerraingridActivate and true or false
local dismissKey = isRDR and 0xD9D0E1C0 or 22
local dismissKeyGroup = isRDR and 1 or 0
RegisterNetEvent('txAdminClient:warn', function(author, reason)
    sendMenuMessage('setWarnOpen', {
        reason = reason,
        warnedBy = author
    })
    CreateThread(function()
        local countLimit = 100 --10 seconds
        local count = 0
        while true do
            Wait(100)
            if IsControlPressed(dismissKeyGroup, dismissKey) then
                count = count +1
                if count >= countLimit then
                    sendMenuMessage('closeWarning')
                    return
                elseif math.fmod(count, 10) == 0 then
                    sendMenuMessage('pulseWarning')
                end
            else
                count = 0
            end
        end
    end)
end)


-- =============================================
--  Other stuff
-- =============================================
-- Removing unwanted chat suggestions
-- We only want suggestion for: /tx, /txAdmin-debug, /txAdmin-reauth
-- The suggestion is added after 500ms, so we need to wait more
CreateThread(function()
    Wait(1000)
    TriggerEvent('chat:removeSuggestion', '/txadmin') --too spammy
    TriggerEvent('chat:removeSuggestion', '/txaPing')
    TriggerEvent('chat:removeSuggestion', '/txaWarnID')
    TriggerEvent('chat:removeSuggestion', '/txaKickAll')
    TriggerEvent('chat:removeSuggestion', '/txaKickID')
    TriggerEvent('chat:removeSuggestion', '/txaDropIdentifiers')
    TriggerEvent('chat:removeSuggestion', '/txaBroadcast')
    TriggerEvent('chat:removeSuggestion', '/txaEvent')
    TriggerEvent('chat:removeSuggestion', '/txaSendDM')
    TriggerEvent('chat:removeSuggestion', '/txaReportResources')
    TriggerEvent('chat:removeSuggestion', '/txAdmin:menu:noClipToggle')
    TriggerEvent('chat:removeSuggestion', '/txAdmin:menu:endSpectate')
    TriggerEvent('chat:removeSuggestion', '/txAdmin-version')
    TriggerEvent('chat:removeSuggestion', '/txAdmin-locale')
    TriggerEvent('chat:removeSuggestion', '/txAdmin-verbose')
    TriggerEvent('chat:removeSuggestion', '/txAdmin-apiHost')
    TriggerEvent('chat:removeSuggestion', '/txAdmin-apiToken')
    TriggerEvent('chat:removeSuggestion', '/txAdmin-checkPlayerJoin')
    TriggerEvent('chat:removeSuggestion', '/txAdmin-pipeToken')
    TriggerEvent('chat:removeSuggestion', '/txAdminServerMode')
    TriggerEvent('chat:removeSuggestion', '/txAdminMenu-debugMode')
    TriggerEvent('chat:removeSuggestion', '/txEnableMenuBeta')
end)

