/*
=====================================================
-- Creating Tables for the Bronze layer. 
* All names names must start with the sourcve system name, and the table names must 
match their original names without renaming.
* <sourcesystem>_<entity>
	* <sourcesystem>: Nmae of the source system (qvi)
	* <entity>: Extract table name from the source system
	* Exmaple: qvi_transactions - transactions data form the QVI system.
    * DATE	STORE_NBR	LYLTY_CARD_NBR	TXN_ID	PROD_NBR	PROD_NAME	PROD_QTY	TOT_SALES
=======================================================
*/
USE ChipStore;
-- Creating Tables for qvi.
-- For transactions
-- Drop table if exists (for development/testing)
IF OBJECT_ID('bronze.qvi_transactions', 'U') IS NOT NULL
    DROP TABLE bronze.qvi_transactions;
GO

-- Create the bronze transactions table
CREATE TABLE bronze.qvi_transactions (
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
);
GO


-- For Customer Information
IF OBJECT_ID('bronze.qvi_customers', 'U') IS NOT NULL
    DROP TABLE bronze.qvi_customers;
GO

-- Create the bronze customers table
CREATE TABLE bronze.qvi_customers (
    -- Customer Identifier
    lylty_card_nbr     INT,
    
    -- Customer Segmentation
    lifestage           NVARCHAR(50),
    premium_customer    NVARCHAR(20),
    
    -- Metadata (for data lineage and auditin
    
    -- Primary Key
    CONSTRAINT pk_qvi_customers PRIMARY KEY (LYLTY_CARD_NBR)
);
GO

-- creating Indexes for performance optimization
CREATE INDEX idx_qvi_transactions_date_store ON bronze.qvi_transactions (trx_date, store_nbr);

-- Index on customer ID for joins with customer table
CREATE NONCLUSTERED INDEX idx_bronze_transactions_customer 
ON bronze.qvi_transactions(lylty_card_nbr);
GO

-- Index on date for time-based queries
CREATE NONCLUSTERED INDEX idx_bronze_transactions_date 
ON bronze.qvi_transactions(date_value);
GO

-- Index on store for store-level analysis
CREATE NONCLUSTERED INDEX idx_bronze_transactions_store 
ON bronze.qvi_transactions(store_nbr);
GO

-- Index on product for product-level analysis
CREATE NONCLUSTERED INDEX idx_bronze_transactions_product 
ON bronze.qvi_transactions(prod_nbr);
GO

-- Composite index on transaction ID and date for duplicate detection
CREATE NONCLUSTERED INDEX idx_bronze_transactions_txn_date 
ON bronze.qvi_transactions(txn_id, date_value);
GO

-- Index on lifestage for segmentation analysis
CREATE NONCLUSTERED INDEX idx_bronze_customers_lifestage 
ON bronze.qvi_customers(lifestage);
GO

-- Index on premium_customer for tier analysis
CREATE NONCLUSTERED INDEX idx_bronze_customers_premium 
ON bronze.qvi_customers(premium_customer);
GO

-- Composite index for segment combinations
CREATE NONCLUSTERED INDEX idx_bronze_customers_segment 
ON bronze.qvi_customers(lifestage, premium_customer);
GO
