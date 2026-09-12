-- FiveM Vehicle Car Menü Script
-- Main Client File mit Datenbank Support

local menuOpen = false
local musicMenuOpen = false
local currentMusic = nil
local savedMusic = {}

-- Menü öffnen mit N Taste
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        -- N Taste zum Öffnen des Menüs
        if IsControlJustReleased(0, 249) then -- N Taste
            if not menuOpen and IsPedInAnyVehicle(PlayerPedId(), false) then
                OpenCarMenu()
            elseif menuOpen then
                CloseCarMenu()
            end
        end
        
        -- Ö Taste zum Öffnen des Musik-Menüs (wenn im Menü)
        if menuOpen and IsControlJustReleased(0, 246) then -- Ö Taste
            if not musicMenuOpen then
                OpenMusicMenu()
            else
                CloseMusicMenu()
            end
        end
        
        -- U Taste zum Schließen (wenn im Menü)
        if (menuOpen or musicMenuOpen) and IsControlJustReleased(0, 303) then -- U Taste
            CloseMusicMenu()
            CloseCarMenu()
        end
    end
end)

function OpenCarMenu()
    menuOpen = true
    
    -- Gespeicherte Musik laden
    TriggerServerEvent('carMenu:loadSavedMusic')
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"Car Menü", "Menü geöffnet! Drücke Ö für Musik-Menü, U zum Schließen"}
    })
    
    -- Sound abspielen
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
end

function CloseCarMenu()
    menuOpen = false
    musicMenuOpen = false
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Car Menü", "Menü geschlossen!"}
    })
    
    -- Sound abspielen
    PlaySoundFrontend(-1, "CANCEL_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
end

function OpenMusicMenu()
    musicMenuOpen = true
    TriggerEvent('chat:addMessage', {
        color = {0, 100, 255},
        multiline = true,
        args = {"Musik Menü", "Gebe einen YouTube Link ein..."}
    })
    
    -- Sound abspielen
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
    
    -- NUI zeigen mit gespeicherten Links
    SendNUIMessage({
        type = 'openMusicMenu',
        savedMusic = savedMusic
    })
    SetNuiFocus(true, true)
end

function CloseMusicMenu()
    musicMenuOpen = false
    
    -- NUI verstecken
    SendNUIMessage({
        type = 'closeMusicMenu'
    })
    SetNuiFocus(false, false)
    
    -- Sound abspielen
    PlaySoundFrontend(-1, "CANCEL_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
end

-- NUI Callbacks von der HTML Seite empfangen
RegisterNuiCallbackType('musicSubmit')
on_submitMusic = function(data, cb)
    if data.youtubeLink and data.youtubeLink ~= "" then
        currentMusic = data.youtubeLink
        
        -- In Datenbank speichern
        TriggerServerEvent('carMenu:saveMusic', data.youtubeLink)
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Musik", "Musiklink hinzugefügt und gespeichert: " .. data.youtubeLink}
        })
        
        -- Musik starten
        SendNUIMessage({
            type = 'playMusic',
            link = data.youtubeLink
        })
    end
    
    CloseMusicMenu()
    cb('ok')
end

-- Gespeicherte Musik vom Server empfangen
RegisterNetEvent('carMenu:receiveSavedMusic')
AddEventHandler('carMenu:receiveSavedMusic', function(music)
    savedMusic = music
    if #music > 0 then
        TriggerEvent('chat:addMessage', {
            color = {0, 200, 255},
            multiline = true,
            args = {"Musik", #music .. " gespeicherte Links geladen!"}
        })
    end
end)

-- Fahrzeug Sounds
function PlayVehicleSound(soundName)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        PlaySoundFrontend(-1, soundName, "CONFIRM_BEEP", true)
    end
end

-- Export für andere Scripts
exports('openCarMenu', function()
    OpenCarMenu()
end)

exports('closeCarMenu', function()
    CloseCarMenu()
end)

exports('playMusicMenu', function()
    if menuOpen then
        OpenMusicMenu()
    end
end)

exports('playMusicFromLink', function(link)
    PlayMusicFromLink(link)
end)

function PlayMusicFromLink(link)
    currentMusic = link
    SendNUIMessage({
        type = 'playMusic',
        link = link
    })
end
