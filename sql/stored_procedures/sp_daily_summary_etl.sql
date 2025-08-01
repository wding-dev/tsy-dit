CREATE PROCEDURE sp_daily_summary_etl
AS
BEGIN
    SET NOCOUNT ON;

    -- Run all relevant stored procedures as part of daily ETL
    EXEC sp_extract_loan_position;
    EXEC sp_extract_deposit_position;
    EXEC sp_calculate_ftp_rate;
    EXEC sp_allocate_cost_of_funds;
    EXEC sp_generate_liquidity_report;
END;
