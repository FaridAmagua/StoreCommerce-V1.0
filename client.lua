-- Obtener los objetos principales de QBCore y QB_Banking
QBCore = exports['qb-core']:GetCoreObject()
QB_Banking = exports['qb-banking']

-- Activar modo de depuración en QBCore
QBCore.Debug = true

-- Crear una tabla para almacenar las tiendas disponibles
local tiendasDisponibles = {}

-- Definir la tecla para comprar (tecla E)
local keyBuy = 38

-- Definir la distancia umbral para mostrar el texto
local distanciaUmbral = 2.0

-- Variable para almacenar el nombre del jugador
local playerName = nil

-- Actualizar la lista de tiendas disponibles
RegisterNetEvent('tiendas:actualizarTiendas')
AddEventHandler('tiendas:actualizarTiendas', function(tiendas)
    tiendasDisponibles = tiendas
end)

-- Función para dibujar los marcadores de las tiendas
function DibujarMarcadoresTiendas()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Iterar sobre todas las tiendas disponibles
    for _, tienda in ipairs(tiendasDisponibles) do
        local marcadorX, marcadorY, marcadorZ = tonumber(tienda.marcador_x), tonumber(tienda.marcador_y), tonumber(tienda.marcador_z)

        -- Dibujar el marcador
        DrawMarker(1, marcadorX, marcadorY, marcadorZ, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 2.0, 255, 255, 0, 100, false, true, 2, nil, nil, false)

        -- Calcular la distancia entre el jugador y el marcador
        local distancia = GetDistanceBetweenCoords(playerCoords, marcadorX, marcadorY, marcadorZ, true)

        -- Verificar si el jugador está lo suficientemente cerca para mostrar el texto de compra
        if distancia < distanciaUmbral then
            local texto = "¿Quieres comprar el " .. tienda.nombre .. "?\nEl precio es $" .. tienda.precio .. "\nPulsa [E] para comprar"

            -- Coordenadas de texto en pantalla (ajustar según la preferencia)
            local screenX, screenY = 0.5, 0.5

            -- Dibujar el texto en pantalla
            DrawTextOnScreen(texto, screenX, screenY)

            -- Verificar si se presionó la tecla de compra
            if IsControlJustPressed(0, keyBuy) then
                ComprarTienda(tienda)
            end
        end
    end
end

-- Función para comprar una tienda
function ComprarTienda(tienda)
    local playerName = GetPlayerName(PlayerId())
    TriggerServerEvent('intentarComprarTienda', playerName, tienda)
end

-- Función para dibujar texto en la pantalla
function DrawTextOnScreen(text, x, y)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Bucle principal para dibujar los marcadores de las tiendas continuamente
Citizen.CreateThread(function()
    while true do
        Wait(0)
        DibujarMarcadoresTiendas()
    end
end)
