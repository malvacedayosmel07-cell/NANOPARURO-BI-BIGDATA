# Databricks notebook source

from pyspark.sql import functions as F
from pyspark.sql.window import Window
from time import perf_counter
from statistics import mean

df_original = spark.table("bi_nanoparuro.STG_Ventas")

total = df_original.count()

assert total == 74, "Verificar dataset original"

print("PROYECTO NANOPARURO")
print("Registros originales:", total)
print("Total de columnas:", len(df_original.columns))

display(df_original.limit(10))

# COMMAND ----------


spark.sql("""
    CREATE SCHEMA IF NOT EXISTS
    bi_nanoparuro_experimentos
""")

print("Esquema de experimentacion creado correctamente")

# COMMAND ----------


ventana = Window.orderBy("OrderID")

df_base = df_original.withColumn(
    "_indice",
    F.row_number().over(ventana) - 1
)

def generar_datos(cantidad):

    df_generado = (
        spark.range(cantidad)
        .withColumn("_indice", F.col("id") % 74)
        .join(df_base, "_indice", "inner")
        .withColumn(
            "OrderID",
            F.concat(
                F.lit("EXP-"),
                F.lpad(F.col("id").cast("string"), 10, "0")
            )
        )
        .drop("id", "_indice")
        .select(*df_original.columns)
    )

    return df_generado

df_prueba = generar_datos(1000)

print("Registros generados:", df_prueba.count())

display(df_prueba.limit(10))

# COMMAND ----------


volumenes = [74, 1000, 10000, 100000, 1000000]

resultados_exp01 = []

# Calentamiento inicial
generar_datos(1000).count()

for volumen in volumenes:

    tiempos = []

    df_exp = (
        df_original if volumen == 74
        else generar_datos(volumen)
    )

    for repeticion in range(3):

        inicio = perf_counter()

        resultado = (
            df_exp
            .filter(F.col("Cantidad") > 0)
            .withColumn(
                "ImporteVenta",
                F.col("Cantidad") * F.col("Precio")
            )
            .groupBy("Categoria")
            .agg(
                F.count("OrderID").alias("Pedidos"),
                F.sum("Cantidad").alias("Unidades"),
                F.sum("ImporteVenta").alias("Ventas")
            )
            .collect()
        )

        fin = perf_counter()

        tiempos.append(fin - inicio)

    promedio = mean(tiempos)

    resultados_exp01.append((
        volumen,
        round(tiempos[0], 4),
        round(tiempos[1], 4),
        round(tiempos[2], 4),
        round(promedio, 4)
    ))

    print(
        f"Registros: {volumen:,} | "
        f"Tiempo promedio: {promedio:.4f} segundos"
    )

print("EXPERIMENTO 01 FINALIZADO")

# COMMAND ----------


df_resultados_exp01 = spark.createDataFrame(
    resultados_exp01,
    [
        "CantidadRegistros",
        "Prueba1_seg",
        "Prueba2_seg",
        "Prueba3_seg",
        "TiempoPromedio_seg"
    ]
)

display(
    df_resultados_exp01.orderBy("CantidadRegistros")
)

# COMMAND ----------


df_resultados_exp01.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable(
        "bi_nanoparuro_experimentos.exp01_escalabilidad"
    )

print("Resultados almacenados correctamente")

display(
    spark.table(
        "bi_nanoparuro_experimentos.exp01_escalabilidad"
    ).orderBy("CantidadRegistros")
)

# COMMAND ----------


import matplotlib.pyplot as plt

pdf = df_resultados_exp01.orderBy(
    "CantidadRegistros"
).toPandas()

plt.figure(figsize=(10, 5))

plt.plot(
    pdf["CantidadRegistros"],
    pdf["TiempoPromedio_seg"],
    marker="o",
    linewidth=2
)

plt.xscale("log")

plt.title("NANOPARURO - Escalabilidad de Apache Spark")
plt.xlabel("Cantidad de registros")
plt.ylabel("Tiempo promedio (segundos)")
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

# COMMAND ----------


df_exp02_base = generar_datos(100000)

df_exp02 = df_exp02_base.unionByName(
    df_exp02_base
)

total_exp02 = df_exp02.count()

unicos_exp02 = (
    df_exp02.select("OrderID")
    .distinct()
    .count()
)

print("EXPERIMENTO 02")
print("Total de registros:", total_exp02)
print("Pedidos unicos:", unicos_exp02)
print("Duplicados:", total_exp02 - unicos_exp02)

# COMMAND ----------


ventana_exp02 = (
    Window.partitionBy("OrderID")
    .orderBy(F.col("FechaVenta").desc())
)

metodos = {
    "dropDuplicates": lambda: (
        df_exp02.dropDuplicates(["OrderID"])
    ),

    "distinct": lambda: (
        df_exp02.distinct()
    ),

    "ROW_NUMBER": lambda: (
        df_exp02
        .withColumn(
            "_fila",
            F.row_number().over(ventana_exp02)
        )
        .filter(F.col("_fila") == 1)
        .drop("_fila")
    )
}

resultados_exp02 = []

# Calentamiento inicial
for operacion in metodos.values():
    operacion().count()

# Ejecucion de las pruebas
for metodo, operacion in metodos.items():

    tiempos = []

    for repeticion in range(3):

        inicio = perf_counter()

        cantidad_final = operacion().count()

        fin = perf_counter()

        assert cantidad_final == 100000

        tiempos.append(fin - inicio)

    resultados_exp02.append((
        metodo,
        total_exp02,
        cantidad_final,
        total_exp02 - cantidad_final,
        round(tiempos[0], 4),
        round(tiempos[1], 4),
        round(tiempos[2], 4),
        round(mean(tiempos), 4)
    ))

    print(
        metodo,
        "| Tiempo promedio:",
        round(mean(tiempos), 4),
        "segundos"
    )

print("EXPERIMENTO 02 FINALIZADO")

# COMMAND ----------


df_resultados_exp02 = spark.createDataFrame(
    resultados_exp02,
    [
        "Metodo",
        "RegistrosIniciales",
        "RegistrosFinales",
        "DuplicadosEliminados",
        "Prueba1_seg",
        "Prueba2_seg",
        "Prueba3_seg",
        "TiempoPromedio_seg"
    ]
)

display(
    df_resultados_exp02.orderBy(
        "TiempoPromedio_seg"
    )
)

# COMMAND ----------


df_resultados_exp02.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable(
        "bi_nanoparuro_experimentos.exp02_duplicados"
    )

print("RESULTADOS ALMACENADOS CORRECTAMENTE")

display(
    spark.table(
        "bi_nanoparuro_experimentos.exp02_duplicados"
    ).orderBy("TiempoPromedio_seg")
)

# COMMAND ----------


import matplotlib.pyplot as plt

pdf_exp02 = df_resultados_exp02.orderBy(
    "TiempoPromedio_seg"
).toPandas()

plt.figure(figsize=(10, 5))

barras = plt.bar(
    pdf_exp02["Metodo"],
    pdf_exp02["TiempoPromedio_seg"],
    color=["#16a34a", "#2563eb", "#f59e0b"]
)

plt.bar_label(barras, fmt="%.4f s")

plt.title(
    "NANOPARURO - Comparacion de metodos de limpieza"
)

plt.xlabel("Metodo de eliminacion de duplicados")
plt.ylabel("Tiempo promedio (segundos)")

plt.ylim(
    0, max(pdf_exp02["TiempoPromedio_seg"]) * 1.2
)

plt.grid(axis="y", alpha=0.3)
plt.tight_layout()
plt.show()

# COMMAND ----------


df_exp03 = generar_datos(1000000)

total_exp03 = df_exp03.count()

categoria_exp03 = (
    df_exp03.groupBy("Categoria")
    .count()
    .orderBy(F.desc("count"), "Categoria")
    .first()["Categoria"]
)

filtrados_exp03 = df_exp03.filter(
    F.col("Categoria") == categoria_exp03
).count()

print("EXPERIMENTO 03")
print("Total de registros:", total_exp03)
print("Categoria seleccionada:", categoria_exp03)
print("Registros filtrados:", filtrados_exp03)

display(
    df_exp03.groupBy("Categoria")
    .count()
    .orderBy(F.desc("count"))
)

# COMMAND ----------


def agrupar_ventas(df):
    return df.groupBy("Categoria").agg(
        F.count("OrderID").alias("Pedidos"),
        F.sum("Cantidad").alias("Unidades"),
        F.sum(
            F.col("Cantidad") * F.col("Precio")
        ).alias("Ventas")
    )

metodos_exp03 = {
    "Filtrar antes de agrupar": lambda: (
        agrupar_ventas(
            df_exp03.filter(
                F.col("Categoria") == categoria_exp03
            )
        )
    ),

    "Filtrar despues de agrupar": lambda: (
        agrupar_ventas(df_exp03)
        .filter(
            F.col("Categoria") == categoria_exp03
        )
    )
}

resultados_exp03 = []

# Calentamiento inicial
for operacion in metodos_exp03.values():
    operacion().collect()

# Medicion de rendimiento
for metodo, operacion in metodos_exp03.items():

    tiempos = []

    for repeticion in range(3):

        inicio = perf_counter()

        resultado = operacion().collect()

        fin = perf_counter()

        assert resultado[0]["Pedidos"] == filtrados_exp03

        tiempos.append(fin - inicio)

    resultados_exp03.append((
        metodo,
        total_exp03,
        filtrados_exp03,
        round(tiempos[0], 4),
        round(tiempos[1], 4),
        round(tiempos[2], 4),
        round(mean(tiempos), 4)
    ))

    print(
        metodo,
        "| Tiempo promedio:",
        round(mean(tiempos), 4),
        "segundos"
    )

print("EXPERIMENTO 03 FINALIZADO")

# COMMAND ----------


df_resultados_exp03 = spark.createDataFrame(
    resultados_exp03,
    [
        "Metodo",
        "RegistrosIniciales",
        "RegistrosFiltrados",
        "Prueba1_seg",
        "Prueba2_seg",
        "Prueba3_seg",
        "TiempoPromedio_seg"
    ]
)

display(
    df_resultados_exp03.orderBy(
        "TiempoPromedio_seg"
    )
)

# Analisis de los planes de ejecucion
for metodo, operacion in metodos_exp03.items():

    print("\n" + "=" * 60)
    print(metodo)
    print("=" * 60)

    operacion().explain(mode="extended")

# COMMAND ----------


df_resultados_exp03.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable(
        "bi_nanoparuro_experimentos.exp03_optimizacion"
    )

print("RESULTADOS ALMACENADOS CORRECTAMENTE")

display(
    spark.table(
        "bi_nanoparuro_experimentos.exp03_optimizacion"
    ).orderBy("TiempoPromedio_seg")
)

# COMMAND ----------


import matplotlib.pyplot as plt

pdf_exp03 = (
    spark.table(
        "bi_nanoparuro_experimentos.exp03_optimizacion"
    )
    .orderBy("TiempoPromedio_seg")
    .toPandas()
)

plt.figure(figsize=(10, 5))

barras = plt.bar(
    pdf_exp03["Metodo"],
    pdf_exp03["TiempoPromedio_seg"],
    color=["#16a34a", "#2563eb"]
)

plt.bar_label(
    barras,
    fmt="%.4f s",
    padding=5
)

plt.title(
    "NANOPARURO - Optimizacion de consultas"
)

plt.xlabel("Metodo de procesamiento")
plt.ylabel("Tiempo promedio (segundos)")

plt.ylim(
    0,
    max(pdf_exp03["TiempoPromedio_seg"]) * 1.2
)

plt.grid(axis="y", alpha=0.3)
plt.tight_layout()
plt.show()

# COMMAND ----------


df_exp04 = generar_datos(1000000)

total_exp04 = df_exp04.count()

particiones_exp04 = [1, 2, 4, 8, 16]

print("EXPERIMENTO 04")
print("Total de registros:", total_exp04)
print("Configuraciones:", particiones_exp04)

display(df_exp04.limit(5))

# COMMAND ----------


from time import perf_counter
from statistics import mean
from pyspark.sql import functions as F

resultados_exp04 = []

def procesar_exp04(n):
    return (
        df_exp04.repartition(n)
        .groupBy("Categoria")
        .agg(
            F.count("*").alias("Pedidos"),
            F.sum("Cantidad").alias("Unidades"),
            F.sum(
                F.col("Cantidad") * F.col("Precio")
            ).alias("Ventas")
        )
        .collect()
    )

# Calentamiento inicial
procesar_exp04(4)

for n in particiones_exp04:

    tiempos = []

    for repeticion in range(3):

        inicio = perf_counter()

        resultado = procesar_exp04(n)

        fin = perf_counter()

        assert sum(
            fila["Pedidos"] for fila in resultado
        ) == total_exp04

        tiempos.append(fin - inicio)

    resultados_exp04.append((
        n,
        total_exp04,
        round(tiempos[0], 4),
        round(tiempos[1], 4),
        round(tiempos[2], 4),
        round(mean(tiempos), 4)
    ))

    print(
        n, "particiones",
        "| Tiempo promedio:",
        round(mean(tiempos), 4),
        "segundos"
    )

print("EXPERIMENTO 04 FINALIZADO")

# COMMAND ----------


df_resultados_exp04 = spark.createDataFrame(
    resultados_exp04,
    [
        "Particiones",
        "CantidadRegistros",
        "Prueba1_seg",
        "Prueba2_seg",
        "Prueba3_seg",
        "TiempoPromedio_seg"
    ]
)

display(
    df_resultados_exp04.orderBy("Particiones")
)

mejor_exp04 = (
    df_resultados_exp04
    .orderBy("TiempoPromedio_seg")
    .first()
)

print("MEJOR CONFIGURACION")
print("Particiones:", mejor_exp04["Particiones"])
print("Tiempo promedio:",
      mejor_exp04["TiempoPromedio_seg"],
      "segundos")

# COMMAND ----------


df_resultados_exp04.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable(
        "bi_nanoparuro_experimentos.exp04_particiones"
    )

print("RESULTADOS ALMACENADOS CORRECTAMENTE")

display(
    spark.table(
        "bi_nanoparuro_experimentos.exp04_particiones"
    ).orderBy("Particiones")
)

# COMMAND ----------


import matplotlib.pyplot as plt

pdf_exp04 = (
    spark.table(
        "bi_nanoparuro_experimentos.exp04_particiones"
    )
    .orderBy("Particiones")
    .toPandas()
)

plt.figure(figsize=(10, 5))

colores = [
    "#16a34a" if n == mejor_exp04["Particiones"]
    else "#2563eb"
    for n in pdf_exp04["Particiones"]
]

barras = plt.bar(
    pdf_exp04["Particiones"].astype(str),
    pdf_exp04["TiempoPromedio_seg"],
    color=colores
)

plt.bar_label(barras, fmt="%.4f s", padding=5)

plt.title(
    "NANOPARURO - Rendimiento por particiones"
)

plt.xlabel("Cantidad de particiones")
plt.ylabel("Tiempo promedio (segundos)")

plt.ylim(
    0,
    max(pdf_exp04["TiempoPromedio_seg"]) * 1.2
)

plt.grid(axis="y", alpha=0.3)
plt.tight_layout()
plt.show()

# COMMAND ----------


df_exp05 = generar_datos(1000000)

total_exp05 = df_exp05.count()

print("EXPERIMENTO 05")
print("Total de registros:", total_exp05)
print("Metodo A: Regeneracion de datos")
print("Metodo B: Reutilizacion de datos Delta")

display(df_exp05.limit(5))

# COMMAND ----------


from time import perf_counter

tabla_exp05 = (
    "bi_nanoparuro_experimentos.exp05_datos_delta"
)

inicio = perf_counter()

df_exp05.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable(tabla_exp05)

fin = perf_counter()

tiempo_materializacion_exp05 = round(fin - inicio, 4)

df_delta_exp05 = spark.table(tabla_exp05)

total_delta_exp05 = df_delta_exp05.count()

assert total_delta_exp05 == total_exp05

print("DATOS ALMACENADOS CORRECTAMENTE")
print("Tabla:", tabla_exp05)
print("Total de registros:", total_delta_exp05)
print("Tiempo de materializacion:",
      tiempo_materializacion_exp05, "segundos")

display(df_delta_exp05.limit(5))

# COMMAND ----------


from time import perf_counter
from statistics import mean
from pyspark.sql import functions as F

resultados_exp05 = []

def procesar_exp05(df):
    return (
        df.groupBy("Categoria")
        .agg(
            F.count("OrderID").alias("Pedidos"),
            F.sum("Cantidad").alias("Unidades"),
            F.sum(
                F.col("Cantidad") * F.col("Precio")
            ).alias("Ventas")
        )
        .orderBy("Categoria")
        .collect()
    )

metodos_exp05 = {
    "Regeneracion de datos":
        lambda: generar_datos(1000000),

    "Reutilizacion de datos Delta":
        lambda: spark.table(tabla_exp05)
}

referencia_exp05 = None

for metodo, obtener_datos in metodos_exp05.items():

    tiempos = []

    for repeticion in range(3):

        inicio = perf_counter()

        resultado = procesar_exp05(obtener_datos())

        fin = perf_counter()

        assert sum(
            fila["Pedidos"] for fila in resultado
        ) == total_exp05

        if referencia_exp05 is None:
            referencia_exp05 = resultado

        assert resultado == referencia_exp05, \
            "Los resultados no coinciden"

        tiempos.append(fin - inicio)

    resultados_exp05.append((
        metodo,
        total_exp05,
        round(tiempos[0], 4),
        round(tiempos[1], 4),
        round(tiempos[2], 4),
        round(mean(tiempos), 4)
    ))

    print(
        metodo,
        "| Tiempo promedio:",
        round(mean(tiempos), 4),
        "segundos"
    )

print("EXPERIMENTO 05 FINALIZADO")

# COMMAND ----------


from math import ceil

df_resultados_exp05 = spark.createDataFrame(
    resultados_exp05,
    [
        "Metodo",
        "CantidadRegistros",
        "Prueba1_seg",
        "Prueba2_seg",
        "Prueba3_seg",
        "TiempoPromedio_seg"
    ]
)

display(
    df_resultados_exp05.orderBy(
        "TiempoPromedio_seg"
    )
)

tiempo_regeneracion = resultados_exp05[0][5]
tiempo_delta = resultados_exp05[1][5]

ahorro_exp05 = tiempo_regeneracion - tiempo_delta

mejora_exp05 = (
    ahorro_exp05 / tiempo_regeneracion
) * 100

print("ANALISIS DEL EXPERIMENTO 05")
print("=" * 50)

print("Tiempo de regeneracion:",
      tiempo_regeneracion, "segundos")

print("Tiempo de reutilizacion Delta:",
      tiempo_delta, "segundos")

print("Tiempo de materializacion:",
      tiempo_materializacion_exp05, "segundos")

print("Ahorro por consulta:",
      round(ahorro_exp05, 4), "segundos")

print("Porcentaje de mejora:",
      round(mejora_exp05, 2), "%")

if ahorro_exp05 > 0:

    consultas_equilibrio = ceil(
        tiempo_materializacion_exp05 / ahorro_exp05
    )

    print("Consultas para compensar la materializacion:",
          consultas_equilibrio)

    print("MEJOR METODO: Reutilizacion de datos Delta")

else:
    print("No se obtuvo ahorro de tiempo con Delta")

# COMMAND ----------


df_resultados_exp05.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable(
        "bi_nanoparuro_experimentos.exp05_materializacion"
    )

print("RESULTADOS ALMACENADOS CORRECTAMENTE")

display(
    spark.table(
        "bi_nanoparuro_experimentos.exp05_materializacion"
    ).orderBy("TiempoPromedio_seg")
)

# COMMAND ----------


import matplotlib.pyplot as plt

pdf_exp05 = (
    spark.table(
        "bi_nanoparuro_experimentos.exp05_materializacion"
    )
    .orderBy("TiempoPromedio_seg")
    .toPandas()
)

plt.figure(figsize=(10, 5))

barras = plt.bar(
    pdf_exp05["Metodo"],
    pdf_exp05["TiempoPromedio_seg"],
    color=["#16a34a", "#2563eb"]
)

plt.bar_label(
    barras,
    fmt="%.4f s",
    padding=5
)

plt.title(
    "NANOPARURO - Regeneracion vs reutilizacion Delta"
)

plt.xlabel("Metodo de procesamiento")
plt.ylabel("Tiempo promedio (segundos)")

plt.ylim(
    0,
    max(pdf_exp05["TiempoPromedio_seg"]) * 1.2
)

plt.grid(axis="y", alpha=0.3)
plt.tight_layout()
plt.show()