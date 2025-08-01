CREATE PROCEDURE sp_extract_loan_position
AS
BEGIN
    SET NOCOUNT ON;

    SELECT loan_id, customer_id, product_id, amount, start_date, maturity_date, interest_rate
    FROM fact_loan
    WHERE start_date <= CAST(GETDATE() AS DATE)
      AND maturity_date >= CAST(GETDATE() AS DATE);
END;
