# Pregunta 4: conversaciones internas en comentarios

Esta propuesta modifica el modelo relacional sin eliminar `Comentar` ni `Publicacion`.

## Archivos MySQL

1. `mysql/01_esquema.sql`: crea `Conversacion` y `ComentarioConversacion`.
2. `mysql/02_datos_prueba.sql`: crea 20 conversaciones y respuestas de ejemplo.
3. `mysql/03_consulta_recursiva.sql`: obtiene el árbol completo de la conversación `IDConv = 1`.

## Ejecución

Desde la raíz del proyecto:

```fish
mysql -uroot -proot AquaLife < Pregunta4/mysql/01_esquema.sql
mysql -uroot -proot AquaLife < Pregunta4/mysql/02_datos_prueba.sql
mysql -uroot -proot AquaLife < Pregunta4/mysql/03_consulta_recursiva.sql
```

## Modelo

- `Conversacion.IDPub` vincula la conversación con una publicación.
- `ComentarioConversacion.IDComentarioPadre` vincula una respuesta con su comentario padre.
- Un comentario padre nulo representa el inicio del hilo.
- La clave primaria propia permite varios comentarios del mismo usuario en una publicación.

`03_consulta_recursiva.sql` puede cambiar `cc.IDConv = 1` por el identificador de otra conversación.

## Archivos Neo4j

1. `neo4j/01_modelo_y_datos.cypher`: crea las restricciones, 20 publicaciones, conversaciones, usuarios y comentarios.
2. `neo4j/02_consulta_recursiva.cypher`: obtiene el hilo completo de la conversación 1.

## Ejecución en Neo4j

Desde la raíz del proyecto:

```bash
docker compose up -d neo4j
docker exec -i aqualife_neo4j cypher-shell -u neo4j -p password < Pregunta4/neo4j/01_modelo_y_datos.cypher
docker exec -i aqualife_neo4j cypher-shell -u neo4j -p password --format plain < Pregunta4/neo4j/02_consulta_recursiva.cypher
```

El modelo usa nodos `Conversacion`, `Comentario`, `Usuario` y `Publicacion`. La relación `RESPONDE_A` representa las respuestas, el usuario se conecta mediante `PUBLICADO_POR`, y el recorrido variable permite obtener todos los descendientes del comentario inicial.

## Comparación de los diseños

La [comparación relacional y de grafo](04_comparacion.md) explica las ventajas y
desventajas de MySQL y Neo4j para resolver conversaciones internas mediante respuestas
jerárquicas.
