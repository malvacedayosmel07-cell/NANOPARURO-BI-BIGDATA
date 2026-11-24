# Diagrama de arquitectura Big Data - NANOPARURO

```mermaid
flowchart TD
    A["FUENTES DE DATOS<br/>74 pedidos originales"] --> B
    B["INGESTA DE DATOS<br/>Databricks - Apache Spark"] --> C
    C["DataFrames de PySpark"] --> D
    D["Análisis exploratorio - EDA"] --> E
    E["Limpieza y transformación"] --> F
    F["Ampliación mediante datos sintéticos"] --> G
    G["Validación de calidad de datos"] --> H
    H["Persistencia - Tablas Delta"] --> I
    I["Modelo dimensional y ventas_limpias"] --> J
    J["Dashboard Databricks AI/BI"] --> K
    K["9 indicadores KPI y 10 gráficos"]

    style A fill:#1e40af,color:#fff
    style B fill:#c2410c,color:#fff
    style C fill:#c2410c,color:#fff
    style D fill:#0f766e,color:#fff
    style E fill:#0f766e,color:#fff
    style F fill:#0f766e,color:#fff
    style G fill:#0f766e,color:#fff
    style H fill:#7e22ce,color:#fff
    style I fill:#7e22ce,color:#fff
    style J fill:#164e63,color:#fff
    style K fill:#164e63,color:#fff
```

## Descripción

La arquitectura representa el flujo de procesamiento de
los datos comerciales de NANOPARURO, desde la ingesta
hasta la generación de indicadores y visualizaciones
para la toma de decisiones.
