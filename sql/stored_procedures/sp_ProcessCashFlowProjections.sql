-- Stored Procedure: Process Cash Flow Projections
CREATE PROCEDURE [dbo].[sp_ProcessCashFlowProjections]
    @ProjectionDate DATE,
    @ScenarioType NVARCHAR(50) = 'Base'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO [dbo].[TreasuryCashFlowProjections] (
            [ProjectionDate], [CashFlowDate], [CashFlowType], [CashFlowCategory],
            [CashFlowSubCategory], [ProjectedAmount], [ConfidenceLevel], [ScenarioType], [BusinessUnit]
        )
        SELECT 
            @ProjectionDate, DATEADD(DAY, 30, @ProjectionDate), 'Inflow', 'Operating',
            'Deposit Inflows', SUM([DepositAmount]) * 0.05, 85.0, @ScenarioType, 'Treasury'
        FROM [dbo].[CoreNonRateSensitiveDeposits]
        WHERE [IsActive] = 1;
        
        COMMIT TRANSACTION;
        PRINT 'Cash flow projections processed successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
