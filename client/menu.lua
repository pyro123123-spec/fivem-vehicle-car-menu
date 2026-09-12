-- FiveM Vehicle Car Menü Script
-- Menu Handler

-- Menü Struktur
local carMenu = {
    {
        label = "🎵 Musik abspielen",
        icon = "🎵",
        description = "Musik über YouTube Link abspielen",
        action = "openMusic"
    },
    {
        label = "🔊 Sound Test",
        icon = "🔊",
        description = "Teste verschiedene Sounds",
        action = "soundTest"
    },
    {
        label = "🚗 Fahrzeug Info",
        icon = "🚗",
        description = "Informationen über das Fahrzeug",
        action = "vehicleInfo"
    },
    {
        label = "❌ Menü schließen",
        icon = "❌",
        description = "Schließe das Menü",
        action = "closeMenu"
    }
}

-- Menü Aktionen
function HandleMenuAction(action)
    if action == "openMusic" then
        OpenMusicMenu()
    elseif action == "soundTest" then
        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Sound Test", "Beep!"}
        })
    elseif action == "vehicleInfo" then
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            local speed = GetEntitySpeed(vehicle)
            TriggerEvent('chat:addMessage', {
                color = {0, 150, 255},
                multiline = true,
                args = {"Fahrzeug Info", "Modell: " .. model .. " | Geschwindigkeit: " .. math.floor(speed * 3.6) .. " km/h"}
            })
        end
    elseif action == "closeMenu" then
        CloseCarMenu()
    end
end

-- Menü Aufruf (wird in main.lua aufgerufen)
function DisplayCarMenu()
    local menuString = "\n"
    menuString = menuString .. "════════════════════════\n"
    menuString = menuString .. "    🚗 VEHICLE MENÜ 🚗\n"
    menuString = menuString .. "════════════════════════\n\n"
    
    for i, item in ipairs(carMenu) do
        menuString = menuString .. "[" .. i .. "] " .. item.label .. "\n"
        menuString = menuString .. "    " .. item.description .. "\n\n"
    end
    
    menuString = menuString .. "════════════════════════\n"
    menuString = menuString .. "[Ö] Musik Menü öffnen\n"
    menuString = menuString .. "[U] Menü schließen\n"
    menuString = menuString .. "════════════════════════\n"
    
    TriggerEvent('chat:addMessage', {
        color = {255, 200, 0},
        multiline = true,
        args = {"Menü", menuString}
    })
end

-- Export
exports('handleMenuAction', function(action)
    HandleMenuAction(action)
end)
