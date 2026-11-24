-- Databricks notebook source
/* ======================================================================
   BI_Nanoparuro - version Databricks (Spark SQL / Delta)
   Convertido desde T-SQL. Esquema: bi_nanoparuro
   Si quieres otro catalogo, descomenta la linea USE CATALOG.
   ====================================================================== */

-- USE CATALOG mi_catalogo;
DROP SCHEMA IF EXISTS bi_nanoparuro CASCADE;
CREATE SCHEMA bi_nanoparuro;
USE SCHEMA bi_nanoparuro;

-- COMMAND ----------

/* =========================   DIM_CLIENTE   ========================= */
CREATE TABLE DIM_CLIENTE (
    ClienteKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    CustomerID VARCHAR(50) NOT NULL,
    NombreCliente VARCHAR(150),
    TipoCliente VARCHAR(50),
    CONSTRAINT PK_DIM_CLIENTE PRIMARY KEY (ClienteKey)
);

/* =========================   DIM_PRODUCTO   ========================= */
CREATE TABLE DIM_PRODUCTO (
    ProductoKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    ProductID VARCHAR(50) NOT NULL,
    NombreProducto VARCHAR(150),
    Categoria VARCHAR(100),
    Subcategoria VARCHAR(100),
    CONSTRAINT PK_DIM_PRODUCTO PRIMARY KEY (ProductoKey)
);

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

/* =========================   DIM_GEOGRAFIA   ========================= */
CREATE TABLE DIM_GEOGRAFIA (
    GeografiaKey BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
    Ciudad VARCHAR(100) NOT NULL,
    Estado VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NOT NULL,
    CodigoPostal VARCHAR(20) NOT NULL,
    CONSTRAINT PK_DIM_GEOGRAFIA PRIMARY KEY (GeografiaKey)
);

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

ALTER TABLE STG_Ventas ADD CONSTRAINT CK_STG_Calificacion CHECK (Calificacion IS NULL OR Calificacion BETWEEN 1 AND 5);
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

/* =========================   CARGAR DIM_CLIENTE   ========================= */
INSERT INTO DIM_CLIENTE (CustomerID, NombreCliente, TipoCliente)
SELECT
    TRIM(CustomerID),
    TRIM(NombreCliente),
    TRIM(TipoCliente)
FROM STG_Ventas
GROUP BY
    TRIM(CustomerID),
    TRIM(NombreCliente),
    TRIM(TipoCliente);

/* =========================   CARGAR DIM_PRODUCTO   ========================= */
INSERT INTO DIM_PRODUCTO (ProductID, NombreProducto, Categoria, Subcategoria)
SELECT
    TRIM(ProductID),
    TRIM(NombreProducto),
    TRIM(Categoria),
    TRIM(Subcategoria)
FROM STG_Ventas
GROUP BY
    TRIM(ProductID),
    TRIM(NombreProducto),
    TRIM(Categoria),
    TRIM(Subcategoria);

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
FROM STG_Ventas
GROUP BY FechaVenta;

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

/* =========================   VERIFICACION DE CARGA   ========================= */
SELECT
    (SELECT COUNT(*) FROM STG_Ventas)    AS FilasStaging,
    (SELECT COUNT(*) FROM FACT_VENTAS)   AS FilasHechos,
    CASE WHEN (SELECT COUNT(*) FROM STG_Ventas) = (SELECT COUNT(*) FROM FACT_VENTAS)
         THEN 'OK' ELSE 'REVISAR' END    AS Conciliacion;

/* =========================   KPIs DEL PROYECTO   ========================= */
CREATE OR REPLACE VIEW vw_KPI_General
AS
SELECT
    SUM(ImporteTotal)          AS VentasTotales,
    COUNT(DISTINCT OrderID)    AS Ordenes,
    CAST(SUM(ImporteTotal) / NULLIF(COUNT(DISTINCT OrderID), 0)    AS DECIMAL(18,2)) AS TicketPromedio,
    COUNT(DISTINCT ClienteKey) AS Clientes,
    CAST(SUM(ImporteTotal) / NULLIF(COUNT(DISTINCT ClienteKey), 0) AS DECIMAL(18,2)) AS TicketPorCliente,
    CAST(AVG(CAST(Calificacion AS DECIMAL(5,2))) AS DECIMAL(4,2))                     AS Calificacion,
    CAST(AVG(CAST(DiasEntrega  AS DECIMAL(10,2))) AS DECIMAL(10,2))                   AS DiasEntrega,
    CAST(100.0 * SUM(CAST(EntregaTardia AS INT)) / NULLIF(COUNT(EntregaTardia), 0)
         AS DECIMAL(5,2))                                                              AS EntregaTardiaPct
FROM FACT_VENTAS;

SELECT * FROM vw_KPI_General;

-- COMMAND ----------

/* Ventas por mes y categoria */
SELECT f.Anio, f.Mes, f.NombreMes, p.Categoria, SUM(v.ImporteTotal) AS Ventas
FROM FACT_VENTAS v
INNER JOIN DIM_FECHA    f ON f.FechaKey    = v.FechaKey
INNER JOIN DIM_PRODUCTO p ON p.ProductoKey = v.ProductoKey
GROUP BY f.Anio, f.Mes, f.NombreMes, p.Categoria
ORDER BY f.Anio, f.Mes, Ventas DESC;

/* Ventas por ciudad del cliente */
SELECT g.Ciudad, SUM(v.ImporteTotal) AS Ventas, COUNT(DISTINCT v.OrderID) AS Ordenes
FROM FACT_VENTAS v
INNER JOIN DIM_GEOGRAFIA g ON g.GeografiaKey = v.GeografiaKey
GROUP BY g.Ciudad
ORDER BY Ventas DESC;

/* Ventas por vendedor */
SELECT s.SellerID, s.NombreVendedor, SUM(v.ImporteTotal) AS Ventas, COUNT(DISTINCT v.OrderID) AS Ordenes
FROM FACT_VENTAS v
INNER JOIN DIM_VENDEDOR s ON s.VendedorKey = v.VendedorKey
GROUP BY s.SellerID, s.NombreVendedor
ORDER BY Ventas DESC;

/* Clientes recurrentes (mas de un pedido) */
SELECT c.CustomerID, c.NombreCliente, COUNT(DISTINCT v.OrderID) AS Pedidos, SUM(v.ImporteTotal) AS Gasto
FROM FACT_VENTAS v
INNER JOIN DIM_CLIENTE c ON c.ClienteKey = v.ClienteKey
GROUP BY c.CustomerID, c.NombreCliente
HAVING COUNT(DISTINCT v.OrderID) > 1;

/* Entrega y satisfaccion por mes */
SELECT f.Anio, f.Mes, f.NombreMes,
       CAST(AVG(CAST(v.DiasEntrega  AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS DiasEntrega,
       CAST(AVG(CAST(v.Calificacion AS DECIMAL(5,2)))  AS DECIMAL(4,2))  AS Calificacion,
       CAST(100.0 * SUM(CAST(v.EntregaTardia AS INT)) / NULLIF(COUNT(v.EntregaTardia), 0) AS DECIMAL(5,2)) AS EntregaTardiaPct
FROM FACT_VENTAS v
INNER JOIN DIM_FECHA f ON f.FechaKey = v.FechaKey
GROUP BY f.Anio, f.Mes, f.NombreMes
ORDER BY f.Anio, f.Mes;

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

USE bi_nanoparuro;

SELECT COUNT(*) AS TotalRegistros
FROM STG_Ventas;

-- COMMAND ----------

DESCRIBE TABLE STG_Ventas;

-- COMMAND ----------

INSERT INTO bi_nanoparuro.STG_Ventas (
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
    CostoFlete,
    FechaEntregaEstimada,
    FechaEntregaReal,
    Calificacion
)
WITH base AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY OrderID) AS fila
    FROM bi_nanoparuro.STG_Ventas
    WHERE OrderID NOT LIKE 'ORD-SIM-%'
),
total AS (
    SELECT COUNT(*) AS cantidad FROM base
),
generados AS (
    SELECT
        id,
        DATE_ADD(
            DATE '2026-01-01',
            CAST(FLOOR(RAND(42) * 365) AS INT)
        ) AS NuevaFecha,
        CAST(FLOOR(RAND(43) * 30) + 1 AS INT)
            AS NuevaCantidad,
        CAST(ROUND(5 + RAND(44) * 45, 2)
            AS DECIMAL(18,2)) AS NuevoFlete,
        CAST(FLOOR(RAND(45) * 7) + 3 AS INT)
            AS DiasEstimados,
        CAST(FLOOR(RAND(46) * 12) + 1 AS INT)
            AS DiasReales,
        CAST(FLOOR(RAND(47) * 5) + 1 AS TINYINT)
            AS NuevaCalificacion
    FROM RANGE(10000)
)
SELECT
    CONCAT('ORD-SIM-', LPAD(CAST(g.id + 1 AS STRING), 6, '0')),
    b.CustomerID,
    TRIM(b.NombreCliente),
    b.TipoCliente,
    b.ProductID,
    b.NombreProducto,
    b.Categoria,
    b.Subcategoria,
    g.NuevaFecha,
    b.Ciudad,
    b.Estado,
    b.Region,
    b.CodigoPostal,
    b.SellerID,
    b.NombreVendedor,
    g.NuevaCantidad,
    b.Precio,
    g.NuevoFlete,
    DATE_ADD(g.NuevaFecha, g.DiasEstimados),
    DATE_ADD(g.NuevaFecha, g.DiasReales),
    g.NuevaCalificacion
FROM generados g
CROSS JOIN total t
JOIN base b
    ON b.fila = PMOD(g.id, t.cantidad) + 1
WHERE NOT EXISTS (
    SELECT 1
    FROM bi_nanoparuro.STG_Ventas s
    WHERE s.OrderID = CONCAT(
        'ORD-SIM-',
        LPAD(CAST(g.id + 1 AS STRING), 6, '0')
    )
);

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    MIN(FechaVenta) AS PrimeraVenta,
    MAX(FechaVenta) AS UltimaVenta
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

INSERT INTO bi_nanoparuro.STG_Ventas (
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
    CostoFlete,
    FechaEntregaEstimada,
    FechaEntregaReal,
    Calificacion
)
WITH base AS (
    SELECT *,
        ROW_NUMBER() OVER (
            ORDER BY OrderID
        ) AS fila
    FROM bi_nanoparuro.STG_Ventas
    WHERE OrderID NOT LIKE 'ORD-SIM-%'
),
total AS (
    SELECT COUNT(*) AS cantidad
    FROM base
),
generados AS (
    SELECT
        id,
        PMOD(id, 238) + 13 AS ClienteNuevo,
        PMOD(id, 40) + 11 AS ProductoNuevo,
        DATE_ADD(
            DATE '2026-01-01',
            CAST(FLOOR(RAND(51) * 365) AS INT)
        ) AS NuevaFecha,
        CAST(FLOOR(RAND(52) * 25) + 1 AS INT)
            AS NuevaCantidad,
        CAST(ROUND(5 + RAND(53) * 40, 2)
            AS DECIMAL(18,2)) AS NuevoFlete,
        CAST(FLOOR(RAND(54) * 7) + 3 AS INT)
            AS DiasEstimados,
        CAST(FLOOR(RAND(55) * 12) + 1 AS INT)
            AS DiasReales,
        CAST(FLOOR(RAND(56) * 5) + 1 AS TINYINT)
            AS NuevaCalificacion
    FROM RANGE(10000)
),
productos AS (
    SELECT
        id + 11 AS Numero,
        ELEMENT_AT(
            ARRAY(
                'Arduino Mega 2560',
                'Arduino Nano',
                'ESP8266 NodeMCU',
                'ESP32-C3',
                'ESP32-S3',
                'STM32 Blue Pill',
                'Raspberry Pi Pico W',
                'Arduino Leonardo',
                'Sensor DHT22',
                'Sensor BMP280',
                'Sensor BME280',
                'Sensor MQ-2',
                'Sensor MQ-135',
                'Sensor de lluvia',
                'Sensor de humedad de suelo',
                'Sensor de luz LDR',
                'Sensor de sonido',
                'Sensor MPU6050',
                'Sensor infrarrojo',
                'Sensor Hall',
                'Display LCD 16x2',
                'Display LCD 20x4',
                'Pantalla TFT 1.8',
                'Pantalla TFT 2.4',
                'Pantalla OLED 1.3',
                'Display 7 segmentos',
                'Matriz LED 8x8',
                'Motor DC 6V',
                'Motor paso a paso',
                'Servomotor MG996R',
                'Modulo L298N',
                'Modulo L293D',
                'Modulo Rele 4 canales',
                'Zumbador activo',
                'Protoboard 400 puntos',
                'Cables Dupont',
                'Kit de resistencias',
                'Kit de capacitores',
                'Modulo Bluetooth HC-05',
                'Modulo lector RFID'
            ),
            CAST(id + 1 AS INT)
        ) AS Nombre,
        CASE
            WHEN id < 8 THEN 'Microcontroladores'
            WHEN id < 20 THEN 'Sensores'
            WHEN id < 27 THEN 'Displays'
            WHEN id < 34 THEN 'Actuadores'
            ELSE 'Accesorios'
        END AS CategoriaNueva,
        CASE
            WHEN id < 8 THEN 'Placas'
            WHEN id < 20 THEN 'Deteccion y medicion'
            WHEN id < 27 THEN 'Pantallas'
            WHEN id < 34 THEN 'Control y movimiento'
            ELSE 'Componentes electronicos'
        END AS SubcategoriaNueva,
        CAST(
            ROUND(5 + PMOD(id * 17, 145), 2)
            AS DECIMAL(18,2)
        ) AS PrecioNuevo
    FROM RANGE(40)
)
SELECT
    CONCAT(
        'ORD-SIM-EXT-',
        LPAD(CAST(g.id + 1 AS STRING), 6, '0')
    ),
    CONCAT(
        'CLI-SIM-',
        LPAD(CAST(g.ClienteNuevo AS STRING), 3, '0')
    ),
    CASE
        WHEN PMOD(g.ClienteNuevo, 3) = 0
        THEN CONCAT('Empresa Simulada ', g.ClienteNuevo)
        ELSE CONCAT('Cliente Simulado ', g.ClienteNuevo)
    END,
    CASE
        WHEN PMOD(g.ClienteNuevo, 3) = 0
        THEN 'Empresa'
        ELSE 'Final'
    END,
    CONCAT(
        'PROD-SIM-',
        LPAD(CAST(p.Numero AS STRING), 3, '0')
    ),
    p.Nombre,
    p.CategoriaNueva,
    p.SubcategoriaNueva,
    g.NuevaFecha,
    b.Ciudad,
    b.Estado,
    b.Region,
    b.CodigoPostal,
    b.SellerID,
    b.NombreVendedor,
    g.NuevaCantidad,
    p.PrecioNuevo,
    g.NuevoFlete,
    DATE_ADD(g.NuevaFecha, g.DiasEstimados),
    DATE_ADD(g.NuevaFecha, g.DiasReales),
    g.NuevaCalificacion
FROM generados g
CROSS JOIN total t
JOIN base b
    ON b.fila = PMOD(g.id, t.cantidad) + 1
JOIN productos p
    ON p.Numero = g.ProductoNuevo
WHERE NOT EXISTS (
    SELECT 1
    FROM bi_nanoparuro.STG_Ventas s
    WHERE s.OrderID = CONCAT(
        'ORD-SIM-EXT-',
        LPAD(CAST(g.id + 1 AS STRING), 6, '0')
    )
);

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    COUNT(DISTINCT Region) AS TotalRegiones,
    MIN(FechaVenta) AS PrimeraVenta,
    MAX(FechaVenta) AS UltimaVenta
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

SELECT
    OrderID,
    COUNT(*) AS VecesRepetido
FROM bi_nanoparuro.STG_Ventas
GROUP BY OrderID
HAVING COUNT(*) > 1
ORDER BY VecesRepetido DESC;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(*) - (
        SELECT COUNT(*)
        FROM (
            SELECT DISTINCT *
            FROM bi_nanoparuro.STG_Ventas
        ) d
    ) AS DuplicadosExactos
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS
    bi_nanoparuro.STG_Ventas_Respaldo
USING DELTA
AS
SELECT *
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

CREATE OR REPLACE TABLE
    bi_nanoparuro.STG_Ventas_Limpieza
USING DELTA
AS
SELECT DISTINCT *
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

INSERT OVERWRITE TABLE bi_nanoparuro.STG_Ventas
SELECT *
FROM bi_nanoparuro.STG_Ventas_Limpieza;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID)
        AS RegistrosAdicionales,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    COUNT(DISTINCT Region) AS TotalRegiones
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

SELECT
    Ciudad,
    Estado,
    Region,
    CodigoPostal,
    COUNT(*) AS TotalVentas
FROM bi_nanoparuro.STG_Ventas
GROUP BY
    Ciudad,
    Estado,
    Region,
    CodigoPostal
ORDER BY Estado, Region;

-- COMMAND ----------

CREATE OR REPLACE TABLE bi_nanoparuro.Catalogo_Regiones
USING DELTA
AS
SELECT * FROM VALUES
    (1, 'Chachapoyas', 'Amazonas'),
    (2, 'Huaraz', 'Áncash'),
    (3, 'Abancay', 'Apurímac'),
    (4, 'Arequipa', 'Arequipa'),
    (5, 'Ayacucho', 'Ayacucho'),
    (6, 'Cajamarca', 'Cajamarca'),
    (7, 'Cusco', 'Cusco'),
    (8, 'Huancavelica', 'Huancavelica'),
    (9, 'Huánuco', 'Huánuco'),
    (10, 'Ica', 'Ica'),
    (11, 'Huancayo', 'Junín'),
    (12, 'Trujillo', 'La Libertad'),
    (13, 'Chiclayo', 'Lambayeque'),
    (14, 'Lima', 'Lima'),
    (15, 'Iquitos', 'Loreto'),
    (16, 'Puerto Maldonado', 'Madre de Dios'),
    (17, 'Moquegua', 'Moquegua'),
    (18, 'Cerro de Pasco', 'Pasco'),
    (19, 'Piura', 'Piura'),
    (20, 'Puno', 'Puno'),
    (21, 'Moyobamba', 'San Martín'),
    (22, 'Tacna', 'Tacna'),
    (23, 'Tumbes', 'Tumbes'),
    (24, 'Pucallpa', 'Ucayali')
AS regiones(IDRegion, Ciudad, Departamento);

-- COMMAND ----------

SELECT *
FROM bi_nanoparuro.Catalogo_Regiones
ORDER BY IDRegion;

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS
    bi_nanoparuro.STG_Ventas_Respaldo_Geografia
USING DELTA
AS
SELECT *
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

MERGE INTO bi_nanoparuro.STG_Ventas AS v
USING (
    SELECT
        s.OrderID,
        r.Ciudad,
        r.Departamento
    FROM (
        SELECT
            OrderID,
            PMOD(
                ROW_NUMBER() OVER (
                    ORDER BY OrderID
                ) - 1,
                24
            ) + 1 AS IDRegion
        FROM bi_nanoparuro.STG_Ventas
        WHERE OrderID LIKE 'ORD-SIM-%'
    ) s
    INNER JOIN bi_nanoparuro.Catalogo_Regiones r
        ON s.IDRegion = r.IDRegion
) AS nueva

ON v.OrderID = nueva.OrderID

WHEN MATCHED THEN
UPDATE SET
    v.Ciudad = nueva.Ciudad,
    v.Estado = nueva.Departamento,
    v.Region = nueva.Departamento,
    v.CodigoPostal = NULL;

-- COMMAND ----------

UPDATE bi_nanoparuro.STG_Ventas
SET
    Estado = CASE
        WHEN Estado = 'Junin' THEN 'Junín'
        ELSE Estado
    END,
    Region = CASE
        WHEN Estado = 'Junin' THEN 'Junín'
        ELSE Estado
    END
WHERE OrderID NOT LIKE 'ORD-SIM-%';

-- COMMAND ----------

SELECT
    Region,
    COUNT(DISTINCT OrderID) AS TotalPedidos
FROM bi_nanoparuro.STG_Ventas
GROUP BY Region
ORDER BY Region;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID)
        AS Duplicados,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    COUNT(DISTINCT Region) AS TotalRegiones
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

SHOW TABLES IN bi_nanoparuro;

-- COMMAND ----------

DESCRIBE TABLE bi_nanoparuro.DIM_CLIENTE;

-- COMMAND ----------

SHOW CREATE TABLE bi_nanoparuro.DIM_CLIENTE;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalClientes,
    COUNT(DISTINCT CustomerID) AS ClientesUnicos,
    COUNT(*) - COUNT(DISTINCT CustomerID) AS Duplicados
FROM bi_nanoparuro.DIM_CLIENTE;

-- COMMAND ----------

SELECT
    CustomerID,
    COUNT(DISTINCT TRIM(NombreCliente)) AS Nombres,
    COUNT(DISTINCT TRIM(TipoCliente)) AS Tipos
FROM bi_nanoparuro.STG_Ventas
GROUP BY CustomerID
HAVING COUNT(DISTINCT TRIM(NombreCliente)) > 1
    OR COUNT(DISTINCT TRIM(TipoCliente)) > 1;

-- COMMAND ----------

MERGE INTO bi_nanoparuro.DIM_CLIENTE AS destino
USING (
    SELECT
        CustomerID,
        MAX(TRIM(NombreCliente)) AS NombreCliente,
        MAX(TRIM(TipoCliente)) AS TipoCliente
    FROM bi_nanoparuro.STG_Ventas
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS origen

ON destino.CustomerID = origen.CustomerID

WHEN NOT MATCHED THEN
    INSERT (
        CustomerID,
        NombreCliente,
        TipoCliente
    )
    VALUES (
        origen.CustomerID,
        origen.NombreCliente,
        origen.TipoCliente
    );

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalClientes,
    COUNT(DISTINCT CustomerID) AS ClientesUnicos,
    COUNT(*) - COUNT(DISTINCT CustomerID) AS Duplicados
FROM bi_nanoparuro.DIM_CLIENTE;

-- COMMAND ----------

SHOW CREATE TABLE bi_nanoparuro.DIM_PRODUCTO;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalProductos,
    COUNT(DISTINCT ProductID) AS ProductosUnicos,
    COUNT(*) - COUNT(DISTINCT ProductID) AS Duplicados
FROM bi_nanoparuro.DIM_PRODUCTO;

-- COMMAND ----------

SELECT
    ProductID,
    COUNT(DISTINCT TRIM(NombreProducto)) AS Nombres,
    COUNT(DISTINCT TRIM(Categoria)) AS Categorias,
    COUNT(DISTINCT TRIM(Subcategoria)) AS Subcategorias
FROM bi_nanoparuro.STG_Ventas
GROUP BY ProductID
HAVING COUNT(DISTINCT TRIM(NombreProducto)) > 1
    OR COUNT(DISTINCT TRIM(Categoria)) > 1
    OR COUNT(DISTINCT TRIM(Subcategoria)) > 1;

-- COMMAND ----------

MERGE INTO bi_nanoparuro.DIM_PRODUCTO AS destino
USING (
    SELECT DISTINCT
        ProductID,
        TRIM(NombreProducto) AS NombreProducto,
        TRIM(Categoria) AS Categoria,
        TRIM(Subcategoria) AS Subcategoria
    FROM bi_nanoparuro.STG_Ventas
    WHERE ProductID IS NOT NULL
) AS origen
ON destino.ProductID = origen.ProductID

WHEN NOT MATCHED THEN
INSERT (
    ProductID,
    NombreProducto,
    Categoria,
    Subcategoria
)
VALUES (
    origen.ProductID,
    origen.NombreProducto,
    origen.Categoria,
    origen.Subcategoria
);

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalProductos,
    COUNT(DISTINCT ProductID) AS ProductosUnicos,
    COUNT(*) - COUNT(DISTINCT ProductID) AS Duplicados
FROM bi_nanoparuro.DIM_PRODUCTO;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC # Verificar las estructuras y registros de las tablas
-- MAGIC
-- MAGIC tablas = [
-- MAGIC     "DIM_GEOGRAFIA",
-- MAGIC     "DIM_FECHA",
-- MAGIC     "DIM_VENDEDOR",
-- MAGIC     "FACT_VENTAS"
-- MAGIC ]
-- MAGIC
-- MAGIC for tabla in tablas:
-- MAGIC     df = spark.table(f"bi_nanoparuro.{tabla}")
-- MAGIC
-- MAGIC     print("=" * 60)
-- MAGIC     print(f"TABLA: {tabla}")
-- MAGIC     print("=" * 60)
-- MAGIC
-- MAGIC     for campo in df.schema.fields:
-- MAGIC         print(f"{campo.name}: {campo.dataType.simpleString()}")
-- MAGIC
-- MAGIC     print(f"Total de registros: {df.count()}")
-- MAGIC     print()

-- COMMAND ----------

-- ==========================================
-- 1. CORREGIR CODIGOS POSTALES FALTANTES
-- ==========================================

UPDATE bi_nanoparuro.STG_Ventas
SET CodigoPostal = 'SIN CODIGO'
WHERE CodigoPostal IS NULL
   OR TRIM(CodigoPostal) = '';


-- ==========================================
-- 2. ACTUALIZAR DIM_GEOGRAFIA
-- ==========================================

MERGE INTO bi_nanoparuro.DIM_GEOGRAFIA AS destino
USING (
    SELECT DISTINCT
        TRIM(Ciudad) AS Ciudad,
        TRIM(Estado) AS Estado,
        TRIM(Region) AS Region,
        TRIM(CodigoPostal) AS CodigoPostal
    FROM bi_nanoparuro.STG_Ventas
) AS origen

ON destino.Ciudad <=> origen.Ciudad
AND destino.Estado <=> origen.Estado
AND destino.Region <=> origen.Region
AND destino.CodigoPostal <=> origen.CodigoPostal

WHEN NOT MATCHED THEN
INSERT (
    Ciudad,
    Estado,
    Region,
    CodigoPostal
)
VALUES (
    origen.Ciudad,
    origen.Estado,
    origen.Region,
    origen.CodigoPostal
);


-- ==========================================
-- 3. ACTUALIZAR DIM_FECHA
-- ==========================================

MERGE INTO bi_nanoparuro.DIM_FECHA AS destino
USING (
    SELECT
        CAST(DATE_FORMAT(Fecha, 'yyyyMMdd') AS INT) AS FechaKey,
        Fecha,
        DAY(Fecha) AS Dia,
        MONTH(Fecha) AS Mes,
        ELEMENT_AT(
            ARRAY(
                'Enero',
                'Febrero',
                'Marzo',
                'Abril',
                'Mayo',
                'Junio',
                'Julio',
                'Agosto',
                'Septiembre',
                'Octubre',
                'Noviembre',
                'Diciembre'
            ),
            MONTH(Fecha)
        ) AS NombreMes,
        QUARTER(Fecha) AS Trimestre,
        YEAR(Fecha) AS Anio
    FROM (
        SELECT EXPLODE(
            SEQUENCE(
                DATE '2026-01-01',
                DATE '2026-12-31',
                INTERVAL 1 DAY
            )
        ) AS Fecha
    )
) AS origen

ON destino.Fecha = origen.Fecha

WHEN NOT MATCHED THEN
INSERT (
    FechaKey,
    Fecha,
    Dia,
    Mes,
    NombreMes,
    Trimestre,
    Anio
)
VALUES (
    origen.FechaKey,
    origen.Fecha,
    origen.Dia,
    origen.Mes,
    origen.NombreMes,
    origen.Trimestre,
    origen.Anio
);


-- ==========================================
-- 4. ACTUALIZAR DIM_VENDEDOR
-- ==========================================

MERGE INTO bi_nanoparuro.DIM_VENDEDOR AS destino
USING (
    SELECT
        SellerID,
        MAX(TRIM(NombreVendedor)) AS NombreVendedor
    FROM bi_nanoparuro.STG_Ventas
    WHERE SellerID IS NOT NULL
    GROUP BY SellerID
) AS origen

ON destino.SellerID = origen.SellerID

WHEN MATCHED THEN
UPDATE SET
    destino.NombreVendedor = origen.NombreVendedor;

-- COMMAND ----------

SELECT 'DIM_CLIENTE' AS Tabla, COUNT(*) AS Registros
FROM bi_nanoparuro.DIM_CLIENTE

UNION ALL

SELECT 'DIM_PRODUCTO', COUNT(*)
FROM bi_nanoparuro.DIM_PRODUCTO

UNION ALL

SELECT 'DIM_GEOGRAFIA', COUNT(*)
FROM bi_nanoparuro.DIM_GEOGRAFIA

UNION ALL

SELECT 'DIM_FECHA', COUNT(*)
FROM bi_nanoparuro.DIM_FECHA

UNION ALL

SELECT 'DIM_VENDEDOR', COUNT(*)
FROM bi_nanoparuro.DIM_VENDEDOR

UNION ALL

SELECT 'STG_Ventas', COUNT(*)
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID) AS Duplicados
FROM bi_nanoparuro.FACT_VENTAS;

-- COMMAND ----------

SHOW CREATE TABLE bi_nanoparuro.FACT_VENTAS;

-- COMMAND ----------

SELECT
    Region,
    COUNT(*) AS TotalVentas
FROM bi_nanoparuro.STG_Ventas
GROUP BY Region
ORDER BY Region;

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS
bi_nanoparuro.fact_ventas_respaldo
AS
SELECT *
FROM bi_nanoparuro.FACT_VENTAS;

-- COMMAND ----------

SELECT *
FROM bi_nanoparuro.FACT_VENTAS
WHERE OrderID IN (
    SELECT OrderID
    FROM bi_nanoparuro.FACT_VENTAS
    GROUP BY OrderID
    HAVING COUNT(*) > 1
)
ORDER BY OrderID, VentaKey;

-- COMMAND ----------

DELETE FROM bi_nanoparuro.FACT_VENTAS
WHERE VentaKey IN (
    SELECT VentaKey
    FROM (
        SELECT
            VentaKey,
            ROW_NUMBER() OVER (
                PARTITION BY OrderID
                ORDER BY VentaKey
            ) AS Fila
        FROM bi_nanoparuro.FACT_VENTAS
    ) AS duplicados
    WHERE Fila > 1
);

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID) AS Duplicados
FROM bi_nanoparuro.FACT_VENTAS;

-- COMMAND ----------

SHOW CREATE TABLE bi_nanoparuro.FACT_VENTAS;

-- COMMAND ----------

SHOW CREATE TABLE bi_nanoparuro.FACT_VENTAS;

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW vw_carga_fact_ventas AS
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

    DATEDIFF(
        s.FechaEntregaReal,
        s.FechaVenta
    ) AS DiasEntrega,

    CAST(
        CASE
            WHEN s.FechaEntregaReal IS NULL
              OR s.FechaEntregaEstimada IS NULL
            THEN NULL
            WHEN s.FechaEntregaReal > s.FechaEntregaEstimada
            THEN 1
            ELSE 0
        END AS TINYINT
    ) AS EntregaTardia,

    CAST(
        s.Cantidad * s.Precio AS DECIMAL(18,2)
    ) AS ImporteTotal

FROM bi_nanoparuro.STG_Ventas s

INNER JOIN bi_nanoparuro.DIM_CLIENTE c
    ON s.CustomerID = c.CustomerID

INNER JOIN bi_nanoparuro.DIM_PRODUCTO p
    ON s.ProductID = p.ProductID

INNER JOIN bi_nanoparuro.DIM_FECHA f
    ON s.FechaVenta = f.Fecha

INNER JOIN bi_nanoparuro.DIM_GEOGRAFIA g
    ON TRIM(s.Ciudad) = g.Ciudad
    AND TRIM(s.Estado) = g.Estado
    AND TRIM(s.Region) = g.Region
    AND TRIM(s.CodigoPostal) = g.CodigoPostal

INNER JOIN bi_nanoparuro.DIM_VENDEDOR v
    ON s.SellerID = v.SellerID;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID) AS Duplicados
FROM vw_carga_fact_ventas;

-- COMMAND ----------

MERGE INTO bi_nanoparuro.FACT_VENTAS AS destino
USING vw_carga_fact_ventas AS origen

ON destino.OrderID = origen.OrderID

WHEN MATCHED THEN
UPDATE SET
    destino.ClienteKey = origen.ClienteKey,
    destino.ProductoKey = origen.ProductoKey,
    destino.FechaKey = origen.FechaKey,
    destino.GeografiaKey = origen.GeografiaKey,
    destino.VendedorKey = origen.VendedorKey,
    destino.Cantidad = origen.Cantidad,
    destino.Precio = origen.Precio,
    destino.CostoFlete = origen.CostoFlete,
    destino.FechaEntregaEstimada = origen.FechaEntregaEstimada,
    destino.FechaEntregaReal = origen.FechaEntregaReal,
    destino.Calificacion = origen.Calificacion,
    destino.DiasEntrega = origen.DiasEntrega,
    destino.EntregaTardia = origen.EntregaTardia

WHEN NOT MATCHED THEN
INSERT (
    ClienteKey,
    ProductoKey,
    FechaKey,
    GeografiaKey,
    VendedorKey,
    OrderID,
    Cantidad,
    Precio,
    CostoFlete,
    FechaEntregaEstimada,
    FechaEntregaReal,
    Calificacion,
    DiasEntrega,
    EntregaTardia
)
VALUES (
    origen.ClienteKey,
    origen.ProductoKey,
    origen.FechaKey,
    origen.GeografiaKey,
    origen.VendedorKey,
    origen.OrderID,
    origen.Cantidad,
    origen.Precio,
    origen.CostoFlete,
    origen.FechaEntregaEstimada,
    origen.FechaEntregaReal,
    origen.Calificacion,
    origen.DiasEntrega,
    origen.EntregaTardia
);

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID) AS Duplicados,
    COUNT(DISTINCT ClienteKey) AS TotalClientes,
    COUNT(DISTINCT ProductoKey) AS TotalProductos
FROM bi_nanoparuro.FACT_VENTAS;

-- COMMAND ----------

INSERT OVERWRITE TABLE bi_nanoparuro.ventas_limpias
SELECT
    TRIM(OrderID),
    TRIM(CustomerID),
    TRIM(NombreCliente),
    TRIM(TipoCliente),
    TRIM(ProductID),
    TRIM(NombreProducto),
    TRIM(Categoria),
    TRIM(Subcategoria),
    FechaVenta,
    TRIM(Ciudad),
    TRIM(Estado),
    TRIM(Region),
    TRIM(CodigoPostal),
    TRIM(SellerID),
    TRIM(NombreVendedor),
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

FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID) AS Duplicados,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    COUNT(DISTINCT Region) AS TotalRegiones,
    MIN(FechaVenta) AS PrimeraVenta,
    MAX(FechaVenta) AS UltimaVenta
FROM bi_nanoparuro.ventas_limpias;

-- COMMAND ----------

DESCRIBE HISTORY bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

RESTORE TABLE bi_nanoparuro.STG_Ventas
TO VERSION AS OF 2;

-- COMMAND ----------

DESCRIBE HISTORY bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    COUNT(DISTINCT Region) AS TotalRegiones,
    MIN(FechaVenta) AS PrimeraVenta,
    MAX(FechaVenta) AS UltimaVenta
FROM bi_nanoparuro.STG_Ventas;

-- COMMAND ----------

SELECT 2 AS Version, COUNT(*) AS Registros
FROM bi_nanoparuro.STG_Ventas VERSION AS OF 2

UNION ALL

SELECT 6, COUNT(*)
FROM bi_nanoparuro.STG_Ventas VERSION AS OF 6

UNION ALL

SELECT 7, COUNT(*)
FROM bi_nanoparuro.STG_Ventas VERSION AS OF 7

UNION ALL

SELECT 8, COUNT(*)
FROM bi_nanoparuro.STG_Ventas VERSION AS OF 8

UNION ALL

SELECT 9, COUNT(*)
FROM bi_nanoparuro.STG_Ventas VERSION AS OF 9

UNION ALL

SELECT 15, COUNT(*)
FROM bi_nanoparuro.STG_Ventas VERSION AS OF 15

UNION ALL

SELECT 16, COUNT(*)
FROM bi_nanoparuro.STG_Ventas VERSION AS OF 16

ORDER BY Version;

-- COMMAND ----------

WITH recuperacion AS (
    SELECT *
    FROM bi_nanoparuro.STG_Ventas VERSION AS OF 7
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY OrderID
        ORDER BY FechaVenta DESC
    ) = 1
)

SELECT
    COUNT(*) AS TotalRegistros,
    COUNT(DISTINCT OrderID) AS PedidosUnicos,
    COUNT(*) - COUNT(DISTINCT OrderID) AS Duplicados,
    COUNT(DISTINCT CustomerID) AS TotalClientes,
    COUNT(DISTINCT ProductID) AS TotalProductos,
    COUNT(DISTINCT Region) AS TotalRegiones
FROM recuperacion;

-- COMMAND ----------

ALTER TABLE bi_nanoparuro.STG_Ventas
DROP CONSTRAINT ck_stg_calificacion;

-- COMMAND ----------

ALTER TABLE bi_nanoparuro.STG_Ventas
ADD CONSTRAINT ck_stg_calificacion
CHECK (
    Calificacion IS NULL
    OR Calificacion BETWEEN 1 AND 5
);

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC df_original = spark.sql("""
-- MAGIC     SELECT *
-- MAGIC     FROM bi_nanoparuro.STG_Ventas VERSION AS OF 7
-- MAGIC     QUALIFY ROW_NUMBER() OVER (
-- MAGIC         PARTITION BY OrderID
-- MAGIC         ORDER BY FechaVenta DESC
-- MAGIC     ) = 1
-- MAGIC """)
-- MAGIC
-- MAGIC registros = df_original.collect()
-- MAGIC
-- MAGIC df_recuperado = spark.createDataFrame(
-- MAGIC     registros,
-- MAGIC     schema=df_original.schema
-- MAGIC )
-- MAGIC
-- MAGIC total = df_recuperado.count()
-- MAGIC unicos = df_recuperado.select("OrderID").distinct().count()
-- MAGIC
-- MAGIC assert total == 74
-- MAGIC assert unicos == 74
-- MAGIC
-- MAGIC df_recuperado.write.mode("overwrite").insertInto(
-- MAGIC     "bi_nanoparuro.STG_Ventas"
-- MAGIC )
-- MAGIC
-- MAGIC print("RECUPERACION EXITOSA")
-- MAGIC print("Total de registros:", total)
-- MAGIC print("Pedidos unicos:", unicos)
-- MAGIC print("Duplicados:", total - unicos)
-- MAGIC

-- COMMAND ----------

SELECT 'STG_Ventas' AS Tabla, COUNT(*) AS Registros
FROM bi_nanoparuro.STG_Ventas

UNION ALL

SELECT 'DIM_CLIENTE', COUNT(*)
FROM bi_nanoparuro.DIM_CLIENTE

UNION ALL

SELECT 'DIM_PRODUCTO', COUNT(*)
FROM bi_nanoparuro.DIM_PRODUCTO

UNION ALL

SELECT 'DIM_GEOGRAFIA', COUNT(*)
FROM bi_nanoparuro.DIM_GEOGRAFIA

UNION ALL

SELECT 'DIM_FECHA', COUNT(*)
FROM bi_nanoparuro.DIM_FECHA

UNION ALL

SELECT 'DIM_VENDEDOR', COUNT(*)
FROM bi_nanoparuro.DIM_VENDEDOR

UNION ALL

SELECT 'FACT_VENTAS', COUNT(*)
FROM bi_nanoparuro.FACT_VENTAS

UNION ALL

SELECT 'ventas_limpias', COUNT(*)
FROM bi_nanoparuro.ventas_limpias;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC bd = "bi_nanoparuro"
-- MAGIC
-- MAGIC # 1. Verificar los registros originales
-- MAGIC df = spark.table(f"{bd}.STG_Ventas")
-- MAGIC
-- MAGIC assert df.count() == 74
-- MAGIC assert df.select("OrderID").distinct().count() == 74
-- MAGIC
-- MAGIC # 2. Recuperar tabla de hechos
-- MAGIC spark.sql(f"""
-- MAGIC     DELETE FROM {bd}.FACT_VENTAS
-- MAGIC     WHERE OrderID NOT IN (
-- MAGIC         SELECT OrderID FROM {bd}.STG_Ventas
-- MAGIC     )
-- MAGIC """)
-- MAGIC
-- MAGIC print("FACT_VENTAS recuperada")
-- MAGIC
-- MAGIC # 3. Recuperar tabla del dashboard
-- MAGIC spark.sql(f"""
-- MAGIC     INSERT OVERWRITE TABLE {bd}.ventas_limpias
-- MAGIC     SELECT
-- MAGIC         TRIM(OrderID),
-- MAGIC         TRIM(CustomerID),
-- MAGIC         TRIM(NombreCliente),
-- MAGIC         TRIM(TipoCliente),
-- MAGIC         TRIM(ProductID),
-- MAGIC         TRIM(NombreProducto),
-- MAGIC         TRIM(Categoria),
-- MAGIC         TRIM(Subcategoria),
-- MAGIC         FechaVenta,
-- MAGIC         TRIM(Ciudad),
-- MAGIC         TRIM(Estado),
-- MAGIC         TRIM(Region),
-- MAGIC         TRIM(CodigoPostal),
-- MAGIC         TRIM(SellerID),
-- MAGIC         TRIM(NombreVendedor),
-- MAGIC         Cantidad,
-- MAGIC         Precio,
-- MAGIC         CostoFlete,
-- MAGIC         FechaEntregaEstimada,
-- MAGIC         FechaEntregaReal,
-- MAGIC         Calificacion,
-- MAGIC         CAST(Cantidad * Precio AS DECIMAL(30,2)),
-- MAGIC         DATEDIFF(FechaEntregaReal, FechaVenta),
-- MAGIC         CASE
-- MAGIC             WHEN FechaEntregaReal IS NULL
-- MAGIC               OR FechaEntregaEstimada IS NULL
-- MAGIC                 THEN 'Sin datos suficientes'
-- MAGIC             WHEN FechaEntregaReal <= FechaEntregaEstimada
-- MAGIC                 THEN 'A tiempo'
-- MAGIC             ELSE 'Con retraso'
-- MAGIC         END
-- MAGIC     FROM {bd}.STG_Ventas
-- MAGIC """)
-- MAGIC
-- MAGIC print("ventas_limpias recuperada")
-- MAGIC
-- MAGIC # 4. Recuperar dimensiones de clientes y productos
-- MAGIC dimensiones = [
-- MAGIC     ("DIM_CLIENTE", "CustomerID"),
-- MAGIC     ("DIM_PRODUCTO", "ProductID"),
-- MAGIC     ("DIM_VENDEDOR", "SellerID")
-- MAGIC ]
-- MAGIC
-- MAGIC for tabla, campo in dimensiones:
-- MAGIC
-- MAGIC     spark.sql(f"""
-- MAGIC         DELETE FROM {bd}.{tabla}
-- MAGIC         WHERE {campo} NOT IN (
-- MAGIC             SELECT DISTINCT {campo}
-- MAGIC             FROM {bd}.STG_Ventas
-- MAGIC         )
-- MAGIC     """)
-- MAGIC
-- MAGIC     print(f"{tabla} recuperada")
-- MAGIC
-- MAGIC # 5. Recuperar nombres originales de clientes
-- MAGIC spark.sql(f"""
-- MAGIC     MERGE INTO {bd}.DIM_CLIENTE AS d
-- MAGIC     USING (
-- MAGIC         SELECT CustomerID,
-- MAGIC                MAX(TRIM(NombreCliente)) AS NombreCliente
-- MAGIC         FROM {bd}.STG_Ventas
-- MAGIC         GROUP BY CustomerID
-- MAGIC     ) AS s
-- MAGIC     ON d.CustomerID = s.CustomerID
-- MAGIC     WHEN MATCHED THEN UPDATE SET
-- MAGIC         d.NombreCliente = s.NombreCliente
-- MAGIC """)
-- MAGIC
-- MAGIC # 6. Recuperar nombres originales de productos
-- MAGIC spark.sql(f"""
-- MAGIC     MERGE INTO {bd}.DIM_PRODUCTO AS d
-- MAGIC     USING (
-- MAGIC         SELECT ProductID,
-- MAGIC                MAX(TRIM(NombreProducto)) AS NombreProducto
-- MAGIC         FROM {bd}.STG_Ventas
-- MAGIC         GROUP BY ProductID
-- MAGIC     ) AS s
-- MAGIC     ON d.ProductID = s.ProductID
-- MAGIC     WHEN MATCHED THEN UPDATE SET
-- MAGIC         d.NombreProducto = s.NombreProducto
-- MAGIC """)
-- MAGIC
-- MAGIC # 7. Recuperar dimension geografica
-- MAGIC spark.sql(f"""
-- MAGIC     DELETE FROM {bd}.DIM_GEOGRAFIA AS d
-- MAGIC     WHERE NOT EXISTS (
-- MAGIC         SELECT 1
-- MAGIC         FROM {bd}.STG_Ventas AS s
-- MAGIC         WHERE TRIM(d.Ciudad) <=> TRIM(s.Ciudad)
-- MAGIC           AND TRIM(d.Estado) <=> TRIM(s.Estado)
-- MAGIC           AND TRIM(d.Region) <=> TRIM(s.Region)
-- MAGIC           AND TRIM(d.CodigoPostal) <=> TRIM(s.CodigoPostal)
-- MAGIC     )
-- MAGIC """)
-- MAGIC
-- MAGIC print("DIM_GEOGRAFIA recuperada")
-- MAGIC
-- MAGIC # 8. Verificar todas las tablas
-- MAGIC tablas = [
-- MAGIC     "STG_Ventas",
-- MAGIC     "DIM_CLIENTE",
-- MAGIC     "DIM_PRODUCTO",
-- MAGIC     "DIM_GEOGRAFIA",
-- MAGIC     "DIM_FECHA",
-- MAGIC     "DIM_VENDEDOR",
-- MAGIC     "FACT_VENTAS",
-- MAGIC     "ventas_limpias"
-- MAGIC ]
-- MAGIC
-- MAGIC resultados = []
-- MAGIC
-- MAGIC for tabla in tablas:
-- MAGIC     cantidad = spark.table(f"{bd}.{tabla}").count()
-- MAGIC     resultados.append((tabla, cantidad))
-- MAGIC
-- MAGIC display(
-- MAGIC     spark.createDataFrame(
-- MAGIC         resultados,
-- MAGIC         ["Tabla", "TotalRegistros"]
-- MAGIC     )
-- MAGIC )

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
FROM bi_nanoparuro.ventas_limpias;