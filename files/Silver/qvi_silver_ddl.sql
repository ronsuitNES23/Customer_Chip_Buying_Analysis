/*
==================================================================
Create Tables for the Silver Schema
==================================================================
Script Purpose:
	This script creates  new tables for 'ChipStore' silver schema from Bronze tables
*/
USE ChipStore;


-- creating silver.qvi_customers table
IF OBJECT_ID('silver.qvi_customers', 'U') IS NOT NULL
	DROP TABLE silver.qvi_customers;
	GO
	-- Create the silver customers table
	CREATE TABLE silver.qvi_customers (
		-- Customer Identifier
		lylty_card_nbr     INT,
		
		-- Customer Segmentation
		lifestage           NVARCHAR(50),
		premium_customer    NVARCHAR(20),
		
		-- Metadata (for data lineage and auditing)
		dwh_create_date		DATETIME2 DEFAULT GETDATE()

		-- Primary Key
		CONSTRAINT pk_silver_qvi_customers PRIMARY KEY (LYLTY_CARD_NBR)
	);	

	-- creating silver.qvi_transactions table
	IF OBJECT_ID('silver.qvi_transactions', 'U') IS NOT NULL
	DROP TABLE silver.qvi_transactions;
		GO
		-- Create the silver transactions table
		CREATE TABLE silver.qvi_transactions (
			-- Transaction Identifiers
			trx_date INT,
			store_nbr INT,
			
			-- Customer Information
			lylty_card_nbr INT,
			
			-- Product Information
			txn_id INT,
			prod_nbr INT,
			prod_name NVARCHAR(50),
			prod_qty INT,
			
			-- Transaction Details
			tot_sales DECIMAL(10, 2),
			
			-- Metadata (for data lineage and auditing)
			dwh_create_date		DATETIME2 DEFAULT GETDATE()
		);	
		GO

	-- Checking tables
	SELECT *
	FROM silver.qvi_customers;

	SELECT *
	FROM silver.qvi_transactions;
