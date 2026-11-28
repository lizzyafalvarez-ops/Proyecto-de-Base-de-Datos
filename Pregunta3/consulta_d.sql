WITH contrib AS (
    -- 1. Agrupamos por especie y sacamos su conteo total y su categoría
    SELECT ta.IDTA,
           ta.Tipo AS tipo_agua,
           e.IDProd,
           e.NombreComun,
           e.Categoria,
           COUNT(*) AS total_contribuciones
    FROM Contribucion c
    JOIN Especie  e  ON e.IDProd = c.IDProd
    JOIN TipoAgua ta ON ta.IDTA  = e.IDTA
    GROUP BY ta.IDTA, ta.Tipo, e.IDProd, e.NombreComun, e.Categoria
),
ranking_especies AS (
    -- 2. Hacemos el ranking SOLO de las especies
    SELECT tipo_agua,
           NombreComun AS especie_mas_popular,
           Categoria   AS categoria_de_la_especie,
           total_contribuciones,
           ROW_NUMBER() OVER (PARTITION BY IDTA ORDER BY total_contribuciones DESC, NombreComun ASC) AS posicion
    FROM contrib
)
-- 3. Filtramos para quedarnos solo con el número 1 de cada tipo de agua
SELECT tipo_agua,
       especie_mas_popular,
       categoria_de_la_especie,
       total_contribuciones
FROM ranking_especies
WHERE posicion = 1
ORDER BY total_contribuciones DESC;
