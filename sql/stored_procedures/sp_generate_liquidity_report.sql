CREATE PROCEDURE sp_generate_liquidity_report
AS
BEGIN
    SET NOCOUNT ON;

    -- Simple aggregation of liquidity transfers by source, destination product and rate type
    SELECT
        lt.source_product,
        lt.destination_product,
        rt.rate_type_name,
        SUM(lt.transfer_amount) AS total_transfer_amount,
        CAST(GETDATE() AS DATE) AS report_date
    FROM ft_liquidity_transfer lt
    INNER JOIN dim_rate_type rt ON lt.rate_type_id = rt.rate_type_id
    GROUP BY lt.source_product, lt.destination_product, rt.rate_type_name;
END;