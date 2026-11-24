# Databricks notebook source
spark.sql("USE SCHEMA bi_nanoparuro")

display(spark.sql("SHOW TABLES"))

# COMMAND ----------

from pyspark.sql import functions as F

df = spark.table("bi_nanoparuro.stg_ventas")

display(df)

# COMMAND ----------

df.printSchema()

print("Total de registros:", df.count())
print("Total de columnas:", len(df.columns))

# COMMAND ----------

# Identificar valores nulos por columna

nulos = df.select([
    F.count(F.when(F.col(c).isNull(), 1)).alias(c)
    for c in df.columns
])

display(nulos)

# COMMAND ----------

# Identificar registros duplicados

total_original = df.count()
total_unicos = df.dropDuplicates().count()

print("Registros originales:", total_original)
print("Registros únicos:", total_unicos)
print("Registros duplicados:", total_original - total_unicos)

# COMMAND ----------

# Identificar pedidos repetidos

duplicados = df.groupBy("OrderID").agg(
    F.count("*").alias("Repeticiones")
).filter(F.col("Repeticiones") > 1)

display(duplicados)

# COMMAND ----------

# Eliminar registros completamente duplicados

df_limpio = df.dropDuplicates()

print("Registros antes:", df.count())
print("Registros después:", df_limpio.count())
print("Duplicados eliminados:", df.count() - df_limpio.count())

display(df_limpio)

# COMMAND ----------

# Estandarizar columnas de texto

for columna, tipo in df_limpio.dtypes:
    if tipo == "string":
        df_limpio = df_limpio.withColumn(
            columna, F.trim(F.col(columna))
        )

display(df_limpio)

# COMMAND ----------

# Tratamiento de campos vacíos

for columna, tipo in df_limpio.dtypes:
    if tipo == "string":
        df_limpio = df_limpio.withColumn(
            columna,
            F.when(F.col(columna) == "", None)
            .otherwise(F.col(columna))
        )

display(df_limpio)

# COMMAND ----------

# Verificar valores nulos después de la limpieza

display(df_limpio.select([
    F.count(F.when(F.col(c).isNull(), 1)).alias(c)
    for c in df_limpio.columns
]))

# COMMAND ----------

for columna, tipo in df_limpio.dtypes:
    print(columna, ":", tipo)

# COMMAND ----------

# Resumen estadístico de los datos

display(df_limpio.describe())

# COMMAND ----------

# Detectar valores negativos

for columna, tipo in df_limpio.dtypes:
    if tipo.startswith(("int", "bigint", "double",
                        "float", "decimal", "long")):

        negativos = df_limpio.filter(
            F.col(columna) < 0
        ).count()

        print(columna, "- Valores negativos:", negativos)

# COMMAND ----------

# Validación de identificadores

df_limpio = df_limpio.dropna(
    subset=["OrderID", "CustomerID", "ProductID"]
)

print("Registros actuales:", df_limpio.count())
display(df_limpio)

# COMMAND ----------

# Validación de datos numéricos

df_limpio = df_limpio.filter(
    (F.col("Cantidad") > 0) &
    (F.col("Precio") > 0) &
    (F.col("CostoFlete") >= 0)
)

print("Registros válidos:", df_limpio.count())

display(df_limpio)

# COMMAND ----------

# Detección de valores atípicos en Precio

Q1, Q3 = df_limpio.approxQuantile(
    "Precio", [0.25, 0.75], 0.01
)

IQR = Q3 - Q1

limite_inferior = Q1 - 1.5 * IQR
limite_superior = Q3 + 1.5 * IQR

print("Primer cuartil:", Q1)
print("Tercer cuartil:", Q3)
print("IQR:", IQR)
print("Límite inferior:", limite_inferior)
print("Límite superior:", limite_superior)

atipicos = df_limpio.filter(
    (F.col("Precio") < limite_inferior) |
    (F.col("Precio") > limite_superior)
)

print("Valores atípicos:", atipicos.count())

display(atipicos)

# COMMAND ----------

# Calcular importe de venta

df_limpio = df_limpio.withColumn(
    "ImporteVenta",
    F.round(F.col("Cantidad") * F.col("Precio"), 2)
)

display(df_limpio.select(
    "OrderID",
    "NombreProducto",
    "Cantidad",
    "Precio",
    "ImporteVenta"
))

# COMMAND ----------

# Resumen de ventas por categoría

ventas_categoria = df_limpio.groupBy("Categoria").agg(
    F.round(F.sum("ImporteVenta"), 2).alias("VentasTotales"),
    F.sum("Cantidad").alias("UnidadesVendidas"),
    F.round(F.avg("Precio"), 2).alias("PrecioPromedio"),
    F.countDistinct("OrderID").alias("TotalPedidos")
).orderBy(F.desc("VentasTotales"))

display(ventas_categoria)

# COMMAND ----------

# Validación de calificaciones

df_limpio = df_limpio.withColumn(
    "Calificacion",
    F.when(F.col("Calificacion").between(1, 5),
           F.col("Calificacion"))
    .otherwise(None)
)

display(df_limpio.groupBy("Calificacion").count()
        .orderBy("Calificacion"))

# COMMAND ----------

# Validación de fechas

for columna in ["FechaEntregaEstimada", "FechaEntregaReal"]:
    df_limpio = df_limpio.withColumn(
        columna,
        F.when(F.col(columna) >= F.col("FechaVenta"),
               F.col(columna))
        .otherwise(None)
    )

# Calcular días de entrega

df_limpio = df_limpio.withColumn(
    "DiasEntrega",
    F.datediff("FechaEntregaReal", "FechaVenta")
)

display(df_limpio.select(
    "OrderID",
    "FechaVenta",
    "FechaEntregaEstimada",
    "FechaEntregaReal",
    "DiasEntrega"
))

# COMMAND ----------

# Ranking de productos

productos_vendidos = df_limpio.groupBy(
    "NombreProducto"
).agg(
    F.sum("Cantidad").alias("UnidadesVendidas"),
    F.round(F.sum("ImporteVenta"), 2).alias("Ingresos")
).orderBy(F.desc("UnidadesVendidas"))

display(productos_vendidos)

# COMMAND ----------

# Resumen de ventas por región

ventas_region = df_limpio.groupBy("Region").agg(
    F.round(F.sum("ImporteVenta"), 2).alias("VentasTotales"),
    F.countDistinct("OrderID").alias("Pedidos"),
    F.round(F.avg("DiasEntrega"), 2).alias("PromedioEntrega")
).orderBy(F.desc("VentasTotales"))

display(ventas_region)

# COMMAND ----------

# Análisis mensual de ventas

ventas_mensuales = df_limpio.withColumn(
    "Mes", F.date_format("FechaVenta", "yyyy-MM")
).groupBy("Mes").agg(
    F.round(F.sum("ImporteVenta"), 2).alias("VentasTotales"),
    F.countDistinct("OrderID").alias("Pedidos"),
    F.sum("Cantidad").alias("UnidadesVendidas")
).orderBy("Mes")

display(ventas_mensuales)

# COMMAND ----------

# Indicadores KPI generales de Nanoparuro

kpi_general = df_limpio.agg(
    F.round(F.sum("ImporteVenta"), 2)
        .alias("VentasTotales"),

    F.countDistinct("OrderID")
        .alias("TotalPedidos"),

    F.sum("Cantidad")
        .alias("UnidadesVendidas"),

    F.countDistinct("CustomerID")
        .alias("TotalClientes"),

    F.countDistinct("ProductID")
        .alias("TotalProductos"),

    F.round(
        F.sum("ImporteVenta") /
        F.countDistinct("OrderID"), 2
    ).alias("TicketPromedio"),

    F.round(F.avg("Calificacion"), 2)
        .alias("CalificacionPromedio"),

    F.round(F.avg("DiasEntrega"), 2)
        .alias("PromedioDiasEntrega"),

    F.round(F.sum("CostoFlete"), 2)
        .alias("CostoTotalFlete")
)

display(kpi_general)

# COMMAND ----------

# Ventas por tipo de cliente

ventas_tipo_cliente = df_limpio.groupBy(
    "TipoCliente"
).agg(
    F.round(F.sum("ImporteVenta"), 2)
        .alias("VentasTotales"),
    F.countDistinct("OrderID")
        .alias("Pedidos"),
    F.countDistinct("CustomerID")
        .alias("Clientes")
)

display(ventas_tipo_cliente)

# COMMAND ----------

# Distribución de calificaciones

calificaciones = df_limpio.filter(
    F.col("Calificacion").isNotNull()
).groupBy("Calificacion").agg(
    F.countDistinct("OrderID").alias("Pedidos")
).orderBy("Calificacion")

display(calificaciones)

# COMMAND ----------

# Tiempo promedio de entrega por región

entregas_region = df_limpio.groupBy(
    "Region"
).agg(
    F.round(F.avg("DiasEntrega"), 2)
        .alias("PromedioDias")
).orderBy(F.desc("PromedioDias"))

display(entregas_region)

# COMMAND ----------

# Clasificación del cumplimiento de entregas

cumplimiento = df_limpio.withColumn(
    "CumplimientoEntrega",
    F.when(
        F.col("FechaEntregaReal").isNull() |
        F.col("FechaEntregaEstimada").isNull(),
        "Sin datos suficientes"
    ).when(
        F.col("FechaEntregaReal") <=
        F.col("FechaEntregaEstimada"),
        "A tiempo"
    ).otherwise("Con retraso")
).groupBy("CumplimientoEntrega").agg(
    F.countDistinct("OrderID").alias("Pedidos")
)

display(cumplimiento)

# COMMAND ----------

# Ranking de clientes por compras

ranking_clientes = df_limpio.groupBy(
    "CustomerID", "NombreCliente"
).agg(
    F.round(F.sum("ImporteVenta"), 2)
        .alias("TotalCompras"),
    F.countDistinct("OrderID")
        .alias("Pedidos")
).orderBy(F.desc("TotalCompras")).limit(10)

display(ranking_clientes)

# COMMAND ----------

# Análisis de costos de transporte por región

flete_region = df_limpio.groupBy("Region").agg(
    F.round(F.sum("CostoFlete"), 2)
        .alias("CostoTotalFlete"),

    F.round(F.avg("CostoFlete"), 2)
        .alias("CostoPromedioFlete")

).orderBy(F.desc("CostoTotalFlete"))

display(flete_region)

# COMMAND ----------

# Guardar DataFrame limpio como tabla Delta

df_limpio.write \
    .format("delta") \
    .mode("ignore") \
    .saveAsTable("bi_nanoparuro.ventas_limpias")

print("Tabla disponible correctamente")

# COMMAND ----------

# Verificar si existe la columna en la tabla guardada

df_final = spark.table("bi_nanoparuro.ventas_limpias")

print("CumplimientoEntrega" in df_final.columns)

# COMMAND ----------

# Incorporar cumplimiento de entregas al DataFrame limpio

df_limpio = df_limpio.withColumn(
    "CumplimientoEntrega",
    F.when(
        F.col("FechaEntregaReal").isNull() |
        F.col("FechaEntregaEstimada").isNull(),
        "Sin datos suficientes"
    ).when(
        F.col("FechaEntregaReal") <=
        F.col("FechaEntregaEstimada"),
        "A tiempo"
    ).otherwise("Con retraso")
)

print("Total de columnas:", len(df_limpio.columns))

display(df_limpio)

# COMMAND ----------

# Actualizar tabla Delta con la nueva columna

assert df_limpio.count() == 74
assert "CumplimientoEntrega" in df_limpio.columns

df_limpio.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("bi_nanoparuro.ventas_limpias")

print("Tabla actualizada correctamente")

# COMMAND ----------

# Verificar tabla Delta actualizada

df_final = spark.table("bi_nanoparuro.ventas_limpias")

print("Total de registros:", df_final.count())
print("Total de columnas:", len(df_final.columns))

display(
    df_final.groupBy("CumplimientoEntrega")
    .agg(F.countDistinct("OrderID").alias("Pedidos"))
)

# COMMAND ----------

# Verificar estructura de la tabla actual

df_actual = spark.table("bi_nanoparuro.ventas_limpias")

df_actual.printSchema()

print("Total de registros:", df_actual.count())
print("Total de columnas:", len(df_actual.columns))

display(df_actual.limit(10))

# COMMAND ----------

# Mostrar todas las columnas de la tabla

for i, campo in enumerate(df_actual.schema.fields, 1):
    print(f"{i}. {campo.name}: {campo.dataType.simpleString()}")