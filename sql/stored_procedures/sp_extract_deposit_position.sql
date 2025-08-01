CREATE PROCEDURE sp_extract_deposit_position
AS
BEGIN
    SET NOCOUNT ON;

    SELECT deposit_id, customer_id, product_id, amount, open_date, interest_rate
    FROM fact_deposit
    WHERE open_date <= CAST(GETDATE() AS DATE);
END;
