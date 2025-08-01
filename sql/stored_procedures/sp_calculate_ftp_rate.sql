CREATE PROCEDURE sp_calculate_ftp_rate
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert a new FTP rate for each product type and rate type based on avg loan interest rate (dummy logic)
    INSERT INTO ft_ftp_rates (product_type, rate_type_id, ftp_rate, effective_date)
    SELECT
        p.product_type,
        -- Assign different rate types based on product characteristics
        CASE 
            WHEN p.product_type LIKE '%Fixed%' THEN 1 -- Fixed
            WHEN p.product_type LIKE '%Variable%' THEN 2 -- Variable
            WHEN p.product_type LIKE '%Overnight%' THEN 3 -- Overnight
            WHEN p.product_type LIKE '%Term%' THEN 4 -- Term
            ELSE 5 -- Base
        END AS rate_type_id,
        ROUND(AVG(l.interest_rate) * 0.9, 2) AS ftp_rate,
        CAST(GETDATE() AS DATE)
    FROM fact_loan l
    INNER JOIN dim_product p ON l.product_id = p.product_id
    GROUP BY p.product_type;
END;