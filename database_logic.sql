/*******************************************************************************
  PROYECTO: Global Sales Data Warehouse & Analytics
  OBJETIVO: Demostrar arquitectura de datos escalable para mercados globales.
  CAPACIDAD: Diseñado para procesar +3.1M de registros.
*******************************************************************************/

-- 1. CREACIÓN DE ESTRUCTURA (MODELO RELACIONAL)
CREATE TABLE Dim_Geografia (
    ID_Pais INTEGER PRIMARY KEY,
    Pais TEXT,
    Continente TEXT,
    Codigo_ISO TEXT
);

CREATE TABLE Dim_Productos (
    ID_Producto INTEGER PRIMARY KEY,
    Nombre_Producto TEXT,
    Categoria TEXT,
    Precio_Unitario REAL,
    Costo_Unitario REAL
);

CREATE TABLE Dim_Clientes (
    ID_Cliente INTEGER PRIMARY KEY,
    Nombre_Empresa TEXT,
    Sector TEXT,
    Tipo_Cliente TEXT
);

CREATE TABLE Hechos_Ventas (
    ID_Venta INTEGER PRIMARY KEY,
    Fecha DATE,
    ID_Producto INTEGER,
    ID_Cliente INTEGER,
    ID_Pais INTEGER,
    Cantidad INTEGER,
    Monto_Total REAL,
    FOREIGN KEY (ID_Producto) REFERENCES Dim_Productos(ID_Producto),
    FOREIGN KEY (ID_Cliente) REFERENCES Dim_Clientes(ID_Cliente),
    FOREIGN KEY (ID_Pais) REFERENCES Dim_Geografia(ID_Pais)
);

-- 2. ANÁLISIS DE RENTABILIDAD GLOBAL
-- Esta consulta calcula el margen de beneficio neto por producto.
-- Fórmula utilizada: $$Beneficio = IngresoTotal - (CostoUnitario \times Cantidad)$$
SELECT 
    p.Nombre_Producto,
    p.Categoria,
    SUM(v.Cantidad) AS Unidades_Vendidas,
    ROUND(SUM(v.Monto_Total), 2) AS Ingresos_Totales,
    ROUND(SUM(v.Monto_Total - (p.Costo_Unitario * v.Cantidad)), 2) AS Beneficio_Neto,
    ROUND(AVG((v.Monto_Total - (p.Costo_Unitario * v.Cantidad)) / v.Monto_Total * 100), 2) || '%' AS Margen_Promedio
FROM Hechos_Ventas AS v
INNER JOIN Dim_Productos AS p ON v.ID_Producto = p.ID_Producto
GROUP BY p.Nombre_Producto
ORDER BY Beneficio_Neto DESC;

-- 3. VISTA PARA DASHBOARD DE GERENCIA
CREATE VIEW Dashboard_Rentabilidad AS
SELECT 
    p.Nombre_Producto,
    SUM(v.Monto_Total) AS Total_Ventas,
    g.Pais
FROM Hechos_Ventas AS v
JOIN Dim_Productos AS p ON v.ID_Producto = p.ID_Producto
JOIN Dim_Geografia AS g ON v.ID_Pais = g.ID_Pais
GROUP BY p.Nombre_Producto, g.Pais;
