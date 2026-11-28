-- SQLBook: Markup
el metodo TIMESTAMPDIFF lo uso para calcular la edad a partir de le fecha de nacimiento
-- SQLBook: Code
WITH edades AS (
    SELECT TIMESTAMPDIFF(YEAR, FechaDeNacimiento, CURDATE()) AS Edad
    FROM Usuario
),
rangos AS (
    SELECT CONCAT(
        FLOOR((Edad - 1) / 10) * 10 + 1,
        '-',
        FLOOR((Edad - 1) / 10) * 10 + 10
    ) AS RangoEdad
    FROM edades
    WHERE Edad >= 1
),
conteos AS (
    SELECT RangoEdad, COUNT(*) AS Cantidad
    FROM rangos
    GROUP BY RangoEdad
),
total_usuarios AS (
    SELECT COUNT(*) AS Total
    FROM rangos
)
SELECT
    c.RangoEdad,
    c.Cantidad,
    ROUND(c.Cantidad * 100.0 / t.Total, 2) AS Porcentaje
FROM conteos AS c
CROSS JOIN total_usuarios AS t
ORDER BY CAST(SUBSTRING_INDEX(c.RangoEdad, '-', 1) AS UNSIGNED);
