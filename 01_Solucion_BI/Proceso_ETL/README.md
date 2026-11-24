# Proceso ETL - NANOPARURO

## Descripción

El proceso ETL fue desarrollado mediante SQL Server Integration Services (SSIS) en Visual Studio, con la finalidad de extraer, transformar y cargar los datos comerciales de NANOPARURO en el Data Mart.

## Flujo de control

El paquete ETL está compuesto por cuatro tareas:

### Tarea 00 - Limpieza STG_Ventas

Elimina los registros existentes en la tabla staging antes de iniciar una nueva carga.

### Tarea 01 - Extracción y carga STG_Ventas

Extrae los datos de la base de datos BD_Nanoparuro_Origen y los almacena en la tabla STG_Ventas.

### Tarea 02 - Carga de dimensiones

Procesa y carga la información correspondiente a las dimensiones:

- DIM_CLIENTE.
- DIM_PRODUCTO.
- DIM_FECHA.
- DIM_GEOGRAFIA.
- DIM_VENDEDOR.

### Tarea 03 - Carga FACT_VENTAS

Integra los registros comerciales con las dimensiones del modelo estrella y carga la tabla de hechos FACT_VENTAS.

## Tecnologías utilizadas

- Microsoft SQL Server.
- Visual Studio.
- SQL Server Integration Services (SSIS).

## Resultados

El proceso ETL permitió cargar los 74 registros originales y realizar pruebas experimentales con volúmenes de 10 000 y 100 000 registros, verificando la ausencia de pedidos duplicados.

## Replicación

Para reproducir el proceso se requiere implementar las bases de datos de origen y destino, abrir el proyecto SSIS, configurar las conexiones al servidor SQL correspondiente y ejecutar el paquete ETL.

## Archivos y evidencias

Esta carpeta incorporará el paquete SSIS, los archivos del proyecto y las evidencias de ejecución del proceso ETL.
