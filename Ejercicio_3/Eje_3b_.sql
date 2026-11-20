-- SQLBook: Markup
Definimos como reaccion positiva: "me gusta", "me encanta", "me divierte". como reaccion negativa: "me enoja", "me entristesa", reaccion neutra que no sa va a usar en el analisi: "me asombra"
-- SQLBook: Code
SELECT p.`IDPub`, p.`Texto`,  COUNT(*) as Total_de_reacciones
FROM `Publicacion`as p
JOIN `Reaccionar` as r ON p.`IDPub` = r.`IDPub`
GROUP BY p.`IDPub`, p.`Texto`
HAVING SUM(CASE 
              WHEN r.`Tipo` IN ('Me gusta', 'Me encanta', 'Me divierte') THEN 1
              ELSE 0
          END)
     > SUM(CASE 
              WHEN r.`Tipo` IN ('Me enoja', 'Me entristece') THEN 1
              ELSE 0
          END);
