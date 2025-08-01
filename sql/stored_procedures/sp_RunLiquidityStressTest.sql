-- Stored Procedure: Run Liquidity Stress Testing
CREATE PROCEDURE [dbo].[sp_RunLiquidityStressTest]
    @TestDate DATE,
    @StressScenario NVARCHAR(50) = 'Severe'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @StressMultiplier DECIMAL(5,2) = CASE 
            WHEN @StressScenario = 'Mild' THEN 1.5
            WHEN @StressScenario = 'Moderate' THEN 2.0
            WHEN @StressScenario = 'Severe' THEN 3.0
            ELSE 2.5
        END;
        
        -- Update LCR under stress conditions
        INSERT INTO [dbo].[LiquidityCoverageRatio] (
            [ReportingDate], [HighQualityLiquidAssets], [Level1Assets],
            [TotalNetCashOutflows], [RetailDepositOutflows], [LCRRatio], [ExcessDeficit]
        )
        SELECT 
            @TestDate AS ReportingDate,
            SUM(CASE WHEN cnrs.[StabilityScore] >= 0.90 THEN cnrs.[DepositAmount] * 0.8 ELSE 0 END) AS HighQualityLiquidAssets,
            SUM(CASE WHEN cnrs.[DepositType] = 'Checking' THEN cnrs.[DepositAmount] * 0.9 ELSE 0 END) AS Level1Assets,
            SUM(cnrs.[DepositAmount] * 0.05 * @StressMultiplier) AS TotalNetCashOutflows,
            SUM(cnrs.[DepositAmount] * 0.03 * @StressMultiplier) AS RetailDepositOutflows,
            CASE 
                WHEN SUM(cnrs.[DepositAmount] * 0.05 * @StressMultiplier) > 0 
                THEN (SUM(CASE WHEN cnrs.[StabilityScore] >= 0.90 THEN cnrs.[DepositAmount] * 0.8 ELSE 0 END) / 
                      SUM(cnrs.[DepositAmount] * 0.05 * @StressMultiplier)) * 100
                ELSE 0 
            END AS LCRRatio,
            SUM(CASE WHEN cnrs.[StabilityScore] >= 0.90 THEN cnrs.[DepositAmount] * 0.8 ELSE 0 END) - 
            SUM(cnrs.[DepositAmount] * 0.05 * @StressMultiplier) AS ExcessDeficit
        FROM [dbo].[CoreNonRateSensitiveDeposits] cnrs
        WHERE cnrs.[IsActive] = 1;
        
        COMMIT TRANSACTION;
        PRINT 'Liquidity stress test completed successfully for scenario: ' + @StressScenario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
