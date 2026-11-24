-- Databricks notebook source
-- MAGIC %md
-- MAGIC # NANOPARURO | Inteligencia de negocios
-- MAGIC Actividad 07 — Databricks / Delta Lake
-- MAGIC
-- MAGIC Datos base del notebook: 74 pedidos, marzo–junio de 2026. Instalación en un esquema nuevo para no modificar el proyecto existente. Ejecutar en orden y una sola vez. Si el esquema ya existe, elegir otro nombre antes de comenzar; no continuar tras un error. Se requiere un catálogo compatible con claves primarias y foráneas informativas.

-- COMMAND ----------

CREATE SCHEMA bi_nanoparuro_final;

-- COMMAND ----------

USE SCHEMA bi_nanoparuro_final;

-- COMMAND ----------

/* =========================   DIM_CLIENTE   ========================= */
CREATE TABLE DIM_CLIENTE (
    ClienteKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    CustomerID VARCHAR(50) NOT NULL,
    NombreCliente VARCHAR(150),
    TipoCliente VARCHAR(50),
    CONSTRAINT PK_DIM_CLIENTE PRIMARY KEY (ClienteKey)
);

-- COMMAND ----------

/* =========================   DIM_PRODUCTO   ========================= */
CREATE TABLE DIM_PRODUCTO (
    ProductoKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    ProductID VARCHAR(50) NOT NULL,
    NombreProducto VARCHAR(150),
    Categoria VARCHAR(100),
    Subcategoria VARCHAR(100),
    CONSTRAINT PK_DIM_PRODUCTO PRIMARY KEY (ProductoKey)
);

-- COMMAND ----------

/* =========================   DIM_FECHA   ========================= */
CREATE TABLE DIM_FECHA (
    FechaKey INT NOT NULL,
    Fecha DATE NOT NULL,
    Dia TINYINT NOT NULL,
    Mes TINYINT NOT NULL,
    NombreMes VARCHAR(20) NOT NULL,
    Trimestre TINYINT NOT NULL,
    Anio SMALLINT NOT NULL,
    CONSTRAINT PK_DIM_FECHA PRIMARY KEY (FechaKey)
);

-- COMMAND ----------

/* =========================   DIM_GEOGRAFIA   ========================= */
CREATE TABLE DIM_GEOGRAFIA (
    GeografiaKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    Ciudad VARCHAR(100) NOT NULL,
    Estado VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NOT NULL,
    CodigoPostal VARCHAR(20) NOT NULL,
    CONSTRAINT PK_DIM_GEOGRAFIA PRIMARY KEY (GeografiaKey)
);

-- COMMAND ----------

/* =========================   DIM_VENDEDOR   ========================= */
CREATE TABLE DIM_VENDEDOR (
    VendedorKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    SellerID VARCHAR(50) NOT NULL,
    NombreVendedor VARCHAR(150),
    CiudadVendedor VARCHAR(100),
    RegionVendedor VARCHAR(100),
    CONSTRAINT PK_DIM_VENDEDOR PRIMARY KEY (VendedorKey)
);

-- COMMAND ----------

/* =========================   STG_Ventas   ========================= */
CREATE TABLE STG_Ventas (
    OrderID VARCHAR(50) NOT NULL,
    CustomerID VARCHAR(50) NOT NULL,
    NombreCliente VARCHAR(150),
    TipoCliente VARCHAR(50),

    ProductID VARCHAR(50) NOT NULL,
    NombreProducto VARCHAR(150),
    Categoria VARCHAR(100),
    Subcategoria VARCHAR(100),

    FechaVenta DATE NOT NULL,

    Ciudad VARCHAR(100),
    Estado VARCHAR(100),
    Region VARCHAR(100),
    CodigoPostal VARCHAR(20),

    SellerID VARCHAR(50) NOT NULL,
    NombreVendedor VARCHAR(150),

    Cantidad INT NOT NULL,
    Precio DECIMAL(18,2) NOT NULL,
    CostoFlete DECIMAL(18,2) NOT NULL,

    FechaEntregaEstimada DATE,
    FechaEntregaReal DATE,           -- NULL = aun no entregado
    Calificacion TINYINT,            -- 1 a 5, NULL = sin reseña

    CONSTRAINT PK_STG_Ventas PRIMARY KEY (OrderID)
);

-- COMMAND ----------

ALTER TABLE STG_Ventas ADD CONSTRAINT CK_STG_Calificacion CHECK (Calificacion IS NULL OR Calificacion BETWEEN 1 AND 5);

-- COMMAND ----------

ALTER TABLE STG_Ventas ADD CONSTRAINT CK_STG_FechaEntrega CHECK (FechaEntregaReal IS NULL OR FechaEntregaReal >= FechaVenta);

-- COMMAND ----------

/* =========================   DATOS STG_Ventas   ========================= */
INSERT INTO STG_Ventas VALUES (
    'ORD-1001', 'CLI-01', ' Juan Perez ', 'Empresa',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-03-01', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-01', 'Carlos Gomez', 5, 45.00, 10.00,
    DATE'2026-03-06', DATE'2026-03-05', 5
),
(
    'ORD-1002', 'CLI-02', 'Maria Lopez', 'Final',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-03-02', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-02', 'Ana Torres', 2, 12.50, 5.00,
    DATE'2026-03-07', DATE'2026-03-09', 3
),
(
    'ORD-1003', 'CLI-01', 'Juan Perez', 'Empresa',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-03-03', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-01', 'Carlos Gomez', 10, 12.00, 8.00,
    DATE'2026-03-08', DATE'2026-03-07', 4
),
(
    'ORD-1004', 'CLI-03', '  Tech Solutions ', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-03-04', 'Trujillo', 'La Libertad', 'Trujillo', '13001',
    'VEN-01', 'Carlos Gomez', 20, 28.00, 15.00,
    DATE'2026-03-10', DATE'2026-03-14', 2
);

-- COMMAND ----------

/* =========================   DATOS ADICIONALES STG_Ventas (70 pedidos)   ========================= */
INSERT INTO STG_Ventas VALUES
(
    'ORD-1005', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-03-05', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-01', 'Carlos Gomez', 5, 7.00, 10.00,
    DATE'2026-03-09', DATE'2026-03-11', 1
),
(
    'ORD-1006', 'CLI-12', 'Andrea Paredes', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-03-06', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-03', 'Luis Ramirez', 2, 7.00, 10.00,
    DATE'2026-03-10', DATE'2026-03-12', 3
),
(
    'ORD-1007', 'CLI-02', 'Maria Lopez', 'Final',
    'PROD-05', 'Sensor Ultrasonico HC-SR04', 'Sensores', 'Distancia',
    DATE'2026-03-08', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-04', 'Rosa Quispe', 2, 7.60, 7.80,
    DATE'2026-03-15', DATE'2026-03-17', 1
),
(
    'ORD-1008', 'CLI-01', 'Juan Perez', 'Empresa',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-03-14', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-01', 'Carlos Gomez', 15, 13.20, 12.00,
    DATE'2026-03-18', DATE'2026-03-20', 1
),
(
    'ORD-1009', 'CLI-04', 'Luis Vargas', 'Final',
    'PROD-04', 'Raspberry Pi Pico', 'Microcontroladores', 'Placas',
    DATE'2026-03-15', 'Lima', 'Lima', 'Miraflores', '15074',
    'VEN-01', 'Carlos Gomez', 3, 17.10, 12.00,
    DATE'2026-03-19', DATE'2026-03-18', 5
),
(
    'ORD-1010', 'CLI-11', 'Mecatronica del Sur SRL', 'Empresa',
    'PROD-06', 'Modulo Rele 5V', 'Actuadores', 'Reles',
    DATE'2026-03-16', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-02', 'Ana Torres', 1, 6.50, 19.50,
    DATE'2026-03-23', NULL, NULL
),
(
    'ORD-1011', 'CLI-10', 'Carla Rojas', 'Final',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-03-17', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-04', 'Rosa Quispe', 4, 5.50, 15.60,
    DATE'2026-03-24', DATE'2026-03-24', 5
),
(
    'ORD-1012', 'CLI-03', 'Tech Solutions', 'Empresa',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-03-18', 'Trujillo', 'La Libertad', 'Trujillo', '13001',
    'VEN-05', 'Jorge Salazar', 5, 5.22, 13.00,
    DATE'2026-03-25', DATE'2026-03-24', 3
),
(
    'ORD-1013', 'CLI-10', 'Carla Rojas', 'Final',
    'PROD-05', 'Sensor Ultrasonico HC-SR04', 'Sensores', 'Distancia',
    DATE'2026-03-19', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-05', 'Jorge Salazar', 2, 8.40, 7.80,
    DATE'2026-03-26', DATE'2026-03-31', 3
),
(
    'ORD-1014', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-03-20', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-01', 'Carlos Gomez', 10, 42.75, 5.00,
    DATE'2026-03-24', DATE'2026-03-26', 2
),
(
    'ORD-1015', 'CLI-06', 'Rosa Medina', 'Final',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-03-23', 'Piura', 'Piura', 'Piura', '20001',
    'VEN-01', 'Carlos Gomez', 3, 47.25, 10.40,
    DATE'2026-03-30', DATE'2026-03-30', NULL
),
(
    'ORD-1016', 'CLI-02', 'Maria Lopez', 'Final',
    'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
    DATE'2026-03-31', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-04', 'Rosa Quispe', 3, 16.50, 7.80,
    DATE'2026-04-07', DATE'2026-04-06', 5
),
(
    'ORD-1017', 'CLI-04', 'Luis Vargas', 'Final',
    'PROD-07', 'Servomotor SG90', 'Actuadores', 'Motores',
    DATE'2026-04-02', 'Lima', 'Lima', 'Miraflores', '15074',
    'VEN-05', 'Jorge Salazar', 2, 9.45, 12.00,
    DATE'2026-04-06', DATE'2026-04-05', 5
),
(
    'ORD-1018', 'CLI-02', 'Maria Lopez', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-04-04', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-04', 'Rosa Quispe', 1, 7.00, 19.50,
    DATE'2026-04-11', DATE'2026-04-10', 4
),
(
    'ORD-1019', 'CLI-09', 'Innova Labs', 'Empresa',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-04-06', 'Huancayo', 'Junin', 'Huancayo', '12001',
    'VEN-04', 'Rosa Quispe', 50, 45.00, 13.00,
    DATE'2026-04-13', DATE'2026-04-10', 4
),
(
    'ORD-1020', 'CLI-09', 'Innova Labs', 'Empresa',
    'PROD-04', 'Raspberry Pi Pico', 'Microcontroladores', 'Placas',
    DATE'2026-04-10', 'Huancayo', 'Junin', 'Huancayo', '12001',
    'VEN-05', 'Jorge Salazar', 3, 18.00, 19.50,
    DATE'2026-04-17', DATE'2026-04-16', 5
),
(
    'ORD-1021', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-04-10', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-04', 'Rosa Quispe', 2, 7.35, 8.00,
    DATE'2026-04-14', DATE'2026-04-13', 4
),
(
    'ORD-1022', 'CLI-05', 'Electro Andina SAC', 'Empresa',
    'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
    DATE'2026-04-11', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-04', 'Rosa Quispe', 10, 15.00, 13.00,
    DATE'2026-04-18', DATE'2026-04-17', 4
),
(
    'ORD-1023', 'CLI-08', 'Diego Flores', 'Final',
    'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
    DATE'2026-04-13', 'Chiclayo', 'Lambayeque', 'Chiclayo', '14001',
    'VEN-01', 'Carlos Gomez', 3, 16.50, 10.40,
    DATE'2026-04-20', DATE'2026-04-18', 3
),
(
    'ORD-1024', 'CLI-04', 'Luis Vargas', 'Final',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-04-14', 'Lima', 'Lima', 'Miraflores', '15074',
    'VEN-01', 'Carlos Gomez', 2, 45.00, 10.00,
    DATE'2026-04-18', DATE'2026-04-18', 5
),
(
    'ORD-1025', 'CLI-11', 'Mecatronica del Sur SRL', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-04-14', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-01', 'Carlos Gomez', 10, 28.00, 10.40,
    DATE'2026-04-21', DATE'2026-04-26', 3
),
(
    'ORD-1026', 'CLI-09', 'Innova Labs', 'Empresa',
    'PROD-04', 'Raspberry Pi Pico', 'Microcontroladores', 'Placas',
    DATE'2026-04-17', 'Huancayo', 'Junin', 'Huancayo', '12001',
    'VEN-01', 'Carlos Gomez', 25, 18.00, 15.60,
    DATE'2026-04-24', DATE'2026-04-24', 5
),
(
    'ORD-1027', 'CLI-10', 'Carla Rojas', 'Final',
    'PROD-05', 'Sensor Ultrasonico HC-SR04', 'Sensores', 'Distancia',
    DATE'2026-04-18', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-05', 'Jorge Salazar', 1, 7.60, 10.40,
    DATE'2026-04-25', DATE'2026-04-23', 3
),
(
    'ORD-1028', 'CLI-03', 'Tech Solutions', 'Empresa',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-04-19', 'Trujillo', 'La Libertad', 'Trujillo', '13001',
    'VEN-01', 'Carlos Gomez', 10, 12.00, 19.50,
    DATE'2026-04-26', DATE'2026-04-24', 5
),
(
    'ORD-1029', 'CLI-05', 'Electro Andina SAC', 'Empresa',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-04-22', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-01', 'Carlos Gomez', 5, 5.50, 7.80,
    DATE'2026-04-29', DATE'2026-04-29', NULL
),
(
    'ORD-1030', 'CLI-01', 'Juan Perez', 'Empresa',
    'PROD-07', 'Servomotor SG90', 'Actuadores', 'Motores',
    DATE'2026-04-24', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-03', 'Luis Ramirez', 10, 8.55, 5.00,
    DATE'2026-04-28', DATE'2026-04-26', 4
),
(
    'ORD-1031', 'CLI-05', 'Electro Andina SAC', 'Empresa',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-04-27', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-01', 'Carlos Gomez', 50, 13.20, 15.60,
    DATE'2026-05-04', DATE'2026-05-05', 2
),
(
    'ORD-1032', 'CLI-08', 'Diego Flores', 'Final',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-04-30', 'Chiclayo', 'Lambayeque', 'Chiclayo', '14001',
    'VEN-05', 'Jorge Salazar', 1, 5.78, 10.40,
    DATE'2026-05-07', DATE'2026-05-07', 5
),
(
    'ORD-1033', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-05-01', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-03', 'Luis Ramirez', 20, 12.00, 10.00,
    DATE'2026-05-05', DATE'2026-05-04', 3
),
(
    'ORD-1034', 'CLI-06', 'Rosa Medina', 'Final',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-05-02', 'Piura', 'Piura', 'Piura', '20001',
    'VEN-04', 'Rosa Quispe', 1, 45.00, 19.50,
    DATE'2026-05-09', DATE'2026-05-10', 2
),
(
    'ORD-1035', 'CLI-02', 'Maria Lopez', 'Final',
    'PROD-05', 'Sensor Ultrasonico HC-SR04', 'Sensores', 'Distancia',
    DATE'2026-05-06', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-04', 'Rosa Quispe', 2, 8.80, 6.50,
    DATE'2026-05-13', DATE'2026-05-18', 4
),
(
    'ORD-1036', 'CLI-04', 'Luis Vargas', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-06', 'Lima', 'Lima', 'Miraflores', '15074',
    'VEN-01', 'Carlos Gomez', 4, 6.65, 6.00,
    DATE'2026-05-10', DATE'2026-05-10', 4
),
(
    'ORD-1037', 'CLI-01', 'Juan Perez', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-05-08', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-05', 'Jorge Salazar', 10, 30.80, 15.00,
    DATE'2026-05-12', DATE'2026-05-13', 2
),
(
    'ORD-1038', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-05-09', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-02', 'Ana Torres', 10, 5.78, 10.00,
    DATE'2026-05-13', DATE'2026-05-13', 4
),
(
    'ORD-1039', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-04', 'Raspberry Pi Pico', 'Microcontroladores', 'Placas',
    DATE'2026-05-09', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-02', 'Ana Torres', 3, 19.80, 5.00,
    DATE'2026-05-13', NULL, NULL
),
(
    'ORD-1040', 'CLI-11', 'Mecatronica del Sur SRL', 'Empresa',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-12', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-05', 'Jorge Salazar', 10, 7.00, 7.80,
    DATE'2026-05-19', DATE'2026-05-19', 4
),
(
    'ORD-1041', 'CLI-05', 'Electro Andina SAC', 'Empresa',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-14', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-04', 'Rosa Quispe', 10, 7.00, 10.40,
    DATE'2026-05-21', DATE'2026-05-20', 3
),
(
    'ORD-1042', 'CLI-10', 'Carla Rojas', 'Final',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-05-15', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-02', 'Ana Torres', 3, 11.40, 19.50,
    DATE'2026-05-22', DATE'2026-05-27', 3
),
(
    'ORD-1043', 'CLI-06', 'Rosa Medina', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-15', 'Piura', 'Piura', 'Piura', '20001',
    'VEN-03', 'Luis Ramirez', 1, 6.65, 19.50,
    DATE'2026-05-22', DATE'2026-05-22', 5
),
(
    'ORD-1044', 'CLI-04', 'Luis Vargas', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-17', 'Lima', 'Lima', 'Miraflores', '15074',
    'VEN-02', 'Ana Torres', 4, 7.35, 15.00,
    DATE'2026-05-21', DATE'2026-05-20', 3
),
(
    'ORD-1045', 'CLI-04', 'Luis Vargas', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-17', 'Lima', 'Lima', 'Miraflores', '15074',
    'VEN-03', 'Luis Ramirez', 2, 7.00, 8.00,
    DATE'2026-05-21', DATE'2026-05-20', 5
),
(
    'ORD-1046', 'CLI-08', 'Diego Flores', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-19', 'Chiclayo', 'Lambayeque', 'Chiclayo', '14001',
    'VEN-04', 'Rosa Quispe', 5, 7.70, 10.40,
    DATE'2026-05-26', DATE'2026-05-26', NULL
),
(
    'ORD-1047', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-05-20', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-04', 'Rosa Quispe', 1, 28.00, 12.00,
    DATE'2026-05-24', DATE'2026-05-25', 2
),
(
    'ORD-1048', 'CLI-01', 'Juan Perez', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-05-22', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-01', 'Carlos Gomez', 5, 28.00, 12.00,
    DATE'2026-05-26', DATE'2026-05-27', 2
),
(
    'ORD-1049', 'CLI-12', 'Andrea Paredes', 'Final',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-05-23', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-01', 'Carlos Gomez', 3, 12.00, 15.00,
    DATE'2026-05-27', DATE'2026-05-27', 4
),
(
    'ORD-1050', 'CLI-01', 'Juan Perez', 'Empresa',
    'PROD-07', 'Servomotor SG90', 'Actuadores', 'Motores',
    DATE'2026-05-25', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-04', 'Rosa Quispe', 20, 9.90, 15.00,
    DATE'2026-05-29', DATE'2026-05-30', NULL
),
(
    'ORD-1051', 'CLI-09', 'Innova Labs', 'Empresa',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-05-26', 'Huancayo', 'Junin', 'Huancayo', '12001',
    'VEN-01', 'Carlos Gomez', 3, 12.60, 10.40,
    DATE'2026-06-02', DATE'2026-06-07', 2
),
(
    'ORD-1052', 'CLI-01', 'Juan Perez', 'Empresa',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-05-26', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-02', 'Ana Torres', 3, 5.50, 8.00,
    DATE'2026-05-30', DATE'2026-05-30', 4
),
(
    'ORD-1053', 'CLI-03', 'Tech Solutions', 'Empresa',
    'PROD-07', 'Servomotor SG90', 'Actuadores', 'Motores',
    DATE'2026-05-30', 'Trujillo', 'La Libertad', 'Trujillo', '13001',
    'VEN-02', 'Ana Torres', 50, 8.55, 15.60,
    DATE'2026-06-06', DATE'2026-06-09', 4
),
(
    'ORD-1054', 'CLI-06', 'Rosa Medina', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-05-31', 'Piura', 'Piura', 'Piura', '20001',
    'VEN-02', 'Ana Torres', 4, 7.70, 6.50,
    DATE'2026-06-07', DATE'2026-06-06', 4
),
(
    'ORD-1055', 'CLI-03', 'Tech Solutions', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-06-03', 'Trujillo', 'La Libertad', 'Trujillo', '13001',
    'VEN-01', 'Carlos Gomez', 2, 30.80, 19.50,
    DATE'2026-06-10', DATE'2026-06-07', 3
),
(
    'ORD-1056', 'CLI-02', 'Maria Lopez', 'Final',
    'PROD-06', 'Modulo Rele 5V', 'Actuadores', 'Reles',
    DATE'2026-06-04', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-03', 'Luis Ramirez', 1, 7.15, 7.80,
    DATE'2026-06-11', DATE'2026-06-11', 4
),
(
    'ORD-1057', 'CLI-06', 'Rosa Medina', 'Final',
    'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
    DATE'2026-06-05', 'Piura', 'Piura', 'Piura', '20001',
    'VEN-01', 'Carlos Gomez', 5, 14.25, 13.00,
    DATE'2026-06-12', DATE'2026-06-12', 5
),
(
    'ORD-1058', 'CLI-11', 'Mecatronica del Sur SRL', 'Empresa',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-06-06', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-03', 'Luis Ramirez', 15, 12.60, 6.50,
    DATE'2026-06-13', DATE'2026-06-18', 2
),
(
    'ORD-1059', 'CLI-06', 'Rosa Medina', 'Final',
    'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
    DATE'2026-06-08', 'Piura', 'Piura', 'Piura', '20001',
    'VEN-05', 'Jorge Salazar', 2, 14.25, 6.50,
    DATE'2026-06-15', DATE'2026-06-13', 5
),
(
    'ORD-1060', 'CLI-05', 'Electro Andina SAC', 'Empresa',
    'PROD-05', 'Sensor Ultrasonico HC-SR04', 'Sensores', 'Distancia',
    DATE'2026-06-09', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-02', 'Ana Torres', 3, 8.00, 13.00,
    DATE'2026-06-16', DATE'2026-06-21', 3
),
(
    'ORD-1061', 'CLI-06', 'Rosa Medina', 'Final',
    'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
    DATE'2026-06-11', 'Piura', 'Piura', 'Piura', '20001',
    'VEN-04', 'Rosa Quispe', 2, 15.00, 7.80,
    DATE'2026-06-18', DATE'2026-06-21', 2
),
(
    'ORD-1062', 'CLI-12', 'Andrea Paredes', 'Final',
    'PROD-06', 'Modulo Rele 5V', 'Actuadores', 'Reles',
    DATE'2026-06-11', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-03', 'Luis Ramirez', 2, 7.15, 10.00,
    DATE'2026-06-15', DATE'2026-06-14', 4
),
(
    'ORD-1063', 'CLI-12', 'Andrea Paredes', 'Final',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-06-12', 'Lima', 'Lima', 'Cercado', '15001',
    'VEN-02', 'Ana Torres', 2, 5.50, 8.00,
    DATE'2026-06-16', DATE'2026-06-18', 1
),
(
    'ORD-1064', 'CLI-05', 'Electro Andina SAC', 'Empresa',
    'PROD-08', 'Pantalla OLED 0.96', 'Displays', 'Pantallas',
    DATE'2026-06-13', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-03', 'Luis Ramirez', 3, 16.50, 19.50,
    DATE'2026-06-20', DATE'2026-06-20', 4
),
(
    'ORD-1065', 'CLI-03', 'Tech Solutions', 'Empresa',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-06-16', 'Trujillo', 'La Libertad', 'Trujillo', '13001',
    'VEN-01', 'Carlos Gomez', 5, 7.00, 15.60,
    DATE'2026-06-23', DATE'2026-06-26', 3
),
(
    'ORD-1066', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-06-17', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-05', 'Jorge Salazar', 10, 47.25, 8.00,
    DATE'2026-06-21', DATE'2026-06-19', 5
),
(
    'ORD-1067', 'CLI-08', 'Diego Flores', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-06-17', 'Chiclayo', 'Lambayeque', 'Chiclayo', '14001',
    'VEN-05', 'Jorge Salazar', 1, 7.35, 10.40,
    DATE'2026-06-24', DATE'2026-06-25', 1
),
(
    'ORD-1068', 'CLI-07', 'Robotica Peru EIRL', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-06-20', 'Lima', 'Lima', 'San Isidro', '15036',
    'VEN-01', 'Carlos Gomez', 5, 30.80, 15.00,
    DATE'2026-06-24', DATE'2026-06-23', 4
),
(
    'ORD-1069', 'CLI-10', 'Carla Rojas', 'Final',
    'PROD-10', 'Sensor PIR HC-SR501', 'Sensores', 'Movimiento',
    DATE'2026-06-21', 'Arequipa', 'Arequipa', 'Arequipa', '04001',
    'VEN-04', 'Rosa Quispe', 5, 5.78, 13.00,
    DATE'2026-06-28', DATE'2026-06-29', 1
),
(
    'ORD-1070', 'CLI-04', 'Luis Vargas', 'Final',
    'PROD-02', 'Sensor DHT11', 'Sensores', 'Temperatura',
    DATE'2026-06-23', 'Lima', 'Lima', 'Miraflores', '15074',
    'VEN-03', 'Luis Ramirez', 2, 11.40, 6.00,
    DATE'2026-06-27', NULL, NULL
),
(
    'ORD-1071', 'CLI-08', 'Diego Flores', 'Final',
    'PROD-09', 'Protoboard 830 puntos', 'Accesorios', 'Prototipado',
    DATE'2026-06-25', 'Chiclayo', 'Lambayeque', 'Chiclayo', '14001',
    'VEN-03', 'Luis Ramirez', 3, 7.00, 6.50,
    DATE'2026-07-02', DATE'2026-07-07', 3
),
(
    'ORD-1072', 'CLI-09', 'Innova Labs', 'Empresa',
    'PROD-01', 'Arduino Uno R3', 'Microcontroladores', 'Placas',
    DATE'2026-06-26', 'Huancayo', 'Junin', 'Huancayo', '12001',
    'VEN-01', 'Carlos Gomez', 3, 45.00, 7.80,
    DATE'2026-07-03', DATE'2026-07-06', 2
),
(
    'ORD-1073', 'CLI-11', 'Mecatronica del Sur SRL', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-06-27', 'Cusco', 'Cusco', 'Cusco', '08001',
    'VEN-03', 'Luis Ramirez', 2, 30.80, 13.00,
    DATE'2026-07-04', DATE'2026-07-09', 3
),
(
    'ORD-1074', 'CLI-09', 'Innova Labs', 'Empresa',
    'PROD-03', 'ESP32 Wi-Fi', 'Microcontroladores', 'Placas',
    DATE'2026-06-27', 'Huancayo', 'Junin', 'Huancayo', '12001',
    'VEN-01', 'Carlos Gomez', 1, 28.00, 13.00,
    DATE'2026-07-04', DATE'2026-07-01', 4
);

-- COMMAND ----------

SELECT assert_true(COUNT(*) = 74 AND COUNT(DISTINCT OrderID) = 74, 'Carga incorrecta') FROM STG_Ventas;

-- COMMAND ----------

UPDATE STG_Ventas SET CodigoPostal = 'SIN CODIGO' WHERE CodigoPostal IS NULL OR TRIM(CodigoPostal) = '';

-- COMMAND ----------

INSERT INTO DIM_CLIENTE (CustomerID, NombreCliente, TipoCliente)
SELECT TRIM(CustomerID), MAX(TRIM(NombreCliente)), MAX(TRIM(TipoCliente)) FROM STG_Ventas GROUP BY TRIM(CustomerID);

-- COMMAND ----------

INSERT INTO DIM_PRODUCTO (ProductID, NombreProducto, Categoria, Subcategoria)
SELECT TRIM(ProductID), MAX(TRIM(NombreProducto)), MAX(TRIM(Categoria)), MAX(TRIM(Subcategoria)) FROM STG_Ventas GROUP BY TRIM(ProductID);

-- COMMAND ----------

/* =========================   CARGAR DIM_FECHA   ========================= */
INSERT INTO DIM_FECHA (FechaKey, Fecha, Dia, Mes, NombreMes, Trimestre, Anio)
SELECT
    CAST(date_format(FechaVenta, 'yyyyMMdd') AS INT),
    FechaVenta,
    DAY(FechaVenta),
    MONTH(FechaVenta),
    elt(MONTH(FechaVenta), 'Enero','Febrero','Marzo','Abril','Mayo','Junio',
                           'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'),
    QUARTER(FechaVenta),
    YEAR(FechaVenta)
FROM (SELECT EXPLODE(SEQUENCE(DATE'2026-01-01', DATE'2026-12-31', INTERVAL 1 DAY)) AS FechaVenta);

-- COMMAND ----------

/* =========================   CARGAR DIM_GEOGRAFIA   ========================= */
INSERT INTO DIM_GEOGRAFIA (Ciudad, Estado, Region, CodigoPostal)
SELECT
    TRIM(Ciudad),
    TRIM(Estado),
    TRIM(Region),
    TRIM(CodigoPostal)
FROM STG_Ventas
GROUP BY
    TRIM(Ciudad),
    TRIM(Estado),
    TRIM(Region),
    TRIM(CodigoPostal);

-- COMMAND ----------

/* =========================   CARGAR DIM_VENDEDOR   ========================= */
INSERT INTO DIM_VENDEDOR (SellerID, NombreVendedor, CiudadVendedor, RegionVendedor)
SELECT
    TRIM(SellerID),
    MAX(TRIM(NombreVendedor)),
    MAX(TRIM(Ciudad)),
    MAX(TRIM(Region))
FROM STG_Ventas
GROUP BY TRIM(SellerID);

-- COMMAND ----------

/* =========================   FACT_VENTAS   ========================= */
CREATE TABLE FACT_VENTAS (
    VentaKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,

    ClienteKey BIGINT NOT NULL,
    ProductoKey BIGINT NOT NULL,
    FechaKey INT NOT NULL,
    GeografiaKey BIGINT NOT NULL,
    VendedorKey BIGINT NOT NULL,

    OrderID VARCHAR(50) NOT NULL,
    Cantidad INT NOT NULL,
    Precio DECIMAL(18,2) NOT NULL,
    CostoFlete DECIMAL(18,2) NOT NULL,

    FechaEntregaEstimada DATE,
    FechaEntregaReal DATE,
    Calificacion TINYINT,
    DiasEntrega INT,                 -- FechaEntregaReal - FechaVenta
    EntregaTardia TINYINT,           -- 1 = tardia, 0 = a tiempo, NULL = no entregado

    ImporteTotal DECIMAL(18,2) GENERATED ALWAYS AS (
        CAST(Cantidad * Precio + CostoFlete AS DECIMAL(18,2))
    ),

    CONSTRAINT PK_FACT_VENTAS PRIMARY KEY (VentaKey),
    CONSTRAINT FK_FACT_CLIENTE   FOREIGN KEY (ClienteKey)   REFERENCES DIM_CLIENTE(ClienteKey),
    CONSTRAINT FK_FACT_PRODUCTO  FOREIGN KEY (ProductoKey)  REFERENCES DIM_PRODUCTO(ProductoKey),
    CONSTRAINT FK_FACT_FECHA     FOREIGN KEY (FechaKey)     REFERENCES DIM_FECHA(FechaKey),
    CONSTRAINT FK_FACT_GEOGRAFIA FOREIGN KEY (GeografiaKey) REFERENCES DIM_GEOGRAFIA(GeografiaKey),
    CONSTRAINT FK_FACT_VENDEDOR  FOREIGN KEY (VendedorKey)  REFERENCES DIM_VENDEDOR(VendedorKey)
);

-- COMMAND ----------

/* =========================   CARGAR FACT_VENTAS   ========================= */
INSERT INTO FACT_VENTAS (
    ClienteKey, ProductoKey, FechaKey, GeografiaKey, VendedorKey,
    OrderID, Cantidad, Precio, CostoFlete,
    FechaEntregaEstimada, FechaEntregaReal, Calificacion, DiasEntrega, EntregaTardia
)
SELECT
    c.ClienteKey,
    p.ProductoKey,
    f.FechaKey,
    g.GeografiaKey,
    v.VendedorKey,
    s.OrderID,
    s.Cantidad,
    s.Precio,
    s.CostoFlete,
    s.FechaEntregaEstimada,
    s.FechaEntregaReal,
    s.Calificacion,
    CASE WHEN s.FechaEntregaReal IS NULL THEN NULL
         ELSE datediff(s.FechaEntregaReal, s.FechaVenta) END,
    CASE WHEN s.FechaEntregaReal IS NULL OR s.FechaEntregaEstimada IS NULL THEN NULL
         WHEN s.FechaEntregaReal > s.FechaEntregaEstimada THEN 1
         ELSE 0 END
FROM STG_Ventas s
INNER JOIN DIM_CLIENTE c
    ON TRIM(s.CustomerID) = c.CustomerID
INNER JOIN DIM_PRODUCTO p
    ON TRIM(s.ProductID) = p.ProductID
INNER JOIN DIM_FECHA f
    ON CAST(date_format(s.FechaVenta, 'yyyyMMdd') AS INT) = f.FechaKey
INNER JOIN DIM_GEOGRAFIA g
    ON TRIM(s.Ciudad) = g.Ciudad
    AND TRIM(s.Estado) = g.Estado
    AND TRIM(s.Region) = g.Region
    AND TRIM(s.CodigoPostal) = g.CodigoPostal
INNER JOIN DIM_VENDEDOR v
    ON TRIM(s.SellerID) = v.SellerID;

-- COMMAND ----------

SELECT assert_true(COUNT(*) = 74 AND COUNT(DISTINCT OrderID) = 74, 'Revisar relaciones dimensionales') FROM FACT_VENTAS;

-- COMMAND ----------

CREATE TABLE ventas_limpias USING DELTA AS
SELECT
    TRIM(OrderID) AS OrderID,
    TRIM(CustomerID) AS CustomerID,
    TRIM(NombreCliente) AS NombreCliente,
    TRIM(TipoCliente) AS TipoCliente,
    TRIM(ProductID) AS ProductID,
    TRIM(NombreProducto) AS NombreProducto,
    TRIM(Categoria) AS Categoria,
    TRIM(Subcategoria) AS Subcategoria,
    FechaVenta,
    TRIM(Ciudad) AS Ciudad,
    TRIM(Estado) AS Estado,
    TRIM(Region) AS Region,
    TRIM(CodigoPostal) AS CodigoPostal,
    TRIM(SellerID) AS SellerID,
    TRIM(NombreVendedor) AS NombreVendedor,
    Cantidad,
    Precio,
    CostoFlete,
    FechaEntregaEstimada,
    FechaEntregaReal,
    Calificacion,

    CAST(Cantidad * Precio AS DECIMAL(30,2))
        AS ImporteVenta,

    DATEDIFF(FechaEntregaReal, FechaVenta)
        AS DiasEntrega,

    CASE
        WHEN FechaEntregaReal IS NULL
          OR FechaEntregaEstimada IS NULL
        THEN 'Sin datos suficientes'

        WHEN FechaEntregaReal <= FechaEntregaEstimada
        THEN 'A tiempo'

        ELSE 'Con retraso'
    END AS CumplimientoEntrega

FROM STG_Ventas;

-- COMMAND ----------

SELECT 'STG_Ventas' AS Tabla, COUNT(*) AS Registros
FROM STG_Ventas

UNION ALL

SELECT 'DIM_CLIENTE', COUNT(*)
FROM DIM_CLIENTE

UNION ALL

SELECT 'DIM_PRODUCTO', COUNT(*)
FROM DIM_PRODUCTO

UNION ALL

SELECT 'DIM_GEOGRAFIA', COUNT(*)
FROM DIM_GEOGRAFIA

UNION ALL

SELECT 'DIM_FECHA', COUNT(*)
FROM DIM_FECHA

UNION ALL

SELECT 'DIM_VENDEDOR', COUNT(*)
FROM DIM_VENDEDOR

UNION ALL

SELECT 'FACT_VENTAS', COUNT(*)
FROM FACT_VENTAS

UNION ALL

SELECT 'ventas_limpias', COUNT(*)
FROM ventas_limpias;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID) AS Duplicados,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    SUM(Cantidad) AS UnidadesVendidas,
    ROUND(SUM(ImporteVenta), 2) AS VentasTotales,
    ROUND(SUM(CostoFlete), 2) AS CostoTotalFlete,
    MIN(FechaVenta) AS PrimeraVenta,
    MAX(FechaVenta) AS UltimaVenta
FROM ventas_limpias;

-- COMMAND ----------

/* Ventas por mes y categoria */
SELECT f.Anio, f.Mes, f.NombreMes, p.Categoria, SUM(v.ImporteTotal) AS Ventas
FROM FACT_VENTAS v
INNER JOIN DIM_FECHA    f ON f.FechaKey    = v.FechaKey
INNER JOIN DIM_PRODUCTO p ON p.ProductoKey = v.ProductoKey
GROUP BY f.Anio, f.Mes, f.NombreMes, p.Categoria
ORDER BY f.Anio, f.Mes, Ventas DESC;

-- COMMAND ----------

/* Ventas por ciudad del cliente */
SELECT g.Ciudad, SUM(v.ImporteTotal) AS Ventas, COUNT(DISTINCT v.OrderID) AS Ordenes
FROM FACT_VENTAS v
INNER JOIN DIM_GEOGRAFIA g ON g.GeografiaKey = v.GeografiaKey
GROUP BY g.Ciudad
ORDER BY Ventas DESC;

-- COMMAND ----------

/* Ventas por vendedor */
SELECT s.SellerID, s.NombreVendedor, SUM(v.ImporteTotal) AS Ventas, COUNT(DISTINCT v.OrderID) AS Ordenes
FROM FACT_VENTAS v
INNER JOIN DIM_VENDEDOR s ON s.VendedorKey = v.VendedorKey
GROUP BY s.SellerID, s.NombreVendedor
ORDER BY Ventas DESC;

-- COMMAND ----------

/* Clientes recurrentes (mas de un pedido) */
SELECT c.CustomerID, c.NombreCliente, COUNT(DISTINCT v.OrderID) AS Pedidos, SUM(v.ImporteTotal) AS Gasto
FROM FACT_VENTAS v
INNER JOIN DIM_CLIENTE c ON c.ClienteKey = v.ClienteKey
GROUP BY c.CustomerID, c.NombreCliente
HAVING COUNT(DISTINCT v.OrderID) > 1;

-- COMMAND ----------

/* Entrega y satisfaccion por mes */
SELECT f.Anio, f.Mes, f.NombreMes,
       CAST(AVG(CAST(v.DiasEntrega  AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS DiasEntrega,
       CAST(AVG(CAST(v.Calificacion AS DECIMAL(5,2)))  AS DECIMAL(4,2))  AS Calificacion,
       CAST(100.0 * SUM(CAST(v.EntregaTardia AS INT)) / NULLIF(COUNT(v.EntregaTardia), 0) AS DECIMAL(5,2)) AS EntregaTardiaPct
FROM FACT_VENTAS v
INNER JOIN DIM_FECHA f ON f.FechaKey = v.FechaKey
GROUP BY f.Anio, f.Mes, f.NombreMes
ORDER BY f.Anio, f.Mes;

-- COMMAND ----------

/* Entrega y satisfaccion por vendedor */
SELECT s.SellerID, s.NombreVendedor,
       CAST(AVG(CAST(v.DiasEntrega  AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS DiasEntrega,
       CAST(AVG(CAST(v.Calificacion AS DECIMAL(5,2)))  AS DECIMAL(4,2))  AS Calificacion,
       CAST(100.0 * SUM(CAST(v.EntregaTardia AS INT)) / NULLIF(COUNT(v.EntregaTardia), 0) AS DECIMAL(5,2)) AS EntregaTardiaPct
FROM FACT_VENTAS v
INNER JOIN DIM_VENDEDOR s ON s.VendedorKey = v.VendedorKey
GROUP BY s.SellerID, s.NombreVendedor
ORDER BY EntregaTardiaPct DESC;

-- COMMAND ----------

SELECT
    OrderID,
    CustomerID,
    NombreCliente,
    TipoCliente,
    ProductID,
    NombreProducto,
    Categoria,
    Subcategoria,
    FechaVenta,
    Ciudad,
    Estado,
    Region,
    CodigoPostal,
    SellerID,
    NombreVendedor,
    Cantidad,
    Precio,
    CostoFlete
FROM bi_nanoparuro.STG_Ventas
ORDER BY OrderID;

-- COMMAND ----------

SELECT *
FROM bi_nanoparuro.STG_Ventas;