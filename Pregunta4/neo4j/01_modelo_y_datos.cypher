// Pregunta 4.b: modelo alternativo en Neo4j.

CREATE CONSTRAINT conversacion_id IF NOT EXISTS
FOR (c:Conversacion) REQUIRE c.IDConv IS UNIQUE;

CREATE CONSTRAINT comentario_id IF NOT EXISTS
FOR (c:Comentario) REQUIRE c.IDComentario IS UNIQUE;

CREATE CONSTRAINT usuario_id IF NOT EXISTS
FOR (u:Usuario) REQUIRE u.IDU IS UNIQUE;

CREATE CONSTRAINT publicacion_id IF NOT EXISTS
FOR (p:Publicacion) REQUIRE p.IDPub IS UNIQUE;

UNWIND range(1, 20) AS id
MERGE (p:Publicacion {IDPub: id})
MERGE (c:Conversacion {IDConv: id})
SET c.Titulo = 'Conversación sobre la publicación ' + toString(id),
    c.Estado = 'activa'
MERGE (p)-[:TIENE_CONVERSACION]->(c);

UNWIND range(1, 20) AS id
MERGE (root:Comentario {
  IDComentario: id
})
SET root.Texto = 'Hola a todos, deseo comentarios y soluciones para esta consulta.',
    root.Fecha = datetime()
MERGE (rootUser:Usuario {IDU: 1})
MERGE (root)-[:PUBLICADO_POR]->(rootUser)
MERGE (c:Conversacion {IDConv: id})
MERGE (c)-[:TIENE_COMENTARIO_INICIAL]->(root);

UNWIND range(1, 20) AS id
MERGE (answer:Comentario {
  IDComentario: 20 + id
})
SET answer.Texto = 'En mi experiencia, conviene verificar primero los parámetros del acuario.',
    answer.Fecha = datetime()
MERGE (answerUser:Usuario {IDU: 2})
MERGE (answer)-[:PUBLICADO_POR]->(answerUser)
MERGE (root:Comentario {IDComentario: id})
MERGE (answer)-[:RESPONDE_A]->(root);

UNWIND range(1, 20) AS id
MERGE (answer:Comentario {
  IDComentario: 40 + id
})
SET answer.Texto = 'Podemos comparar soluciones y resultados antes de modificar el diseño.',
    answer.Fecha = datetime()
MERGE (answerUser:Usuario {IDU: 3})
MERGE (answer)-[:PUBLICADO_POR]->(answerUser)
MERGE (root:Comentario {IDComentario: id})
MERGE (answer)-[:RESPONDE_A]->(root);

