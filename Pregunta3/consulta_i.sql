SET SESSION group_concat_max_len = 1000000;

WITH
-- 1. Variación de precios: más de 30 % dentro del mismo mes.
alertas_precios AS (
    SELECT r.IDUV,
           GROUP_CONCAT(DISTINCT
               CONCAT(p.Nombre, ' [', r.anio, '-', LPAD(r.mes, 2, '0'), ']')
               ORDER BY r.anio, r.mes, p.Nombre
               SEPARATOR ', '
           ) AS detalle
    FROM _resumen_ventas r
    JOIN Producto p ON p.IDProd = r.IDProd
    WHERE r.precio_min > 0
      AND (1.0 * (r.precio_max - r.precio_min) / r.precio_min) > 0.30
    GROUP BY r.IDUV
),

-- 2. Calificaciones polarizadas: al menos 30 % con 1, al menos 30 % con 5
-- y como máximo 20 % con valores intermedios.
productos_polarizados AS (
    SELECT c.IDUV,
           c.IDProd
    FROM Compra c
    WHERE c.Puntuacion IS NOT NULL
    GROUP BY c.IDUV, c.IDProd
    HAVING COUNT(c.Puntuacion) >= 5
       AND (1.0 * SUM(c.Puntuacion = 1) / COUNT(c.Puntuacion)) >= 0.30
       AND (1.0 * SUM(c.Puntuacion = 5) / COUNT(c.Puntuacion)) >= 0.30
       AND (1.0 * SUM(c.Puntuacion IN (2, 3, 4)) / COUNT(c.Puntuacion)) <= 0.20
),
alertas_calificaciones AS (
    SELECT pp.IDUV,
           GROUP_CONCAT(DISTINCT p.Nombre
               ORDER BY p.Nombre
               SEPARATOR ', '
           ) AS detalle
    FROM productos_polarizados pp
    JOIN Producto p ON p.IDProd = pp.IDProd
    GROUP BY pp.IDUV
),

-- 3. Compradores fantasma: compradores que solo adquirieron un producto.
clientes_de_un_producto AS (
    SELECT c.IDUC
    FROM Compra c
    GROUP BY c.IDUC
    HAVING COUNT(DISTINCT c.IDProd) = 1
),
total_clientes_vendedor AS (
    SELECT c.IDUV,
           COUNT(DISTINCT c.IDUC) AS total_clientes
    FROM Compra c
    GROUP BY c.IDUV
),
clientes_unicos_vendedor AS (
    SELECT c.IDUV,
           COUNT(DISTINCT c.IDUC) AS clientes_unicos
    FROM Compra c
    JOIN clientes_de_un_producto cup ON cup.IDUC = c.IDUC
    GROUP BY c.IDUV
),
alertas_compradores AS (
    SELECT t.IDUV,
           CONCAT(u.clientes_unicos, ' de ', t.total_clientes,
                  ' clientes solo compraron 1 producto') AS detalle
    FROM total_clientes_vendedor t
    JOIN clientes_unicos_vendedor u ON u.IDUV = t.IDUV
    WHERE t.total_clientes >= 5
      AND (1.0 * u.clientes_unicos / t.total_clientes) >= 0.80
),

-- 4. Patrón distinto al de la competencia.
metricas_vendedor AS (
    SELECT c.IDProd,
           c.IDUV,
           AVG(c.Precio) AS precio_promedio,
           SUM(c.Cantidad) AS unidades_totales,
           AVG(c.Puntuacion) AS puntuacion_promedio
    FROM Compra c
    GROUP BY c.IDProd, c.IDUV
),
totales_producto AS (
    SELECT IDProd,
           SUM(precio_promedio) AS suma_precios,
           SUM(unidades_totales) AS suma_unidades,
           SUM(puntuacion_promedio) AS suma_puntuaciones,
           COUNT(*) AS numero_vendedores
    FROM metricas_vendedor
    GROUP BY IDProd
),
comparativa AS (
    SELECT m.IDProd,
           m.IDUV,
           m.precio_promedio,
           m.unidades_totales,
           m.puntuacion_promedio,
           CASE WHEN t.numero_vendedores > 1
                THEN (t.suma_precios - m.precio_promedio)
                     / (t.numero_vendedores - 1)
           END AS precio_otros,
           CASE WHEN t.numero_vendedores > 1
                THEN (t.suma_unidades - m.unidades_totales)
                     / (t.numero_vendedores - 1)
           END AS unidades_otros,
           CASE WHEN t.numero_vendedores > 1
                THEN (t.suma_puntuaciones - m.puntuacion_promedio)
                     / (t.numero_vendedores - 1)
           END AS puntuacion_otros,
           t.numero_vendedores
    FROM metricas_vendedor m
    JOIN totales_producto t ON t.IDProd = m.IDProd
),
alertas_competencia AS (
    SELECT IDUV,
           GROUP_CONCAT(
               CONCAT(NombreProducto, ' (', TiposAnomalia, ')')
               ORDER BY NombreProducto
               SEPARATOR ' | '
           ) AS detalle
    FROM (
        SELECT c.IDUV,
               p.Nombre AS NombreProducto,
               CONCAT_WS(', ',
                   CASE WHEN MAX(
                        c.precio_otros > 0
                        AND ABS(c.precio_promedio - c.precio_otros)
                            / c.precio_otros > 0.30
                   ) THEN 'Precio Atipico' END,
                   CASE WHEN MAX(
                        c.unidades_otros > 0
                        AND (c.unidades_totales > 2 * c.unidades_otros
                             OR c.unidades_totales < 0.5 * c.unidades_otros)
                   ) THEN 'Volumen Atipico' END,
                   CASE WHEN MAX(
                        c.puntuacion_otros IS NOT NULL
                        AND ABS(c.puntuacion_promedio - c.puntuacion_otros) >= 1.5
                   ) THEN 'Rating Atipico' END
               ) AS TiposAnomalia
        FROM comparativa c
        JOIN Producto p ON p.IDProd = c.IDProd
        WHERE c.numero_vendedores > 1
          AND (
              (c.precio_otros > 0
               AND ABS(c.precio_promedio - c.precio_otros)
                   / c.precio_otros > 0.30)
              OR
              (c.unidades_otros > 0
               AND (c.unidades_totales > 2 * c.unidades_otros
                    OR c.unidades_totales < 0.5 * c.unidades_otros))
              OR
              (c.puntuacion_otros IS NOT NULL
               AND ABS(c.puntuacion_promedio - c.puntuacion_otros) >= 1.5)
          )
        GROUP BY c.IDUV, p.Nombre
    ) AS anomalas_producto
    GROUP BY IDUV
),

-- Consolidado final con índice de sospecha.
auditoria AS (
    SELECT u.IDU AS ID_Vendedor,
           u.Nombre AS Vendedor,
           ap.detalle AS ev_precios,
           ac.detalle AS ev_calificaciones,
           acb.detalle AS ev_compradores,
           ace.detalle AS ev_competencia,
           (CASE WHEN ap.IDUV IS NOT NULL THEN 30 ELSE 0 END
            + CASE WHEN ac.IDUV IS NOT NULL THEN 25 ELSE 0 END
            + CASE WHEN acb.IDUV IS NOT NULL THEN 20 ELSE 0 END
            + CASE WHEN ace.IDUV IS NOT NULL THEN 25 ELSE 0 END
           ) AS indice_sospecha
    FROM Usuario u
    LEFT JOIN alertas_precios ap ON ap.IDUV = u.IDU
    LEFT JOIN alertas_calificaciones ac ON ac.IDUV = u.IDU
    LEFT JOIN alertas_compradores acb ON acb.IDUV = u.IDU
    LEFT JOIN alertas_competencia ace ON ace.IDUV = u.IDU
)
SELECT ID_Vendedor,
       Vendedor,
       indice_sospecha,
       LEFT(CONCAT_WS(' || ',
           CASE WHEN ev_precios IS NOT NULL
                THEN CONCAT('[PRECIOS]: ', ev_precios)
           END,
           CASE WHEN ev_calificaciones IS NOT NULL
                THEN CONCAT('[CALIFICACIONES]: ', ev_calificaciones)
           END,
           CASE WHEN ev_compradores IS NOT NULL
                THEN CONCAT('[CLIENTES]: ', ev_compradores)
           END,
           CASE WHEN ev_competencia IS NOT NULL
                THEN CONCAT('[COMPETENCIA]: ', ev_competencia)
           END
       ), 500) AS reporte_evidencias
FROM auditoria
WHERE indice_sospecha > 0
ORDER BY indice_sospecha DESC,
         Vendedor ASC;
]]]
