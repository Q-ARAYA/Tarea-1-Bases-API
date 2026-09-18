USE AdventureWorks;
GO

-- this one is the SP of the basic select
-- I use the SET NOCOUNT ON; to sent only the query result, to avoid the regular mesagge of '5 rows affected' or similar 

CREATE OR ALTER PROCEDURE sp_GetProducts
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductID, Name, ProductNumber, ListPrice, ProductSubcategoryID
    FROM Production.Product;
END
GO

-- this one is the SP for the select but now with join
CREATE OR ALTER PROCEDURE sp_GetProductsWithCategory
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductID, p.Name, p.ProductNumber, p.ListPrice,
           s.Name AS Subcategory
    FROM Production.Product p
    JOIN Production.ProductSubcategory s
        ON p.ProductSubcategoryID = s.ProductSubcategoryID;
END
GO


-- this one is the SP to insert new data
CREATE OR ALTER PROCEDURE sp_InsertProduct
    @Name NVARCHAR(50),
    @ProductNumber NVARCHAR(25),
    @ListPrice MONEY,
    @ProductSubcategoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Production.Product
        (Name, ProductNumber, ListPrice, ProductSubcategoryID,
         SafetyStockLevel, ReorderPoint, StandardCost, DaysToManufacture,
         SellStartDate, rowguid, ModifiedDate)
    VALUES
        (@Name, @ProductNumber, @ListPrice, @ProductSubcategoryID,
         100, 75, @ListPrice * 0.6, 1,
         GETDATE(), NEWID(), GETDATE());

    SELECT SCOPE_IDENTITY() AS NewProductID;
END
GO

-- this one is the SP to update a record 
CREATE OR ALTER PROCEDURE sp_UpdateProduct
    @ProductID INT,
    @Name NVARCHAR(50),
    @ListPrice MONEY
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Production.Product
    SET Name = @Name,
        ListPrice = @ListPrice,
        ModifiedDate = GETDATE()
    WHERE ProductID = @ProductID;
END
GO


-- this is the sp to delete a record 
CREATE OR ALTER PROCEDURE sp_DeleteProduct
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Production.Product WHERE ProductID = @ProductID;
END
GO
