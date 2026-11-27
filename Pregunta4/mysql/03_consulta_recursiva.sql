-- Consulta recursiva: obtiene una conversación completa como árbol.

SET SESSION cte_max_recursion_depth = 10000;

WITH RECURSIVE arbol_comentarios AS (
    -- Raíces: comentarios que no responden a otro comentario.
    SELECT
        cc.IDComentario,
        cc.IDComentarioPadre,
        cc.IDConv,
        cc.IDU,
        u.Nombre,
        cc.Texto,
        cc.Fecha,
        0 AS Nivel,
        CAST(LPAD(cc.IDComentario, 10, '0') AS CHAR(1000)) AS Ruta
    FROM ComentarioConversacion cc
    JOIN Usuario u ON u.IDU = cc.IDU
    WHERE cc.IDConv = 1
      AND cc.IDComentarioPadre IS NULL

    UNION ALL

    -- Respuestas: se enlazan al comentario padre.
    SELECT
        cc.IDComentario,
        cc.IDComentarioPadre,
        cc.IDConv,
        cc.IDU,
        u.Nombre,
        cc.Texto,
        cc.Fecha,
        ac.Nivel + 1,
        CONCAT(ac.Ruta, '.', LPAD(cc.IDComentario, 10, '0'))
    FROM ComentarioConversacion cc
    JOIN arbol_comentarios ac
      ON cc.IDComentarioPadre = ac.IDComentario
    JOIN Usuario u ON u.IDU = cc.IDU
)
SELECT
    Nivel,
    CONCAT(REPEAT('  ', Nivel), Nombre, ': ', Texto) AS Conversacion,
    Fecha
FROM arbol_comentarios
ORDER BY Ruta;
