# Dataset - NANOPARURO

## Descripción

Esta carpeta contiene los conjuntos de datos utilizados
para la implementación de la solución Big Data de NANOPARURO.

## Datos originales

El conjunto de datos inicial contiene 74 pedidos comerciales
correspondientes al periodo de marzo a junio de 2026.

## Datos ampliados

Mediante Databricks y Apache Spark se generaron 20,000
registros sintéticos adicionales para ampliar el volumen
de información y evaluar la capacidad de procesamiento.

## Características del dataset ampliado

| Característica | Cantidad |
|---|---:|
| Pedidos originales | 74 |
| Registros sintéticos | 20,000 |
| Total de registros | 20,074 |
| Pedidos únicos | 20,074 |
| Clientes | 250 |
| Productos | 50 |
| Regiones | 24 |
| Vendedores | 5 |
| Registros duplicados | 0 |

Periodo de análisis: enero a diciembre de 2026.

## Archivos

- 01_Dataset_Original.csv
- 02_Dataset_Ampliado.csv

## Fuente de datos

Los datos originales provienen de la solución BI de NANOPARURO.
Los datos adicionales fueron generados artificialmente
con fines académicos y de experimentación.

## Tecnologías utilizadas

- Apache Spark.
- PySpark.
- Databricks.
- Spark SQL.
- Delta Lake.

## Objetivo

Facilitar la replicación del procesamiento, la limpieza,
el análisis exploratorio y los experimentos realizados
en la solución Big Data.
