QBCore = exports['qb-core']:GetCoreObject()
QB_Banking = exports['qb-banking']
QBCore.Debug = true

local tiendasDisponibles = {}  --DIC frin server function
local keyBuy = 38 -- CODE KEY TO BUY  =  [E]
local distanciaUmbral = 2.0 -- Umbral de distancia para mostrar el texto
local playerName= nil

RegisterNetEvent('tiendas:actualizarTiendas')
AddEventHandler('tiendas:actualizarTiendas', function(tiendas)
    tiendasDisponibles = tiendas
end)

function DibujarMarcadoresTiendas()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, tienda in ipairs(tiendasDisponibles) do
        local marcadorX, marcadorY, marcadorZ = tonumber(tienda.marcador_x), tonumber(tienda.marcador_y), tonumber(tienda.marcador_z)

        -- Dibujar el marcador
        DrawMarker(1, marcadorX, marcadorY, marcadorZ, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 2.0, 255, 255, 0, 100, false, true, 2, nil, nil, false)

        -- Calcula la distancia entre el jugador y el marcador
        local distancia = GetDistanceBetweenCoords(playerCoords, marcadorX, marcadorY, marcadorZ, true)

        if distancia < distanciaUmbral then
            local texto = "¿Quieres comprar el "..tienda.nombre .. "?".."\nEl precio es $" .. tienda.precio .." \nPulsa la [E]"

            -- Coordenadas de texto en pantalla (ajustar según la preferencia)
            local screenX, screenY = 0.5, 0.5

            DrawTextOnScreen(texto, screenX, screenY)
            if IsControlJustPressed(0, keyBuy) then -- 38 es el código de la tecla E
                ComprarTienda(tienda)
            end

        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



function ComprarTienda(tienda)
    local playerName = GetPlayerName(PlayerId())
    TriggerServerEvent('intentarComprarTienda', playerName, tienda)
    -- QB_Banking:AddMoney(playerName, 1222)

    
end



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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


Citizen.CreateThread(function()
    while true do
        Wait(0)
        DibujarMarcadoresTiendas()
    end
end)
