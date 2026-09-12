-- FiveM Vehicle Car Menü Script
-- Server File mit Datenbank Support

print("^2[Vehicle Car Menü] Server Script geladen!^7")

-- Datenbank initialisieren (MySQL/Async)
local function initializeDatabase()
    -- Tabelle für gespeicherte Musik erstellen
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `car_menu_music` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `player_id` VARCHAR(50) NOT NULL,
            `player_name` VARCHAR(100),
            `youtube_link` VARCHAR(255) NOT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY `unique_link` (`player_id`, `youtube_link`),
            INDEX `player_idx` (`player_id`)
        )
    ]])
    
    print("^3[Vehicle Car Menü] Datenbank Tabelle erstellt/aktualisiert!^7")
end

-- Starte Datenbank Init beim Server-Start
Citizen.CreateThread(function()
    Wait(1000)
    initializeDatabase()
end)

-- Musik speichern in Datenbank
RegisterServerEvent('carMenu:saveMusic')
AddEventHandler('carMenu:saveMusic', function(youtubeLink)
    local source = source
    local player = GetPlayer(source)
    
    if not player then
        print("^1[Vehicle Car Menü] Player " .. source .. " nicht gefunden!^7")
        return
    end
    
    local playerId = player.identifier
    local playerName = player.name
    
    -- Musik in Datenbank speichern
    MySQL.Async.execute(
        'INSERT INTO car_menu_music (player_id, player_name, youtube_link) VALUES (@player_id, @player_name, @youtube_link) ON DUPLICATE KEY UPDATE updated_at = NOW()',
        {
            ['@player_id'] = playerId,
            ['@player_name'] = playerName,
            ['@youtube_link'] = youtubeLink
        },
        function(rowsChanged)
            print("^2[Vehicle Car Menü] Musik von " .. playerName .. " (" .. playerId .. ") gespeichert: " .. youtubeLink .. "^7")
            
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"✓ Gespeichert", "Dein Musik-Link wurde in der Datenbank gespeichert!"}
            })
        end
    )
end)

-- Gespeicherte Musik laden
RegisterServerEvent('carMenu:loadSavedMusic')
AddEventHandler('carMenu:loadSavedMusic', function()
    local source = source
    local player = GetPlayer(source)
    
    if not player then return end
    
    local playerId = player.identifier
    
    MySQL.Async.fetchAll(
        'SELECT youtube_link FROM car_menu_music WHERE player_id = @player_id ORDER BY updated_at DESC LIMIT 10',
        {
            ['@player_id'] = playerId
        },
        function(results)
            local musicLinks = {}
            
            if results then
                for i, row in ipairs(results) do
                    table.insert(musicLinks, row.youtube_link)
                end
            end
            
            -- An Client zurückschicken
            TriggerClientEvent('carMenu:receiveSavedMusic', source, musicLinks)
            
            if #musicLinks > 0 then
                print("^3[Vehicle Car Menü] " .. #musicLinks .. " gespeicherte Links für " .. player.name .. " geladen!^7")
            end
        end
    )
end)

-- Musik löschen
RegisterServerEvent('carMenu:deleteMusic')
AddEventHandler('carMenu:deleteMusic', function(youtubeLink)
    local source = source
    local player = GetPlayer(source)
    
    if not player then return end
    
    local playerId = player.identifier
    
    MySQL.Async.execute(
        'DELETE FROM car_menu_music WHERE player_id = @player_id AND youtube_link = @youtube_link',
        {
            ['@player_id'] = playerId,
            ['@youtube_link'] = youtubeLink
        },
        function(rowsChanged)
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 100, 0},
                multiline = true,
                args = {"🗑️ Gelöscht", "Musik-Link wurde gelöscht!"}
            })
        end
    )
end)

-- Alle Musik eines Spielers löschen
RegisterServerEvent('carMenu:deleteAllMusic')
AddEventHandler('carMenu:deleteAllMusic', function()
    local source = source
    local player = GetPlayer(source)
    
    if not player then return end
    
    local playerId = player.identifier
    
    MySQL.Async.execute(
        'DELETE FROM car_menu_music WHERE player_id = @player_id',
        {
            ['@player_id'] = playerId
        },
        function(rowsChanged)
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"🗑️ Alle gelöscht", "Alle Musik-Links wurden gelöscht!"}
            })
        end
    )
end)

-- Hilfsfunktion: Player Info laden
function GetPlayer(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    if not identifiers or #identifiers == 0 then
        return nil
    end
    
    return {
        identifier = identifiers[1],
        name = GetPlayerName(source),
        source = source
    }
end

-- Admin Command: Musik List anzeigen
RegisterCommand('carmusic', function(source, args, rawCommand)
    if source == 0 then
        print("Console - Dieser Befehl ist nur für Spieler!")
        return
    end
    
    local subcommand = args[1]
    
    if subcommand == "list" then
        local player = GetPlayer(source)
        MySQL.Async.fetchAll(
            'SELECT youtube_link, created_at FROM car_menu_music WHERE player_id = @player_id ORDER BY updated_at DESC',
            {
                ['@player_id'] = player.identifier
            },
            function(results)
                local message = "^3=== Deine gespeicherten Musik Links ===^7\n"
                
                if results and #results > 0 then
                    for i, row in ipairs(results) do
                        message = message .. i .. ". " .. row.youtube_link .. "\n"
                    end
                else
                    message = message .. "Keine Links gespeichert!"
                end
                
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 150, 255},
                    multiline = true,
                    args = {"Musik Liste", message}
                })
            end
        )
    elseif subcommand == "clear" then
        TriggerEvent('carMenu:deleteAllMusic', source)
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"Hilfe", "/carmusic list - Zeige alle Links | /carmusic clear - Lösche alle"}
        })
    end
end)

-- Info Messages
print("^2[Vehicle Car Menü] Server bereit!^7")
print("^3Commands:^7")
print("^3/carmusic list^7 - Zeige alle gespeicherten Links")
print("^3/carmusic clear^7 - Lösche alle Links")
