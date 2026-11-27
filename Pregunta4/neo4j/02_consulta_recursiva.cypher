// Obtener el hilo completo de la conversación 1.
MATCH (c:Conversacion {IDConv: 1})-[:TIENE_COMENTARIO_INICIAL]->(root:Comentario)
MATCH route = (root)<-[:RESPONDE_A*0..]-(comment:Comentario)
MATCH (comment)-[:PUBLICADO_POR]->(u:Usuario)
RETURN
  c.IDConv AS IDConv,
  length(route) AS Nivel,
  u.IDU AS IDU,
  comment.IDComentario AS IDComentario,
  comment.Texto AS Texto,
  comment.Fecha AS Fecha
ORDER BY Nivel, IDComentario;
