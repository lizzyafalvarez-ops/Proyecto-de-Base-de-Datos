-- SQLBook: Code
SELECT
    u.Nombre,
    u.Email,
    u.DireccionParticular,
    SUM(c.Cantidad) AS TotalProductosVendidos,
    ROUND(AVG(c.Puntuacion), 2) AS CalificacionPromedio
FROM Compra AS c
JOIN Usuario AS u ON u.IDU = c.IDUV
WHERE c.Puntuacion IS NOT NULL
GROUP BY u.IDU, u.Nombre, u.Email, u.DireccionParticular
HAVING AVG(c.Puntuacion) IS NOT NULL
ORDER BY CalificacionPromedio DESC
LIMIT 5;