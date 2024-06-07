QBCore = exports['qb-core']:GetCoreObject()

QBCore.Debug = true
QBCore.Commands.Add("creartienda", "Crea una nueva tienda", {
    {name = "nombre", help = "Nombre de la tienda"},
    {name = "precio", help = "Precio de la tienda"},
    {name = "job", help = "Trabajo asociado a la tienda"},
    {name = "grade", help = "Grado asociado al trabajo"},
    {name = "marcador_x", help = "Coordenada X del marcador"},
    {name = "marcador_y", help = "Coordenada Y del marcador"},
    {name = "marcador_z", help = "Coordenada Z del marcador"} 
}, true, function(source, args)
    -- Asigna los argumentos a variables locales
    local nombreTienda, precio, job, grade = args[1], (args[2]), args[3], (args[4])
    local marcadorX, marcadorY, marcadorZ = tonumber(args[5]), tonumber(args[6]), tonumber(args[7])
    
    -- Verifica que todos los argumentos estén presentes y sean válidos
    if nombreTienda and precio and job and grade and marcadorX and marcadorY and marcadorZ then
        -- Inserta los datos en la base de datos
        exports.oxmysql:insert('INSERT INTO tiendas (nombre, precio, job, grade_job, marcador_x, marcador_y, marcador_z, disponible) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {nombreTienda, precio, job, grade, marcadorX, marcadorY, marcadorZ, 1},
            function(insertedId)
                if insertedId then
                    -- Notifica al usuario que la tienda se creó correctamente
                    TriggerClientEvent('QBCore:Notify', source, 'Tienda creada correctamente', 'success')   
                else
                    -- Notifica al usuario si hubo un error al crear la tienda
                    TriggerClientEvent('QBCore:Notify', source, 'Error al crear la tienda', 'error')
                end
            end)
    else
        -- Notifica al usuario si no se proporcionaron argumentos suficientes o si son inválidos
        TriggerClientEvent('QBCore:Notify', source, 'Uso: /creartienda [nombre] [precio] [job] [grade] [marcador_x] [marcador_y] [marcador_z]', 'error')
    end -- <- Asegúrate de que el bloque else esté correctamente cerrado con 'end'
end) -- <- Asegúrate de que la función del comando esté correctamente cerrada con 'end'




QBCore.Commands.Add("borrartienda", "Borra una tienda por su ID", {{name="id_tienda", help="ID de la tienda"}}, true, function(source, args)
    local playerId = source
    local id_tienda = tonumber(args[1]) -- Convertir el argumento a número

    -- Verificar si el ID de la tienda es válido
    if not id_tienda then
        TriggerClientEvent('QBCore:Notify', source, 'ID no válido', 'error')
        return
    end

    exports.oxmysql:execute('DELETE FROM tiendas WHERE id_tienda = ?', {id_tienda}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', source, 'Tienda borrada exitosamente', 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Error al borrar la tienda', 'error')
        end
    end, function(rowsChanged)
        if rowsChanged == 0 then
            TriggerClientEvent('QBCore:Notify', source, 'La tienda con el ID proporcionado no existe', 'error')
        end
    end)
end)


-- Evento para comprar una tienda-- Evento para comprar una tienda-- Evento para comprar una tienda-- Evento para comprar una tienda

function SendNotification(playerId, message, type)
    TriggerClientEvent('chat:addMessage', playerId, {
        color = {124,252,0},
        multiline = true,
        args = {"[Notificación]", message}
    })        
    --implementar mas coles dependiendo de la notificación
end
RegisterCommand('testnotif', function(source, args)
    local playerId = source
    local message = "¡Hola! Esta es una notificación de prueba."
    SendNotification(playerId, message, 'info')
    TriggerClientEvent('QBCore:Notify', source, 'Tienda vendida exitosamente', 'success')

end, false)

RegisterCommand('comprartienda', function(source, args) 
    local playerId = source -- SI mandas por args automaticamente no te deja enviar valores nulos 
    local id_tienda = args[1] -- Supongo que args contiene el ID de la tienda
    local message = "¡Hola! Has seleccionado la tienda con ID: " .. id_tienda .. " y el propietario es: " ..playerId
    SendNotification(playerId, message, 'info')

    --VERFICAR QUE NO ESTA COMPRADA
 -- Verificar si la tienda está disponible en la base de datos
 exports.oxmysql:fetch('SELECT * FROM tiendas WHERE id_tienda = ? AND disponible = 1', {id_tienda}, function(result)
    if result and #result > 0 then
        
        -- La tienda está disponible
        local message = "La tienda con ID " .. id_tienda .. " está disponible para comprar."
        SendNotification(playerId, message, 'info')
        
    else
        -- La tienda no está disponible
        local message = "La tienda con ID " .. id_tienda .. " no está disponible para comprar."
        SendNotification(playerId, message, 'error')
    end
end)
end, false)



------------------------------------------------------------------------------------------------------------------------------------------------

-- Define una tabla para almacenar la información de las tiendas
local tiendasDisponibles = {}

Citizen.CreateThread(function()
    while true do
        -- Realiza la consulta a la base de datos para obtener tiendas disponibles
        exports.oxmysql:fetch("SELECT * FROM tiendas WHERE disponible = 1", {}, function(result)
            if result then
                -- Limpiar las tiendas disponibles antes de actualizarlas
                tiendasDisponibles = {}

                -- Itera sobre los resultados y agrega la información de cada tienda al diccionario
                -- Diccionario JSON 
                for _, row in ipairs(result) do
                    local tiendaInfo = {
                        id_tienda = row.id_tienda,
                        nombre = row.nombre,
                        marcador = row.marcador,
                        precio = row.precio,
                        marcador_x = row.marcador_x,
                        marcador_y = row.marcador_y,
                        marcador_z = row.marcador_z,
                        job = row.job,
                        grade_job = row.grade_job
                        
                    }
                    table.insert(tiendasDisponibles, tiendaInfo)
                    -- Imprime la información de la tienda encontrada
                    -- print("SERVER LUA : Información de la tienda", json.encode(tiendaInfo))
                end

                -- Envía la información de las tiendas disponibles al cliente
                TriggerClientEvent('tiendas:actualizarTiendas', -1, tiendasDisponibles)
            else
                print("Error al ejecutar la consulta SQL")
            end
        end)

        -- Espera un cierto tiempo antes de volver a consultar la base de datos
        Citizen.Wait(20 * 1000) -- 10 segundos en milisegundos
    end
end)

RegisterNetEvent('tiendas:actualizarTiendas')
AddEventHandler('tiendas:actualizarTiendas', function(tiendas)
    TriggerClientEvent('tiendas:actualizarTiendas', -1, tiendas)
end)



-- ------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('intentarComprarTienda')
AddEventHandler('intentarComprarTienda', function(playerName, tienda)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)
    local precioTienda = tonumber(tienda.precio) -- PRECIO PARA DESCONTAR
    local nombreTienda = tienda.nombre -- Nombre de la tienda
    local propietarioID = ply.PlayerData.citizenid --ID DEL CITIZEN PLAYER  
    --- try //execption when the grade and job is null thats important because i dont have a verification funcion in my database to check this value 09/04/2024
    local _job = tienda.job
    local _gradejob = tonumber(tienda.grade_job)    



    exports.oxmysql:fetch('SELECT money FROM players WHERE name = ?', {playerName}, function(result)
        if result[1] then
            local playerData = result[1]             
            local moneyData = json.decode(playerData.money) -- Decodificar el JSON
            local dineroEnBanco = tonumber(moneyData.bank) -- Obtener el dinero en el banco

            if dineroEnBanco >= precioTienda then
                TriggerClientEvent('QBCore:Notify', src, 'Se ha comprado la tienda correctamente', 'success')
                ply.Functions.RemoveMoney('bank', precioTienda)
                ply.Functions.SetJob(_job,_gradejob)

                
                exports.oxmysql:execute('UPDATE tiendas SET disponible = 0 WHERE nombre = ?', {nombreTienda}, function(result)
                    if result then
                        -- La consulta se ejecutó correctamente
                        exports.oxmysql:execute('UPDATE tiendas SET propietario = ? WHERE nombre = ?', {propietarioID, nombreTienda}, function(updateResult)
                            if updateResult then
                                -- La inserción o actualización se realizó correctamente
                                -- print('Se actualizó el propietarioID en la tabla tiendas')
                                TriggerClientEvent('QBCore:Notify', src, 'Se te acaba de asignar el trabajo de Jefe ', 'success')                                
                            else
                                -- Hubo un error en la ejecución de la consulta de inserción o actualización
                                print('No se pudo actualizar el propietarioID en la tabla tiendas')
                            end
                        end)                        
                    else
                        -- Hubo un error en la ejecución de la consulta
                        print('No se pudo actualizar la disponibilidad de la tienda')
                    end
                end)
                
                
            else
                TriggerClientEvent('notify', src, 'inform', 'No tienes suficiente dinero en el banco para comprar en la tienda.')
            end
        else
            print("No se encontraron datos para el jugador con nombre:", playerName)
        end
    end)
end)



-- RegisterServerEvent('intentarComprarTienda')
-- AddEventHandler('intentarComprarTienda', function(playerName, tienda)
--     local src = source
--     local ply = QBCore.Functions.GetPlayer(src)
--     local precioTienda = tonumber(tienda.precio) -- PRECIO PARA DESCONTAR
--     exports.oxmysql:fetch('SELECT money FROM players WHERE name = ?', {playerName}, function(result)
--         if result[1] then
--             local playerData = result[1]             
--             local moneyData = json.decode(playerData.money) -- Decodificar el JSON
--             local dineroEnBanco = tonumber(moneyData.bank) -- Obtener el dinero en el banco
--             -- print("precio de la tienda server = ",precioTienda)
--             -- Procesar los datos del jugador aquí
--             -- for key, value in pairs(playerData) do
--             --     print(key, value)
--             -- end                             
--             if dineroEnBanco >= precioTienda then                
--                 TriggerClientEvent('QBCore:Notify', src, 'Se ha comprado la tienda correctamente', 'success')
--                 ply.Functions.RemoveMoney('bank',precioTienda)
--                     exports.oxmysql:execute('UPDATE tiendas_compradas SET comprada = 1 WHERE nombreTienda = ?', {nombreTienda}, function(rowsChanged)
--                     if result[1] then
--                         -- Aquí puedes realizar acciones con los datos obtenidos de la consulta
--                         -- Por ejemplo, actualizar la columna 'comprada' en la tabla 'tiendas_compradas' a 1
                
--                         exports.oxmysql:execute('UPDATE tiendas_compradas SET comprada = 1 WHERE nombreTienda = ?', {nombreTienda}, function(rowsChanged)
--                             if rowsChanged > 0 then
--                                 print('Se actualizó la columna comprada en la tabla tiendas_compradas')
--                             else
--                                 print('No se pudo actualizar la columna comprada en la tabla tiendas_compradas')
--                             end
--                         end)
--                     else
--                         print("No se encontraron datos para el jugador con nombre:", playerName)
--                     end

                
--             else
--                 TriggerClientEvent('notify', src, 'inform', 'No tienes suficiente dinero en el banco para comprar en la tienda.')
--             end 
--         else
--             print("No se encontraron datos para el jugador con nombre:", playerName)
--         end
--     end)
-- end)

