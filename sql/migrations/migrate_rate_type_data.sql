-- Migration script to update existing data with rate type information

-- Step 1: Create a temporary table to hold existing FTP rates
SELECT * INTO #temp_ftp_rates FROM ft_ftp_rates;

-- Step 2: Truncate the existing table
TRUNCATE TABLE ft_ftp_rates;

-- Step 3: Reinsert the data with rate type information
INSERT INTO ft_ftp_rates (product_type, rate_type_id, ftp_rate, effective_date)
SELECT
    product_type,
    -- Assign different rate types based on product characteristics
    CASE 
        WHEN product_type LIKE '%Fixed%' THEN 1 -- Fixed
        WHEN product_type LIKE '%Variable%' THEN 2 -- Variable
        WHEN product_type LIKE '%Overnight%' THEN 3 -- Overnight
        WHEN product_type LIKE '%Term%' THEN 4 -- Term
        ELSE 5 -- Base
    END AS rate_type_id,
    ftp_rate,
    effective_date
FROM #temp_ftp_rates;

-- Step 4: Drop the temporary table
DROP TABLE #temp_ftp_rates;

-- Step 5: Create a temporary table to hold existing liquidity transfers
SELECT * INTO #temp_liquidity_transfer FROM ft_liquidity_transfer;

-- Step 6: Truncate the existing table
TRUNCATE TABLE ft_liquidity_transfer;

-- Step 7: Reinsert the data with rate type information
INSERT INTO ft_liquidity_transfer (source_product, destination_product, rate_type_id, transfer_amount, transfer_date)
SELECT
    source_product,
    destination_product,
    -- Assign different rate types based on product characteristics
    CASE 
        WHEN source_product LIKE '%Fixed%' OR destination_product LIKE '%Fixed%' THEN 1 -- Fixed
        WHEN source_product LIKE '%Variable%' OR destination_product LIKE '%Variable%' THEN 2 -- Variable
        WHEN source_product LIKE '%Overnight%' OR destination_product LIKE '%Overnight%' THEN 3 -- Overnight
        WHEN source_product LIKE '%Term%' OR destination_product LIKE '%Term%' THEN 4 -- Term
        ELSE 5 -- Base
    END AS rate_type_id,
    transfer_amount,
    transfer_date
FROM #temp_liquidity_transfer;

-- Step 8: Drop the temporary table
DROP TABLE #temp_liquidity_transfer;

-- Step 9: Print completion message
PRINT 'Migration completed successfully.';