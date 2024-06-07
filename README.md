# StoreCommerce V1.0 by Farid

![Funcionamiento](./StoreCommerce.png)

## Configuración
config.lua
En este archivo, especifica los nombres, precios, trabajos (compatibles con NS_JOB), y niveles requeridos para las tiendas. Puedes encontrar más detalles en serve.lua en la función ply.Functions.SetJob(_job,_gradejob).

Este script está diseñado para funcionar con trabajos y roles utilizando el plugin NS multijob para simplificar la gestión. Si prefieres utilizar otro sistema de trabajos, puedes modificar el código según tus necesidades.

### Client.lua
Marcadores
Hemos utilizado los marcadores integrados del juego para indicar las posiciones donde los jugadores pueden interactuar y comprar tiendas.

Funciones Principales:
DibujarMarcadores: Esta función puede ser modificada y personalizada según tus necesidades. Todas las funciones están comentadas para facilitar su comprensión y edición.
ComprarTienda: Recibe el parámetro tienda a través de una función del CubeCore. Usando el playerid, se realiza una inserción en server.lua para asignar la tienda al jugador.
lua
Copiar código
Citizen.CreateThread(function()
    while true do
        Wait(0)
        DibujarMarcadoresTiendas()
    end
end)
Esta función se ejecuta continuamente en un hilo separado, repitiendo la llamada a DibujarMarcadoresTiendas en intervalos de tiempo definidos.

### Server.lua
En este archivo, creamos comandos para facilitar a los administradores el registro de las tiendas.
Por ejemplo, tenemos el comando : QBCore.Commands.Add("creartienda", "Crea una nueva tienda"), que recibe los siguientes parámetros:
{name = "nombre", help = "Nombre de la tienda"},
{name = "precio", help = "Precio de la tienda"},
{name = "job", help = "Trabajo asociado a la tienda"},
{name = "grade", help = "Grado asociado al trabajo"},
{name = "marcador_x", help = "Coordenada X del marcador"},
{name = "marcador_y", help = "Coordenada Y del marcador"},
{name = "marcador_z", help = "Coordenada Z del marcador"}

No proporcionaré una explicación detallada aquí, ya que hay muchas otras guías disponibles, pero puedes copiar y modificar según tus necesidades.

Luego, creamos una tabla tiendas en una base de datos (por ejemplo, usando XAMPP o un gestor de bases de datos). En mi caso, los campos de la tabla son: id_tienda, nombre, precio, disponible, propietario, job, grade, marcador_x, marcador_y, marcador_z. Puedes ajustar los campos según tus preferencias.

![Ejemplo de la base de datos creada](./Database1.png)

CREATE TABLE tiendas (
    id_tienda INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    disponible BOOLEAN NOT NULL DEFAULT TRUE,
    propietario VARCHAR(255),
    job VARCHAR(255),
    grade INT,
    marcador_x FLOAT ,
    marcador_y FLOAT ,
    marcador_z FLOAT 
);

Las funciones principales incluyen:
Comprar tienda: Esto inserta datos en la base de datos con la información recogida del cliente utilizando la función GetId de CubeCore. La notificación de QB_Core te informará sobre el éxito de la compra o cualquier fallo. Puedes 

![Insert en la base de datos](./Database2.png)

personalizar estas configuraciones según tus preferencias, utilizando otros mods para las notificaciones o configuraciones del servidor, como QB_Notify.
La función Citizen.CreateThread(function()) se puede modificar para ajustar el tiempo de actualización de las tiendas y el parseo de los datos.

Por ahora, no tengo planes de futuras actualizaciones, pero estoy abierto a ideas y modificaciones futuras.

Información adicional sobre checkpoints y NS Multijob:

Checkpoints: [Documentación](https://docs.fivem.net/docs/game-references/checkpoints/)
NS Multijob: [Documentación](https://www.docs.nsscripts.com/job-scripts/ns-multijob/customisation)
