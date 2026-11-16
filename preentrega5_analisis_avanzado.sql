
-- ============================================================================
-- Archivo: preentrega_analisis_avanzado.sql
-- Descripción: Análisis mensual de ventas por categoría utilizando CTEs
--              encadenadas, Funciones de Ventana y CASE WHEN.
-- Motor: PostgreSQL
-- ============================================================================


-- 1. Primera CTE: Agrupación mensual por categoría
    -- Extraemos el año/mes con DATE_TRUNC, unimos ventas con productos por
    -- id_producto y con categorias por el nombre de la categoría, y sumamos el monto.


WITH ventas_mensuales AS (
 SELECT DATE_TRUNC ('month', v.fecha) AS mes,
ca.nombre AS categoria,
SUM(v.monto) AS total_ventas
FROM ventas v
INNER JOIN productos p ON v.id_producto=p.id_producto
 INNER JOIN categorias ca ON p.categoria= ca.nombre 
GROUP BY  
DATE_TRUNC ('month', v.fecha),
ca.nombre
),


-- 2. Segunda CTE: Cálculo de métricas con Window Functions
    -- Calculamos el ranking mensual por categoría, el total acumulado en el
    -- tiempo (Running Total) y el promedio mensual de cada categoría.



metricas_ventana AS (
SELECT mes, categoria, total_ventas,
RANK () OVER (PARTITION BY mes
ORDER BY total_ventas DESC) AS ranking_mensual,							-- Ranking de categorías más vendidas dentro de cada mes


SUM (total_ventas) OVER (PARTITION BY categoria order by mes ASC) AS acumulado_categoria,	-- Total acumulado de ventas por categoría a través del tiempo


AVG (total_ventas) over (partition BY categoria) AS promedio_categoria				-- Promedio de ventas de cada categoría para comparar en el SELECT final

FROM ventas_mensuales)



-- 3. Consulta Final (SELECT principal)
-- Comparamos la venta mensual contra el promedio de esa misma categoría
-- para clasificar cada mes como 'Exitoso' o 'Bajo el promedio'.


SELECT 
mes, 
categoria,
total_ventas,
ranking_mensual,
acumulado_categoria,
promedio_categoria,
CASE WHEN total_ventas>=promedio_categoria THEN 'Exitoso'
ELSE 'Bajo el promedio'
END AS Resultado
From metricas_ventana
ORDER BY
Mes asc,
ranking_mensual ASC;