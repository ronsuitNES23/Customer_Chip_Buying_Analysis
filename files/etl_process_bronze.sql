/*
===========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===========================================================================
Script Purpose:
  This stored procedure load data into the 'bronze' schema from external CSV files;
  It performs the following actions:
  - Truncates the bronze tables before loading data
  - Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
  None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
===========================================================================
*/

-- Creating a Stored Procedure to load data into the Bronze layer tables
CREATE OR ALTER PROCEDURE bronze.load_bronze_ChipStore
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY
			SET @batch_start_time = GETDATE();
			PRINT '==================================================';
			PRINT 'Loading data into Bronze Layer Tables';
			PRINT '==================================================';
			PRINT '---------------------------------------------------';
			PRINT 'Loading QVI Source Tables';
			PRINT '---------------------------------------------------';

			--=========================================
			-- for qvi_transactions
			--=========================================
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.qvi_transactions';
			TRUNCATE TABLE bronze.qvi_transactions;
			PRINT '.. Inserting data into bronze.qvi_transactions';
			BULK INSERT bronze.qvi_transactions
			FROM 'C:\Users\rekva\OneDrive\Desktop\quantium\QVI_transaction_data.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				ROWTERMINATOR = '\n',
				TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.qvi_transactions: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '---------------------------------------------------';
			
			--=========================================
			--for qvi_customers
			--=========================================
			SET @start_time = GETDATE();
			PRINT '>> Truncating and Loading bronze.crm_prd_info';
			TRUNCATE TABLE bronze.qvi_customers
			PRINT '.. Inserting data into bronze.crm_prd_info';
			BULK INSERT bronze.qvi_customers
			FROM 'C:\Users\rekva\OneDrive\Desktop\quantium\QVI_purchase_behaviour.csv'
			WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				ROWTERMINATOR = '\n',
				TABLOCK
			);
			SET @end_time = GETDATE();
			PRINT '.. Time taken to load bronze.qvi_customers: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '---------------------------------------------------';

			
			SET @batch_end_time = GETDATE();

			PRINT '==================================================';
			PRINT 'Data loading into Bronze Layer Tables completed successfully';
			PRINT 'Total Time taken to load data into Bronze Layer Tables: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10)) + ' seconds';
			PRINT '==================================================';

	END TRY
		BEGIN CATCH
			PRINT '==================================================';
			PRINT 'Error occurred while loading data into Bronze Layer Tables';
			PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
			PRINT 'Error Message: ' + ERROR_MESSAGE();
			PRINT '==================================================';
		END CATCH
END;
GO
