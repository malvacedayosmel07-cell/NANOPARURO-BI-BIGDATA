-- Databricks notebook source
/* ======================================================================
   BI_Nanoparuro - LIMPIEZA DE DATOS (Databricks / Spark SQL)
   Requiere haber ejecutado antes el script del modelo (esquema bi_nanoparuro).

   Flujo:  STG_Ventas_Sucia  ->  vistas paso1..paso4  ->  STG_Ventas_Limpia
                                                      ->  STG_Ventas_Rechazados
   La tabla original STG_Ventas no se modifica.
   ====================================================================== */

-- USE CATALOG mi_catalogo;   -- solo si usaste otro catalogo
USE SCHEMA bi_nanoparuro;

-- COMMAND ----------

/* =========================   TABLA DE PRACTICA CON DATOS SUCIOS   =========================
   Copia los 74 pedidos y agrega 12 filas con problemas. Si trabajas con datos reales, omite esta celda
   y cambia STG_Ventas_Sucia por el nombre de tu tabla de origen en las celdas siguientes. */
CREATE OR REPLACE TABLE STG_Ventas_Sucia (
    OrderID STRING, CustomerID STRING, NombreCliente STRING, TipoCliente STRING,
    ProductID STRING, NombreProducto STRING, Categoria STRING, Subcategoria STRING,
    FechaVenta DATE,
    Ciudad STRING, Estado STRING, Region STRING, CodigoPostal STRING,
    SellerID STRING, NombreVendedor STRING,
    Cantidad INT, Precio DECIMAL(18,2), CostoFlete DECIMAL(18,2),
    FechaEntregaEstimada DATE, FechaEntregaReal DATE, Calificacion INT
);

-- Copia de los 74 pedidos buenos
INSERT INTO STG_Ventas_Sucia
SELECT OrderID, CustomerID, NombreCliente, TipoCliente, ProductID, NombreProducto, Categoria, Subcategoria, FechaVenta, Ciudad, Estado, Region, CodigoPostal, SellerID, NombreVendedor, Cantidad, Precio, CostoFlete, FechaEntregaEstimada, FechaEntregaReal, Calificacion FROM STG_Ventas;

-- Duplicado exacto de ORD-1010 y ORD-1020
INSERT INTO STG_Ventas_Sucia
SELECT OrderID, CustomerID, NombreCliente, TipoCliente, ProductID, NombreProducto, Categoria, Subcategoria, FechaVenta, Ciudad, Estado, Region, CodigoPostal, SellerID, NombreVendedor, Cantidad, Precio, CostoFlete, FechaEntregaEstimada, FechaEntregaReal, Calificacion FROM STG_Ventas WHERE OrderID IN ('ORD-1010', 'ORD-1020');

-- Duplicado de ORD-1030 con el ID en minusculas y con espacios
INSERT INTO STG_Ventas_Sucia
SELECT concat(' ', lower(OrderID), ' '), CustomerID, NombreCliente, TipoCliente, ProductID, NombreProducto, Categoria, Subcategoria, FechaVenta, Ciudad, Estado, Region, CodigoPostal, SellerID, NombreVendedor, Cantidad, Precio, CostoFlete, FechaEntregaEstimada, FechaEntregaReal, Calificacion FROM STG_Ventas WHERE OrderID = 'ORD-1030';

-- 9 filas con problemas distintos
INSERT INTO STG_Ventas_Sucia VALUES
-- 1) texto sucio: espacios, mayusculas/minusculas (se corrige)
(' ord-2001 ', ' cli-04 ', '  luis   vargas ', 'FINAL', ' prod-04 ', 'Raspberry Pi Pico', 'MICROCONTROLADORES', 'placas',
 DATE'2026-07-02', 'LIMA', 'lima', ' Miraflores', '15074', 'ven-03', 'Luis Ramirez', 2, 18.00, 6.00, DATE'2026-07-06', DATE'2026-07-08', 4),
-- 2) Cantidad negativa (se rechaza)
('ORD-2002', 'CLI-05', 'Electro Andina SAC', 'Empresa', 'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
 DATE'2026-07-03', 'Cusco', 'Cusco', 'Cusco', '08001', 'VEN-04', 'Rosa Quispe', -3, 45.00, 10.00, DATE'2026-07-10', DATE'2026-07-09', 5),
-- 3) Precio = 0 (se rechaza)
('ORD-2003', 'CLI-06', 'Rosa Medina', 'Final', 'PROD-05', 'Sensor Ultrasonico HC-SR04', 'Sensores', 'Distancia',
 DATE'2026-07-04', 'Piura', 'Piura', 'Piura', '20001', 'VEN-02', 'Ana Torres', 2, 0.00, 5.00, DATE'2026-07-11', NULL, NULL),
-- 4) Calificacion = 9 (se pone en NULL)
('ORD-2004', 'CLI-07', 'Robotica Peru EIRL', 'Empresa', 'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
 DATE'2026-07-05', 'Lima', 'Lima', 'San Isidro', '15036', 'VEN-05', 'Jorge Salazar', 10, 15.00, 8.00, DATE'2026-07-09', DATE'2026-07-08', 9),
-- 5) Entrega real anterior a la venta (se pone en NULL)
('ORD-2005', 'CLI-08', 'Diego Flores', 'Final', 'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
 DATE'2026-07-06', 'Chiclayo', 'Lambayeque', 'Chiclayo', '14001', 'VEN-03', 'Luis Ramirez', 3, 7.00, 9.00, DATE'2026-07-13', DATE'2026-07-04', 4),
-- 6) Datos del cliente en NULL (se completan con otros pedidos de CLI-09)
('ORD-2006', 'CLI-09', NULL, NULL, 'PROD-06', 'Modulo Rele 5V', 'Actuadores', 'Reles',
 DATE'2026-07-07', NULL, NULL, NULL, NULL, 'VEN-01', 'Carlos Gomez', 15, 6.50, 12.00, DATE'2026-07-14', DATE'2026-07-12', 5),
-- 7) OrderID nulo (se rechaza)
(NULL, 'CLI-10', 'Carla Rojas', 'Final', 'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
 DATE'2026-07-08', 'Arequipa', 'Arequipa', 'Arequipa', '04001', 'VEN-02', 'Ana Torres', 1, 5.50, 6.50, DATE'2026-07-15', NULL, NULL),
-- 8) FechaVenta nula (se rechaza)
('ORD-2008', 'CLI-11', 'Mecatronica del Sur SRL', 'Empresa', 'PROD-07', 'Servomotor SG90', 'Actuadores', 'Motores',
 NULL, 'Cusco', 'Cusco', 'Cusco', '08001', 'VEN-04', 'Rosa Quispe', 20, 9.00, 12.00, NULL, NULL, NULL),
-- 9) Cantidad = 5000 (valor atipico: se conserva y se marca)
('ORD-2009', 'CLI-12', 'Andrea Paredes', 'Final', 'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
 DATE'2026-07-09', 'Lima', 'Lima', 'Cercado', '15001', 'VEN-04', 'Rosa Quispe', 5000, 12.00, 10.00, DATE'2026-07-13', DATE'2026-07-12', 3);

SELECT COUNT(*) AS FilasTablaSucia FROM STG_Ventas_Sucia;   -- esperado: 86

-- COMMAND ----------

/* =========================   PERFILADO: ANTES DE LIMPIAR   ========================= */
SELECT 'Filas totales' AS Regla, COUNT(*) AS Filas FROM STG_Ventas_Sucia
UNION ALL SELECT 'OrderID nulo o vacio', COUNT(*) FROM STG_Ventas_Sucia WHERE OrderID IS NULL OR TRIM(OrderID) = ''
UNION ALL SELECT 'OrderID repetido (ignorando mayusculas y espacios)', COUNT(OrderID) - COUNT(DISTINCT UPPER(TRIM(OrderID))) FROM STG_Ventas_Sucia
UNION ALL SELECT 'Filas con espacios sobrantes en algun texto', COUNT(*) FROM STG_Ventas_Sucia
    WHERE OrderID <> TRIM(OrderID) OR CustomerID <> TRIM(CustomerID) OR ProductID <> TRIM(ProductID)
       OR SellerID <> TRIM(SellerID) OR NombreCliente <> TRIM(NombreCliente) OR NombreCliente LIKE '%  %'
       OR Ciudad <> TRIM(Ciudad) OR Region <> TRIM(Region)
UNION ALL SELECT 'Filas con texto todo en MAYUSCULAS o minusculas', COUNT(*) FROM STG_Ventas_Sucia
    WHERE TRIM(NombreCliente) IN (lower(TRIM(NombreCliente)), upper(TRIM(NombreCliente)))
       OR TRIM(Categoria) IN (lower(TRIM(Categoria)), upper(TRIM(Categoria)))
       OR TRIM(Subcategoria) IN (lower(TRIM(Subcategoria)), upper(TRIM(Subcategoria)))
       OR TRIM(Ciudad) IN (lower(TRIM(Ciudad)), upper(TRIM(Ciudad)))
       OR TRIM(Estado) IN (lower(TRIM(Estado)), upper(TRIM(Estado)))
UNION ALL SELECT 'TipoCliente distinto de Empresa/Final (ignorando formato)', COUNT(*) FROM STG_Ventas_Sucia
    WHERE TipoCliente IS NOT NULL AND LOWER(TRIM(TipoCliente)) NOT IN ('empresa', 'final')
UNION ALL SELECT 'Datos del cliente nulos', COUNT(*) FROM STG_Ventas_Sucia
    WHERE NombreCliente IS NULL OR TipoCliente IS NULL OR Ciudad IS NULL OR Estado IS NULL OR Region IS NULL OR CodigoPostal IS NULL
UNION ALL SELECT 'FechaVenta nula', COUNT(*) FROM STG_Ventas_Sucia WHERE FechaVenta IS NULL
UNION ALL SELECT 'Cantidad nula o menor/igual a 0', COUNT(*) FROM STG_Ventas_Sucia WHERE Cantidad IS NULL OR Cantidad <= 0
UNION ALL SELECT 'Precio nulo o menor/igual a 0', COUNT(*) FROM STG_Ventas_Sucia WHERE Precio IS NULL OR Precio <= 0
UNION ALL SELECT 'CostoFlete nulo o negativo', COUNT(*) FROM STG_Ventas_Sucia WHERE CostoFlete IS NULL OR CostoFlete < 0
UNION ALL SELECT 'Calificacion fuera de 1 a 5', COUNT(*) FROM STG_Ventas_Sucia WHERE Calificacion IS NOT NULL AND Calificacion NOT BETWEEN 1 AND 5
UNION ALL SELECT 'Entrega real anterior a la venta', COUNT(*) FROM STG_Ventas_Sucia WHERE FechaEntregaReal < FechaVenta
UNION ALL SELECT 'Entrega estimada anterior a la venta', COUNT(*) FROM STG_Ventas_Sucia WHERE FechaEntregaEstimada < FechaVenta;

-- COMMAND ----------

/* PASO 1: quitar espacios, convertir vacios en NULL, IDs en mayusculas, TipoCliente estandar */
CREATE OR REPLACE VIEW vw_stg_paso1 AS
SELECT
    NULLIF(UPPER(TRIM(OrderID)), '')    AS OrderID,
    NULLIF(UPPER(TRIM(CustomerID)), '') AS CustomerID,
    NULLIF(TRIM(regexp_replace(NombreCliente, ' +', ' ')), '') AS NombreCliente,
    CASE LOWER(TRIM(TipoCliente)) WHEN 'empresa' THEN 'Empresa' WHEN 'final' THEN 'Final' END AS TipoCliente,
    NULLIF(UPPER(TRIM(ProductID)), '')  AS ProductID,
    NULLIF(TRIM(regexp_replace(NombreProducto, ' +', ' ')), '') AS NombreProducto,
    NULLIF(TRIM(regexp_replace(Categoria, ' +', ' ')), '') AS Categoria,
    NULLIF(TRIM(regexp_replace(Subcategoria, ' +', ' ')), '') AS Subcategoria,
    FechaVenta,
    NULLIF(TRIM(regexp_replace(Ciudad, ' +', ' ')), '') AS Ciudad,
    NULLIF(TRIM(regexp_replace(Estado, ' +', ' ')), '') AS Estado,
    NULLIF(TRIM(regexp_replace(Region, ' +', ' ')), '') AS Region,
    NULLIF(TRIM(CodigoPostal), '')      AS CodigoPostal,
    NULLIF(UPPER(TRIM(SellerID)), '')   AS SellerID,
    NULLIF(TRIM(regexp_replace(NombreVendedor, ' +', ' ')), '') AS NombreVendedor,
    Cantidad, Precio, CostoFlete,
    FechaEntregaEstimada, FechaEntregaReal, Calificacion
FROM STG_Ventas_Sucia;

-- COMMAND ----------

/* PASO 2: si un texto viene todo en MAYUSCULAS o todo en minusculas, se pasa a formato 'Nombre Propio'.
   Los textos mixtos (ej. 'Electro Andina SAC') se dejan como estan. */
CREATE OR REPLACE VIEW vw_stg_paso2 AS
SELECT
    OrderID, CustomerID,
    CASE WHEN NombreCliente = lower(NombreCliente) OR NombreCliente = upper(NombreCliente) THEN initcap(NombreCliente) ELSE NombreCliente END AS NombreCliente,
    TipoCliente, ProductID,
    CASE WHEN NombreProducto = lower(NombreProducto) OR NombreProducto = upper(NombreProducto) THEN initcap(NombreProducto) ELSE NombreProducto END AS NombreProducto,
    CASE WHEN Categoria = lower(Categoria) OR Categoria = upper(Categoria) THEN initcap(Categoria) ELSE Categoria END AS Categoria,
    CASE WHEN Subcategoria = lower(Subcategoria) OR Subcategoria = upper(Subcategoria) THEN initcap(Subcategoria) ELSE Subcategoria END AS Subcategoria,
    FechaVenta,
    CASE WHEN Ciudad = lower(Ciudad) OR Ciudad = upper(Ciudad) THEN initcap(Ciudad) ELSE Ciudad END AS Ciudad,
    CASE WHEN Estado = lower(Estado) OR Estado = upper(Estado) THEN initcap(Estado) ELSE Estado END AS Estado,
    CASE WHEN Region = lower(Region) OR Region = upper(Region) THEN initcap(Region) ELSE Region END AS Region,
    CodigoPostal, SellerID,
    CASE WHEN NombreVendedor = lower(NombreVendedor) OR NombreVendedor = upper(NombreVendedor) THEN initcap(NombreVendedor) ELSE NombreVendedor END AS NombreVendedor,
    Cantidad, Precio, CostoFlete,
    FechaEntregaEstimada, FechaEntregaReal, Calificacion
FROM vw_stg_paso1;

-- COMMAND ----------

/* PASO 3: completar nulos con datos del mismo cliente/producto/vendedor, corregir valores invalidos
   y calcular el motivo de rechazo.
   Supuesto: cada CustomerID tiene una sola ciudad/region. Si un cliente enviara a varias ciudades,
   esta regla de completado no seria adecuada. */
CREATE OR REPLACE VIEW vw_stg_paso3 AS
SELECT
    OrderID, CustomerID,
    coalesce(NombreCliente, max(NombreCliente) OVER (PARTITION BY CustomerID)) AS NombreCliente,
    coalesce(TipoCliente, max(TipoCliente) OVER (PARTITION BY CustomerID)) AS TipoCliente,
    ProductID,
    coalesce(NombreProducto, max(NombreProducto) OVER (PARTITION BY ProductID)) AS NombreProducto,
    coalesce(Categoria, max(Categoria) OVER (PARTITION BY ProductID)) AS Categoria,
    coalesce(Subcategoria, max(Subcategoria) OVER (PARTITION BY ProductID)) AS Subcategoria,
    FechaVenta,
    coalesce(Ciudad, max(Ciudad) OVER (PARTITION BY CustomerID)) AS Ciudad,
    coalesce(Estado, max(Estado) OVER (PARTITION BY CustomerID)) AS Estado,
    coalesce(Region, max(Region) OVER (PARTITION BY CustomerID)) AS Region,
    coalesce(CodigoPostal, max(CodigoPostal) OVER (PARTITION BY CustomerID)) AS CodigoPostal,
    SellerID,
    coalesce(NombreVendedor, max(NombreVendedor) OVER (PARTITION BY SellerID)) AS NombreVendedor,
    Cantidad, Precio, CostoFlete,
    CASE WHEN FechaEntregaEstimada >= FechaVenta THEN FechaEntregaEstimada END AS FechaEntregaEstimada,
    CASE WHEN FechaEntregaReal >= FechaVenta THEN FechaEntregaReal END         AS FechaEntregaReal,
    CASE WHEN Calificacion BETWEEN 1 AND 5 THEN Calificacion END               AS Calificacion,
    NULLIF(concat_ws('; ',
        CASE WHEN Calificacion IS NOT NULL AND Calificacion NOT BETWEEN 1 AND 5 THEN 'Calificacion fuera de rango -> NULL' END,
        CASE WHEN FechaEntregaReal < FechaVenta THEN 'Entrega real anterior a la venta -> NULL' END,
        CASE WHEN FechaEntregaEstimada < FechaVenta THEN 'Entrega estimada anterior a la venta -> NULL' END,
        CASE WHEN NombreCliente IS NULL OR TipoCliente IS NULL OR Ciudad IS NULL OR Estado IS NULL
                  OR Region IS NULL OR CodigoPostal IS NULL THEN 'Datos de cliente completados desde otros pedidos' END,
        CASE WHEN NombreProducto IS NULL OR Categoria IS NULL OR Subcategoria IS NULL THEN 'Datos de producto completados desde otros pedidos' END,
        CASE WHEN NombreVendedor IS NULL THEN 'Nombre de vendedor completado desde otros pedidos' END
    ), '') AS Observaciones,
    NULLIF(concat_ws('; ',
        CASE WHEN OrderID IS NULL THEN 'OrderID nulo' END,
        CASE WHEN CustomerID IS NULL THEN 'CustomerID nulo' END,
        CASE WHEN ProductID IS NULL THEN 'ProductID nulo' END,
        CASE WHEN SellerID IS NULL THEN 'SellerID nulo' END,
        CASE WHEN FechaVenta IS NULL THEN 'FechaVenta nula' END,
        CASE WHEN Cantidad IS NULL OR Cantidad <= 0 THEN 'Cantidad invalida' END,
        CASE WHEN Precio IS NULL OR Precio <= 0 THEN 'Precio invalido' END,
        CASE WHEN CostoFlete IS NULL OR CostoFlete < 0 THEN 'CostoFlete invalido' END
    ), '') AS MotivoRechazo
FROM vw_stg_paso2;

-- COMMAND ----------

/* PASO 4: duplicados. Por cada OrderID se conserva una sola fila (prefiere la valida y la mas completa) */
CREATE OR REPLACE VIEW vw_stg_paso4 AS
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY OrderID
        ORDER BY (MotivoRechazo IS NULL) DESC, FechaEntregaReal DESC NULLS LAST, Calificacion DESC NULLS LAST
    ) AS rn
FROM vw_stg_paso3;

-- COMMAND ----------

/* =========================   TABLA LIMPIA   ========================= */
CREATE OR REPLACE TABLE STG_Ventas_Limpia AS
WITH stats AS (
    SELECT percentile_approx(Cantidad, 0.25) AS q1, percentile_approx(Cantidad, 0.75) AS q3
    FROM vw_stg_paso4
    WHERE MotivoRechazo IS NULL AND rn = 1
)
SELECT
    r.OrderID,
    r.CustomerID,
    r.NombreCliente,
    r.TipoCliente,
    r.ProductID,
    r.NombreProducto,
    r.Categoria,
    r.Subcategoria,
    r.FechaVenta,
    r.Ciudad,
    r.Estado,
    r.Region,
    r.CodigoPostal,
    r.SellerID,
    r.NombreVendedor,
    r.Cantidad,
    r.Precio,
    r.CostoFlete,
    r.FechaEntregaEstimada,
    r.FechaEntregaReal,
    r.Calificacion,
    r.Observaciones,
    -- valor atipico: Cantidad mayor que Q3 + 3 x (Q3 - Q1). Se conserva, solo se marca
    (r.Cantidad > s.q3 + 3 * (s.q3 - s.q1)) AS EsOutlierCantidad
FROM vw_stg_paso4 r
CROSS JOIN stats s
WHERE r.MotivoRechazo IS NULL AND r.rn = 1;

/* =========================   TABLA DE RECHAZADOS   ========================= */
CREATE OR REPLACE TABLE STG_Ventas_Rechazados AS
SELECT
    r.OrderID,
    r.CustomerID,
    r.NombreCliente,
    r.TipoCliente,
    r.ProductID,
    r.NombreProducto,
    r.Categoria,
    r.Subcategoria,
    r.FechaVenta,
    r.Ciudad,
    r.Estado,
    r.Region,
    r.CodigoPostal,
    r.SellerID,
    r.NombreVendedor,
    r.Cantidad,
    r.Precio,
    r.CostoFlete,
    r.FechaEntregaEstimada,
    r.FechaEntregaReal,
    r.Calificacion,
    concat_ws('; ', r.MotivoRechazo, CASE WHEN r.rn > 1 THEN 'OrderID duplicado' END) AS Motivo
FROM vw_stg_paso4 r
WHERE r.MotivoRechazo IS NOT NULL OR r.rn > 1;

-- COMMAND ----------

/* =========================   VERIFICACION   ========================= */
SELECT
    (SELECT COUNT(*) FROM STG_Ventas_Sucia)       AS FilasOrigen,
    (SELECT COUNT(*) FROM STG_Ventas_Limpia)      AS FilasLimpias,
    (SELECT COUNT(*) FROM STG_Ventas_Rechazados)  AS FilasRechazadas,
    CASE WHEN (SELECT COUNT(*) FROM STG_Ventas_Sucia) =
              (SELECT COUNT(*) FROM STG_Ventas_Limpia) + (SELECT COUNT(*) FROM STG_Ventas_Rechazados)
         THEN 'OK' ELSE 'REVISAR' END             AS Conciliacion;

-- COMMAND ----------

/* Por que se rechazo cada fila */
SELECT Motivo, COUNT(*) AS Filas FROM STG_Ventas_Rechazados GROUP BY Motivo ORDER BY Filas DESC;

-- COMMAND ----------

/* Que correcciones se aplicaron */
SELECT Observaciones, COUNT(*) AS Filas FROM STG_Ventas_Limpia WHERE Observaciones IS NOT NULL GROUP BY Observaciones;

-- COMMAND ----------

/* Valores atipicos marcados (no se eliminan) */
SELECT OrderID, CustomerID, Cantidad, Precio FROM STG_Ventas_Limpia WHERE EsOutlierCantidad ORDER BY Cantidad DESC;

-- COMMAND ----------

/* =========================   PERFILADO: DESPUES DE LIMPIAR (todo debe dar 0)   ========================= */
SELECT 'OrderID nulo o repetido' AS Regla, COUNT(*) - COUNT(DISTINCT OrderID) + SUM(CASE WHEN OrderID IS NULL THEN 1 ELSE 0 END) AS Filas FROM STG_Ventas_Limpia
UNION ALL SELECT 'Textos con espacios sobrantes', COUNT(*) FROM STG_Ventas_Limpia
    WHERE OrderID <> TRIM(OrderID) OR CustomerID <> TRIM(CustomerID) OR NombreCliente <> TRIM(NombreCliente)
       OR NombreCliente LIKE '%  %' OR Ciudad <> TRIM(Ciudad) OR SellerID <> TRIM(SellerID)
UNION ALL SELECT 'Datos de cliente, producto o vendedor nulos', COUNT(*) FROM STG_Ventas_Limpia
    WHERE NombreCliente IS NULL OR TipoCliente IS NULL OR Ciudad IS NULL OR Estado IS NULL OR Region IS NULL
       OR CodigoPostal IS NULL OR NombreProducto IS NULL OR Categoria IS NULL OR Subcategoria IS NULL OR NombreVendedor IS NULL
UNION ALL SELECT 'FechaVenta nula', COUNT(*) FROM STG_Ventas_Limpia WHERE FechaVenta IS NULL
UNION ALL SELECT 'Cantidad, Precio o CostoFlete invalidos', COUNT(*) FROM STG_Ventas_Limpia
    WHERE Cantidad <= 0 OR Precio <= 0 OR CostoFlete < 0
UNION ALL SELECT 'Calificacion fuera de 1 a 5', COUNT(*) FROM STG_Ventas_Limpia WHERE Calificacion NOT BETWEEN 1 AND 5
UNION ALL SELECT 'Fechas de entrega anteriores a la venta', COUNT(*) FROM STG_Ventas_Limpia
    WHERE FechaEntregaReal < FechaVenta OR FechaEntregaEstimada < FechaVenta;

/* Nota: Calificacion y FechaEntregaReal pueden seguir en NULL (pedido sin resena o sin entregar); es valido. */
