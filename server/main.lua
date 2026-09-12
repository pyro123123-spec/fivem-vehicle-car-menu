-- FiveM Vehicle Car Menü Script
-- Server File

print("^2[Vehicle Car Menü] Script geladen!^7")

-- Event Listener für Client Events
RegisterServerEvent('carMenu:playerEnteredVehicle')
AddEventHandler('carMenu:playerEnteredVehicle', function()
    local source = source
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 150, 255},
        multiline = true,
        args = {"Vehicle Menü", "Du bist in einem Fahrzeug! Drücke N zum Öffnen des Menüs"}
    })
end)

-- Spieler Info
RegisterCommand('carmenu', function(source, args, rawCommand)
    if source == 0 then
        print("^3[Vehicle Car Menü] Dieser Befehl kann nur von Spielern verwendet werden!^7")
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            multiline = true,
            args = {"Info", "Verwende N um das Fahrzeug Menü zu öffnen!"}
        })
    end
end)

-- Server Callback für Musik
RegisterServerEvent('carMenu:musicStarted')
AddEventHandler('carMenu:musicStarted', function(link)
    local source = source
    print("^2[Vehicle Car Menü] Spieler " .. source .. " hat Musik gestartet: " .. link .. "^7")
end)

-- Info Command
print("^2[Vehicle Car Menü] Tasten:^7")
print("^3N^7 - Fahrzeug Menü öffnen")
print("^3Ö^7 - Musik Menü öffnen (wenn im Menü)")
print("^3U^7 - Menü schließen")
