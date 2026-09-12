-- FiveM Vehicle Car Menü Script
-- Music Handler

local currentMusicLink = nil
local musicPlaying = false

-- Musik Menü Handler
function PlayMusicFromLink(youtubeLink)
    if youtubeLink and youtubeLink ~= "" then
        currentMusicLink = youtubeLink
        musicPlaying = true
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"🎵 Musik", "Musik wird abgespielt!"}
        })
        
        -- Sound abspielen
        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
        
        -- NUI Message senden
        SendNUIMessage({
            type = 'playMusic',
            link = youtubeLink
        })
    end
end

function StopMusic()
    if musicPlaying then
        musicPlaying = false
        currentMusicLink = nil
        
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"🎵 Musik", "Musik gestoppt!"}
        })
        
        SendNUIMessage({
            type = 'stopMusic'
        })
    end
end

-- Verschiedene Sound Presets
local soundPresets = {
    {name = "Notification", set = "HUD_MINI_GAME_SOUNDSET", sound = "CONFIRM_BEEP"},
    {name = "Error", set = "HUD_MINI_GAME_SOUNDSET", sound = "CANCEL_BEEP"},
    {name = "Success", set = "CONFIRM_BEEP", sound = "CONFIRM_BEEP"},
}

function PlayPresetSound(index)
    if soundPresets[index] then
        local preset = soundPresets[index]
        PlaySoundFrontend(-1, preset.sound, preset.set, true)
    end
end

-- Export Funktionen
exports('playMusicFromLink', function(link)
    PlayMusicFromLink(link)
end)

exports('stopMusic', function()
    StopMusic()
end)

exports('playPresetSound', function(index)
    PlayPresetSound(index)
end)

exports('getCurrentMusic', function()
    return currentMusicLink
end)

exports('isMusicPlaying', function()
    return musicPlaying
end)
