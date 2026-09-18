USE AdventureWorks;
GO

-- this script creates all the synonyms for the SP

IF OBJECT_ID('syn_gp', 'SN') IS NOT NULL DROP SYNONYM syn_gp;
CREATE SYNONYM syn_gp FOR dbo.sp_GetProducts;
GO

IF OBJECT_ID('syn_gpc', 'SN') IS NOT NULL DROP SYNONYM syn_gpc;
CREATE SYNONYM syn_gpc FOR dbo.sp_GetProductsWithCategory;
GO

IF OBJECT_ID('syn_ip', 'SN') IS NOT NULL DROP SYNONYM syn_ip;
CREATE SYNONYM syn_ip FOR dbo.sp_InsertProduct;
GO

IF OBJECT_ID('syn_up', 'SN') IS NOT NULL DROP SYNONYM syn_up;
CREATE SYNONYM syn_up FOR dbo.sp_UpdateProduct;
GO

IF OBJECT_ID('syn_dp', 'SN') IS NOT NULL DROP SYNONYM syn_dp;
CREATE SYNONYM syn_dp FOR dbo.sp_DeleteProduct;
GO