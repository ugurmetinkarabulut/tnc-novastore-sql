-- NovaStore E-Ticaret Veri Yönetim Sistemi
-- Uğur Metin Karabulut
-- SQL Server / T-SQL
-- Bu dosyayı SSMS veya GO destekleyen bir SQL istemcisiyle çalıştırın.
-- Mevcut NovaStoreDB korunur. Örnek veriler yalnızca boş tablolara eklenir.

-- BÖLÜM 1 - Veri tabanı oluşturma
USE master;
GO
IF DB_ID(N'NovaStoreDB') IS NULL
    CREATE DATABASE NovaStoreDB COLLATE Turkish_100_CI_AS_SC_UTF8;
GO
USE NovaStoreDB;
GO

-- BÖLÜM 1 - Ana tablolar
IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
CREATE TABLE dbo.Categories (
    CategoryID int IDENTITY(1,1) PRIMARY KEY,
    CategoryName varchar(50) NOT NULL
);
IF OBJECT_ID(N'dbo.Customers', N'U') IS NULL
CREATE TABLE dbo.Customers (
    CustomerID int IDENTITY(1,1) PRIMARY KEY,
    FullName varchar(50) NOT NULL,
    City varchar(20) NOT NULL,
    Email varchar(100) NOT NULL UNIQUE
);

-- BÖLÜM 1 - Bağımlı tablolar
IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
CREATE TABLE dbo.Products (
    ProductID int IDENTITY(1,1) PRIMARY KEY,
    ProductName varchar(100) NOT NULL,
    Price decimal(10,2) NOT NULL CHECK (Price >= 0),
    Stock int NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    CategoryID int NOT NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID)
);
IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL
CREATE TABLE dbo.Orders (
    OrderID int IDENTITY(1,1) PRIMARY KEY,
    CustomerID int NOT NULL,
    OrderDate datetime NOT NULL DEFAULT GETDATE(),
    TotalAmount decimal(10,2) NOT NULL CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID)
);
IF OBJECT_ID(N'dbo.OrderDetails', N'U') IS NULL
CREATE TABLE dbo.OrderDetails (
    DetailID int IDENTITY(1,1) PRIMARY KEY,
    OrderID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL CHECK (Quantity > 0),
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID)
);
GO

-- BÖLÜM 2 - Örnek veri ekleme
-- Tüm örnek veri tek transaction içinde eklenir.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
AND NOT EXISTS (SELECT 1 FROM dbo.Customers)
AND NOT EXISTS (SELECT 1 FROM dbo.Products)
AND NOT EXISTS (SELECT 1 FROM dbo.Orders)
AND NOT EXISTS (SELECT 1 FROM dbo.OrderDetails)
BEGIN
    SET IDENTITY_INSERT dbo.Categories ON;
    INSERT dbo.Categories (CategoryID, CategoryName) VALUES
    (1,N'Elektronik'), (2,N'Giyim'), (3,N'Kitap'), (4,N'Kozmetik'), (5,N'Ev ve Yaşam');
    SET IDENTITY_INSERT dbo.Categories OFF;

    SET IDENTITY_INSERT dbo.Products ON;
    INSERT dbo.Products (ProductID,ProductName,Price,Stock,CategoryID) VALUES
    (1,N'Kablosuz Kulaklık',1200.00,15,1),
    (2,N'Bluetooth Hoparlör',900.00,35,1),
    (3,N'USB Bellek',250.00,8,1),
    (4,N'Pamuklu Tişört',350.00,50,2),
    (5,N'Kot Pantolon',800.00,12,2),
    (6,N'JavaScript Kitabı',450.00,18,3),
    (7,N'SQL Başlangıç Kitabı',400.00,25,3),
    (8,N'Nemlendirici Krem',300.00,10,4),
    (9,N'Güneş Kremi',500.00,22,4),
    (10,N'Seramik Kupa',150.00,16,5),
    (11,N'Masa Lambası',600.00,7,5),
    (12,N'Defter Seti',200.00,40,5);
    SET IDENTITY_INSERT dbo.Products OFF;

    SET IDENTITY_INSERT dbo.Customers ON;
    INSERT dbo.Customers (CustomerID,FullName,City,Email) VALUES
    (1,N'Ahmet Yılmaz',N'İstanbul','ahmet@example.com'),
    (2,N'Ayşe Demir',N'Ankara','ayse@example.com'),
    (3,N'Mehmet Kaya',N'İzmir','mehmet@example.com'),
    (4,N'Elif Çelik',N'Bursa','elif@example.com'),
    (5,N'Can Arslan',N'Antalya','can@example.com'),
    (6,N'Zeynep Aydın',N'Eskişehir','zeynep@example.com');
    SET IDENTITY_INSERT dbo.Customers OFF;

    SET IDENTITY_INSERT dbo.Orders ON;
    INSERT dbo.Orders (OrderID,CustomerID,OrderDate,TotalAmount) VALUES
    (1,1,DATEADD(day,-30,GETDATE()),0),
    (2,2,DATEADD(day,-24,GETDATE()),0),
    (3,3,DATEADD(day,-20,GETDATE()),0),
    (4,1,DATEADD(day,-16,GETDATE()),0),
    (5,4,DATEADD(day,-12,GETDATE()),0),
    (6,5,DATEADD(day,-10,GETDATE()),0),
    (7,2,DATEADD(day,-7,GETDATE()),0),
    (8,3,DATEADD(day,-5,GETDATE()),0),
    (9,4,DATEADD(day,-2,GETDATE()),0),
    (10,1,GETDATE(),0);
    SET IDENTITY_INSERT dbo.Orders OFF;

    INSERT dbo.OrderDetails (OrderID,ProductID,Quantity) VALUES
    (1,1,1),(1,10,2),(2,4,2),(2,5,1),(3,6,1),(3,7,1),
    (4,2,1),(4,3,2),(5,8,2),(5,9,1),(6,11,1),(6,12,2),
    (7,1,1),(7,4,1),(8,7,2),(8,10,3),(9,5,1),(9,8,1),
    (10,6,1),(10,12,2);

    -- Sipariş toplamı örnek verideki miktar ve ürün fiyatlarından hesaplanır.
    UPDATE o
    SET TotalAmount = totals.Amount
    FROM dbo.Orders AS o
    JOIN (
        SELECT d.OrderID, SUM(d.Quantity * p.Price) AS Amount
        FROM dbo.OrderDetails AS d
        JOIN dbo.Products AS p ON p.ProductID = d.ProductID
        GROUP BY d.OrderID
    ) AS totals ON totals.OrderID = o.OrderID;
END;
COMMIT TRANSACTION;
GO

-- BÖLÜM 3 - Görev 1 - Stoku 20'den az ürünler, azalan stok
SELECT ProductName AS UrunAdi, Stock AS Stok
FROM dbo.Products
WHERE Stock < 20
ORDER BY Stock DESC, ProductID;

-- BÖLÜM 3 - Görev 2 - Müşteriler ve siparişleri
SELECT c.FullName AS MusteriAdi, c.City AS Sehir,
       o.OrderDate AS SiparisTarihi, o.TotalAmount AS ToplamTutar
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate, o.OrderID;

-- BÖLÜM 3 - Görev 3 - Ahmet Yılmaz'ın aldığı ürünler ve kategoriler
SELECT c.FullName AS MusteriAdi, p.ProductName AS UrunAdi,
       p.Price AS Fiyat, cat.CategoryName AS Kategori, d.Quantity AS Adet
FROM dbo.Customers AS c
JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
JOIN dbo.OrderDetails AS d ON d.OrderID = o.OrderID
JOIN dbo.Products AS p ON p.ProductID = d.ProductID
JOIN dbo.Categories AS cat ON cat.CategoryID = p.CategoryID
WHERE c.FullName = N'Ahmet Yılmaz'
ORDER BY o.OrderID, d.DetailID;

-- BÖLÜM 3 - Görev 4 - Her kategorideki ürün kaydı sayısı
SELECT cat.CategoryName AS Kategori, COUNT(p.ProductID) AS UrunSayisi
FROM dbo.Categories AS cat
LEFT JOIN dbo.Products AS p ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY cat.CategoryID;

-- BÖLÜM 3 - Görev 5 - Müşteri bazında toplam ciro
-- Hiç sipariş vermemiş müşteriler de sıfır ciro ile görünür.
SELECT c.FullName AS MusteriAdi, COALESCE(SUM(o.TotalAmount),0) AS ToplamCiro
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY ToplamCiro DESC, c.FullName;

-- BÖLÜM 3 - Görev 6 - Siparişin üzerinden geçen gün
SELECT OrderID AS SiparisNo, OrderDate AS SiparisTarihi,
       DATEDIFF(day,OrderDate,GETDATE()) AS GecenGun
FROM dbo.Orders
ORDER BY OrderID;
GO

-- BÖLÜM 4 - Görev 1 - Sipariş özet görünümü
CREATE OR ALTER VIEW dbo.vw_SiparisOzet
AS
SELECT c.FullName AS MusteriAdi, o.OrderDate AS SiparisTarihi,
       p.ProductName AS UrunAdi, d.Quantity AS Adet
FROM dbo.Customers AS c
JOIN dbo.Orders AS o ON o.CustomerID = c.CustomerID
JOIN dbo.OrderDetails AS d ON d.OrderID = o.OrderID
JOIN dbo.Products AS p ON p.ProductID = d.ProductID;
GO
SELECT * FROM dbo.vw_SiparisOzet;
GO

-- BÖLÜM 4 - Görev 2 - Yedekleme
-- Windows sunucuda C:\Yedek klasörünü oluşturun ve SQL Server
-- servis hesabına bu klasöre yazma yetkisi verin.
-- Yeni yedek mevcut dosyaya eklenir.
IF (SELECT host_platform FROM sys.dm_os_host_info) = N'Windows'
BEGIN
    BACKUP DATABASE NovaStoreDB
    TO DISK = N'C:\Yedek\NovaStoreDB.bak'
    WITH NOINIT, CHECKSUM, STATS = 10;
END
ELSE
BEGIN
    -- Linux test ortamında mevcut ve yazılabilir varsayılan veri klasörü.
    BACKUP DATABASE NovaStoreDB
    TO DISK = N'/var/opt/mssql/data/NovaStoreDB.bak'
    WITH NOINIT, CHECKSUM, STATS = 10;
END;
GO
