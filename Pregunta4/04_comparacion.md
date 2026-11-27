# Pregunta 4.c: comparación de los diseños

## Representación relacional

El diseño relacional representa las conversaciones y sus comentarios mediante las tablas
`Conversacion` y `ComentarioConversacion`. La relación entre respuestas se expresa con
`IDComentarioPadre`, que puede apuntar a otro comentario o contener `NULL` para el
comentario inicial.

Ventajas:

- Mantiene las mismas claves, restricciones e integridad referencial que el resto de
  AquaLife.
- Permite usar `FOREIGN KEY`, índices y operaciones SQL transaccionales conocidas.
- Evita duplicar a usuarios y publicaciones, pues las respuestas están vinculadas a
  sus identificadores.
- Es adecuada para informes, conteos, filtros y consultas por usuario, conversación
  o publicación.
- Permite integrar la conversación con las demás tablas sin cambiar el sistema de
  almacenamiento.

Desventajas:

- Representar una jerarquía requiere una auto-relación sobre
  `ComentarioConversacion`.
- Obtener toda una conversación depende de una consulta recursiva con CTE.
- Consultar hilos muy profundos puede producir rutas largas y requiere definir un
  límite de recursión.
- El orden exacto de los comentarios y la estructura completa deben calcularse
  mediante la columna padre y una ruta auxiliar.
- Las operaciones JOIN pueden ser más costosas cuando crecen las conversaciones y los
  niveles de respuesta.

## Representación con Neo4j

El diseño alternativo representa cada elemento como un nodo y las relaciones forman
directamente el hilo:

- `Publicacion -[:TIENE_CONVERSACION]-> Conversacion`
- `Conversacion -[:TIENE_COMENTARIO_INICIAL]-> Comentario`
- `Comentario -[:PUBLICADO_POR]-> Usuario`
- `Comentario -[:RESPONDE_A]-> Comentario`

Ventajas:

- La estructura jerárquica coincide de forma natural con el grafo de respuestas.
- Los recorridos por `RESPONDE_A` permiten obtener el árbol completo con una
  expresión de ruta variable.
- Agregar una respuesta consiste principalmente en crear un nodo y una relación con
  su comentario padre.
- Es más fácil visualizar y recorrer cadenas de respuestas profundas.
- Las operaciones centradas en relaciones son la fortaleza principal de Neo4j.

Desventajas:

- Introduce otro motor y otra forma de administrar datos dentro del proyecto.
- Las restricciones del grafo deben configurarse explícitamente y no sustituyen todas
  las validaciones del dominio relacional.
- Consultas transversales o analíticas globales pueden ser menos directas que en SQL.
- Es necesario mantener consistencia entre ambos sistemas si MySQL y Neo4j contienen
  los mismos datos.
- Sin índices y restricciones adecuadas, ciertas búsquedas por propiedades pueden
  volverse costosas.

## Comparación aplicada al escenario

Para obtener el hilo desde un comentario inicial:

- En MySQL se utiliza `WITH RECURSIVE` para iniciar en el comentario cuya
  `IDComentarioPadre` es `NULL` y seguir las filas cuya clave padre coincide con la
  clave del comentario anterior.
- En Neo4j se inicia en el comentario relacionado por
  `TIENE_COMENTARIO_INICIAL` y se recorren las relaciones `RESPONDE_A`.

MySQL resulta mejor integrado con la base principal, las restricciones transaccionales
y las operaciones administrativas ya existentes. Neo4j resulta más expresivo para
recorrer relaciones jerárquicas y ofrece una representación más directa del hilo.

## Conclusión

Para AquaLife, el modelo relacional es una opción sólida como fuente principal de
datos por su integración con las demás entidades y el uso de claves foráneas. Neo4j
es más conveniente para demostrar y explorar conversaciones ramificadas, especialmente
cuando el recorrido de respuestas es la operación principal.

Una solución híbrida sería apropiada si MySQL conserva los datos oficiales y Neo4j
sirve como vista especializada para recorrer los comentarios. Sin embargo, esta opción
exige sincronización para evitar que ambos modelos tengan información distinta.
