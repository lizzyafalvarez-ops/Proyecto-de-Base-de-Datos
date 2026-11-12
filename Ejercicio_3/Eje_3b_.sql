-- SQLBook: Code
SELECT DISTINCT Tipo 
FROM `Reaccionar`
-- SQLBook: Code
SELECT `Tipo` , COUNT(*) as total_reacciones
From `Reaccionar`
GROUP BY `Tipo`
ORDER BY `Tipo`
-- SQLBook: Code
