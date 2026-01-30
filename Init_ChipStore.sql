/*
==================================================================
Create Database and Schema
==================================================================
Script Purpose:
	This script creates a new databse named 'ChipStore' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze', 'silver' and 'gold'.

WARNING:
	Running this script will drop the entire 'ChipStore' database if it exists.
	All data in the database will be permamnently deleted. Proceed with caution and 
	ensure you have proper backups before running this script.
*/

USE master;

-- The database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ChipStore')
BEGIN
	ALTER DATABASE ChipStore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ChipStore;
END;
GO
 -- Create the 'ChipStore' database
CREATE DATABASE ChipStore;

-- Using the ChipStore	
USE ChipStore;

-- Creating the Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
