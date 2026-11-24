# Medidas DAX - NANOPARURO

## Descripción

El dashboard comercial de NANOPARURO utiliza medidas DAX
(Data Analysis Expressions) para calcular indicadores clave
de rendimiento (KPI), facilitando el análisis de ventas,
clientes, productos, vendedores y costos de transporte.

Las medidas se encuentran implementadas en la tabla FACT_VENTAS
del modelo dimensional de Power BI.

## 1. Ventas Totales

Calcula el importe total de las ventas sin incluir el costo
de flete.

```dax
Ventas Totales =
SUMX(
    FACT_VENTAS,
    FACT_VENTAS[Cantidad] * FACT_VENTAS[Precio]
)
```

## 2. Total Pedidos

Calcula la cantidad de pedidos únicos registrados.

```dax
Total Pedidos =
DISTINCTCOUNT(FACT_VENTAS[OrderID])
```

## 3. Unidades Vendidas

Calcula la cantidad total de unidades comercializadas.

```dax
Unidades Vendidas =
SUM(FACT_VENTAS[Cantidad])
```

## 4. Total Clientes

Calcula la cantidad de clientes distintos que realizaron compras.

```dax
Total Clientes =
DISTINCTCOUNT(FACT_VENTAS[ClienteKey])
```

## 5. Total Productos

Calcula la cantidad de productos distintos comercializados.

```dax
Total Productos =
DISTINCTCOUNT(FACT_VENTAS[ProductoKey])
```

## 6. Ticket Promedio

Calcula el importe promedio de venta por pedido, evitando
errores de división entre cero.

```dax
Ticket Promedio =
DIVIDE([Ventas Totales], [Total Pedidos], 0)
```

## 7. Costo Total Flete

Calcula la suma de los costos de transporte asociados
a las operaciones comerciales.

```dax
Costo Total Flete =
SUM(FACT_VENTAS[CostoFlete])
```

## 8. Importe con Flete

Calcula el importe total de las ventas incluyendo
los costos de transporte.

```dax
Importe con Flete =
[Ventas Totales] + [Costo Total Flete]
```

## 9. Total Vendedores

Calcula la cantidad de vendedores distintos que participaron
en las operaciones comerciales.

```dax
Total Vendedores =
DISTINCTCOUNT(FACT_VENTAS[VendedorKey])
```

## Resultados obtenidos

Periodo de análisis: marzo - junio de 2026.

| Indicador | Resultado |
|---|---:|
| Ventas Totales | $9.59 mil |
| Total Pedidos | 74 |
| Unidades Vendidas | 525 |
| Total Clientes | 12 |
| Total Productos | 10 |
| Ticket Promedio | $129.57 |
| Costo Total Flete | $846.00 |
| Importe con Flete | $10.43 mil |
| Total Vendedores | 5 |

## Funciones DAX utilizadas

- SUMX: cálculo de expresiones por cada fila.
- SUM: suma de valores numéricos.
- DISTINCTCOUNT: conteo de valores únicos.
- DIVIDE: división segura de valores.

## Tecnología utilizada

- Microsoft Power BI Desktop.
- Lenguaje DAX.
- Microsoft SQL Server.
- Modelo dimensional estrella.

## Conclusión

Las medidas DAX permiten transformar los datos comerciales
en indicadores de rendimiento que facilitan el análisis
del comportamiento de las ventas y apoyan la toma de
decisiones comerciales de NANOPARURO.
