# Arquitectura tecnológica Big Data - NANOPARURO

## Descripción

La arquitectura tecnológica de la solución Big Data
utiliza Databricks y Apache Spark para la integración,
procesamiento, almacenamiento y análisis de datos
comerciales de NANOPARURO.

## Componentes de la arquitectura

### 1. Fuente de datos

Datos comerciales provenientes de la solución BI,
complementados con registros sintéticos para ampliar
el volumen de información.

### 2. Ingesta de datos

Carga de los datos en Databricks mediante DataFrames
de Apache Spark.

### 3. Procesamiento de datos

- Análisis exploratorio de datos (EDA).
- Identificación de valores nulos.
- Eliminación de registros duplicados.
- Limpieza y transformación de datos.
- Generación de datos sintéticos.
- Validación de la calidad de los datos.

### 4. Almacenamiento

Persistencia de los datos procesados mediante tablas
Delta en Databricks.

- STG_Ventas.
- DIM_CLIENTE.
- DIM_PRODUCTO.
- DIM_FECHA.
- DIM_GEOGRAFIA.
- DIM_VENDEDOR.
- FACT_VENTAS.
- ventas_limpias.

### 5. Visualización y análisis

Implementación de indicadores KPI, gráficos comerciales
y filtros interactivos mediante Databricks AI/BI Dashboards.

## Beneficios de la arquitectura

- Escalabilidad del procesamiento.
- Integración de datos comerciales.
- Mejora de la calidad de los datos.
- Almacenamiento estructurado.
- Análisis de grandes volúmenes de información.
- Apoyo a la toma de decisiones comerciales.
