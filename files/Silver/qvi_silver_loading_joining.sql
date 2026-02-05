/*
--================================================================
-- Project: ChipStore Data Warehouse
-- Tables: silver.qvi_transactions, silver.qvi_customers
-- Description: Transform and load data from bronze.qvi_transactions to silver.qvi_transactions
-- Final Table Structure: silver.qvi_customers_transactions
--================================================================
*/

-- For qvi.silver_transactions

-- Drop table if it exists
IF OBJECT_ID('silver.qvi_transactions', 'U') IS NOT NULL
    DROP TABLE silver.qvi_transactions;

-- Create the silver table
CREATE TABLE silver.qvi_transactions (
    trx_date DATETIME NOT NULL,
    store_nbr INT NOT NULL,
    lylty_card_nbr INT NOT NULL,
    txn_id INT NOT NULL,
    prod_nbr INT NOT NULL,
    prod_name NVARCHAR(255) NOT NULL,
    prod_weight INT NOT NULL,
    unit_price DECIMAL(10,2) NULL,
    prod_qty INT NOT NULL,
    tot_sales DECIMAL(10,2) NOT NULL,
    dwh_create_date DATETIME NOT NULL
 
);

-- Insert data
WITH cleaned AS (
    SELECT
        trx_date,
        store_nbr,
        lylty_card_nbr,
        txn_id,
        prod_nbr,
        -- Clean multiple spaces
        LTRIM(RTRIM(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                prod_name,
            '          ', ' '),
            '         ', ' '),
            '        ', ' '),
            '       ', ' '),
            '      ', ' '),
            '     ', ' '),
            '    ', ' '),
            '   ', ' '),
            '  ', ' ')
        )) AS prod_name_clean,
        prod_qty,
        tot_sales
    FROM bronze.qvi_transactions
),
extracted AS (
    SELECT
        *,
        -- Extract weight pattern (digits followed by 'g')
        SUBSTRING(
            prod_name_clean,
            PATINDEX('%[0-9]%g%', prod_name_clean),
            PATINDEX('%g%', SUBSTRING(prod_name_clean, PATINDEX('%[0-9]%g%', prod_name_clean), LEN(prod_name_clean))) + 1
        ) AS weight_text,
        -- Remove weight from product name
        LTRIM(RTRIM(
            REPLACE(
                prod_name_clean,
                SUBSTRING(
                    prod_name_clean,
                    PATINDEX('%[0-9]%g%', prod_name_clean),
                    PATINDEX('%g%', SUBSTRING(prod_name_clean, PATINDEX('%[0-9]%g%', prod_name_clean), LEN(prod_name_clean))) + 1
                ),
                ''
            )
        )) AS prod_name_final
    FROM cleaned
)
INSERT INTO silver.qvi_transactions (
    trx_date,
    store_nbr,
    lylty_card_nbr,
    txn_id,
    prod_nbr,
    prod_name,
    prod_weight,
    unit_price,
    prod_qty,
    tot_sales,
    dwh_create_date
)
SELECT
    DATEADD(DAY, trx_date - 2, '1900-01-01') AS trx_date,
    store_nbr,
    lylty_card_nbr,
    txn_id,
    prod_nbr,
    REPLACE(REPLACE(prod_name_final, '  ', ' '), '  ', ' ') AS prod_name,
    CAST(REPLACE(weight_text, 'g', '') AS INT) AS prod_weight,
    CAST(tot_sales / NULLIF(prod_qty, 0) AS DECIMAL(10,2)) AS unit_price,
    prod_qty,
    tot_sales,
    GETDATE() AS dwh_create_date
FROM extracted;

-- Verify the insert
SELECT COUNT(*) AS total_records FROM silver.qvi_transactions;
SELECT * FROM silver.qvi_transactions;

-- DISTINCT lylty_card_nbrs
SELECT COUNT(DISTINCT lylty_card_nbr) AS distinct_loyalty_cards
FROM silver.qvi_transactions;


-- for qvi_customers
SELECT *
FROM silver.qvi_customers

--Insert into silver layer

-- Drop table if it exists
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

);

INSERT INTO silver.qvi_customers(
    lylty_card_nbr,
    lifestage,
    premium_customer
)

SELECT
    lylty_card_nbr,
    lifestage,
    premium_customer
FROM bronze.qvi_customers;

-- Verify the insert
SELECT COUNT(*) AS total_records FROM silver.qvi_customers;
SELECT TOP 10 * FROM silver.qvi_transactions;


-- Joining the qvi_customers and qvi_transactions tables to get a complete view of customer transactions
SELECT 
	c.lylty_card_nbr,
	c.lifestage,
	c.premium_customer,
	t.trx_date,
	t.store_nbr,
	t.txn_id,
	t.prod_nbr,
	t.prod_name,
	t.prod_weight,
	t.unit_price,
	t.prod_qty,
	t.tot_sales
	FROM
	silver.qvi_customers c
	INNER JOIN silver.qvi_transactions t
	ON c.lylty_card_nbr = t.lylty_card_nbr;

-- Insert joined data into a new table for further analysis
-- Drop table if it exists
IF OBJECT_ID('silver.qvi_customer_transactions', 'U') IS NOT NULL
    DROP TABLE silver.qvi_customer_transactions;

-- Create table with explicit structure
CREATE TABLE silver.qvi_customer_transactions (
    lylty_card_nbr INT NOT NULL,
    lifestage NVARCHAR(50) NOT NULL,
    premium_customer NVARCHAR(50) NOT NULL,
    trx_date DATETIME NOT NULL,
    store_nbr INT NOT NULL,
    txn_id INT NOT NULL,
    prod_nbr INT NOT NULL,
    prod_name NVARCHAR(255) NOT NULL,
    prod_weight INT NOT NULL,
    unit_price DECIMAL(10,2) NULL,
    prod_qty INT NOT NULL,
    tot_sales DECIMAL(10,2) NOT NULL,
    dwh_create_date DATETIME NOT NULL
);

-- Insert data from JOIN
INSERT INTO silver.qvi_customer_transactions (
    lylty_card_nbr,
    lifestage,
    premium_customer,
    trx_date,
    store_nbr,
    txn_id,
    prod_nbr,
    prod_name,
    prod_weight,
    unit_price,
    prod_qty,
    tot_sales,
    dwh_create_date
)
SELECT 
    c.lylty_card_nbr,
    c.lifestage,
    c.premium_customer,
    t.trx_date,
    t.store_nbr,
    t.txn_id,
    t.prod_nbr,
    t.prod_name,
    t.prod_weight,
    t.unit_price,
    t.prod_qty,
    t.tot_sales,
    GETDATE() AS dwh_create_date
FROM silver.qvi_customers c
INNER JOIN silver.qvi_transactions t
    ON c.lylty_card_nbr = t.lylty_card_nbr;
