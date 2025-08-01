CREATE PROCEDURE sp_allocate_cost_of_funds
AS
BEGIN
    SET NOCOUNT ON;

    -- Dummy logic to update loan amounts by allocating cost (increase by 1%)
    UPDATE fact_loan
    SET amount = amount * 1.01;
END;
