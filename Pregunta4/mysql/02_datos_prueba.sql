-- Datos mínimos para probar conversaciones y respuestas.

SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM ComentarioConversacion;
DELETE FROM Conversacion;
SET FOREIGN_KEY_CHECKS = 1;

-- Una conversación por cada una de las primeras 20 publicaciones.
INSERT INTO Conversacion (IDPub, Titulo)
SELECT
    p.IDPub,
    CONCAT('Conversación sobre: ', LEFT(p.Texto, 180))
FROM Publicacion p
JOIN (
    SELECT IDPub
    FROM Publicacion
    ORDER BY IDPub
    LIMIT 20
) AS seleccion ON seleccion.IDPub = p.IDPub;

-- Un comentario inicial publicado por el autor de la publicación.
INSERT INTO ComentarioConversacion (IDConv, IDU, IDComentarioPadre, Texto)
SELECT
    c.IDConv,
    p.IDU,
    NULL,
    'Hola a todos, deseo comentarios y soluciones para esta consulta.'
FROM Conversacion c
JOIN Publicacion p ON p.IDPub = c.IDPub;

-- Una respuesta de otro usuario al comentario inicial.
INSERT INTO ComentarioConversacion (IDConv, IDU, IDComentarioPadre, Texto)
SELECT
    c.IDConv,
    u.IDU,
    (
        SELECT cc.IDComentario
        FROM ComentarioConversacion cc
        WHERE cc.IDConv = c.IDConv
        ORDER BY cc.IDComentario
        LIMIT 1
    ),
    'En mi experiencia, conviene verificar primero los parámetros del acuario.'
FROM Conversacion c
JOIN Publicacion p ON p.IDPub = c.IDPub
JOIN Usuario u
  ON u.IDU = (
      SELECT u2.IDU
      FROM Usuario u2
      WHERE u2.IDU <> p.IDU
      ORDER BY u2.IDU
      LIMIT 1
  );

-- Una segunda respuesta, también dirigida al comentario inicial.
INSERT INTO ComentarioConversacion (IDConv, IDU, IDComentarioPadre, Texto)
SELECT
    c.IDConv,
    u.IDU,
    (
        SELECT cc.IDComentario
        FROM ComentarioConversacion cc
        WHERE cc.IDConv = c.IDConv
        ORDER BY cc.IDComentario
        LIMIT 1
    ),
    'Podemos comparar soluciones y resultados antes de modificar el diseño.'
FROM Conversacion c
JOIN Publicacion p ON p.IDPub = c.IDPub
JOIN Usuario u
  ON u.IDU = (
      SELECT u2.IDU
      FROM Usuario u2
      WHERE u2.IDU <> p.IDU
      ORDER BY u2.IDU
      LIMIT 1 OFFSET 1
  );
