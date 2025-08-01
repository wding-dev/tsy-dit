-- Stored Procedure: Calculate Treasury Turnover Ratios
-- Calculates and inserts turnover ratios for different asset types

CREATE PROCEDURE [dbo].[sp_CalculateTurnoverRatios]
    @CalculationDate DATE,
    @BusinessUnit NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Delete existing records for the calculation date
        DELETE FROM [dbo].[TreasuryTurnoverRatio] 
        WHERE [CalculationDate] = @CalculationDate
        AND (@BusinessUnit IS NULL OR [BusinessUnit] = @BusinessUnit);
        
        -- Calculate turnover ratios for different asset types
        INSERT INTO [dbo].[TreasuryTurnoverRatio] (
            [AssetType], [AssetCategory], [TurnoverRatio], [CalculationDate],
            [AverageAssetValue], [TotalRevenue], [BusinessUnit]
        )
        SELECT 
            'Securities' AS AssetType,
            'Government Bonds' AS AssetCategory,
            CASE 
                WHEN AVG(CAST([OutstandingAmount] AS DECIMAL(18,2))) > 0 
                THEN SUM([FundingCost]) / AVG(CAST([OutstandingAmount] AS DECIMAL(18,2)))
                ELSE 0 
            END AS TurnoverRatio,
            @CalculationDate AS CalculationDate,
            AVG(CAST([OutstandingAmount] AS DECIMAL(18,2))) AS AverageAssetValue,
            SUM([FundingCost]) AS TotalRevenue,
            COALESCE(@BusinessUnit, 'Treasury') AS BusinessUnit
        FROM [dbo].[AssetLiabilityMaturityBuckets] alm
        WHERE alm.[AssetLiabilityType] = 'Asset'
        AND alm.[InstrumentType] LIKE '%Bond%'
        AND alm.[ReportingDate] = @CalculationDate
        HAVING AVG(CAST([OutstandingAmount] AS DECIMAL(18,2))) > 0
        
        UNION ALL
        
        SELECT 
            'Loans' AS AssetType,
            'Commercial Loans' AS AssetCategory,
            CASE 
                WHEN AVG([DepositAmount]) > 0 
                THEN SUM([DepositAmount] * [InterestRate] / 100) / AVG([DepositAmount])
                ELSE 0 
            END AS TurnoverRatio,
            @CalculationDate AS CalculationDate,
            AVG([DepositAmount]) AS AverageAssetValue,
            SUM([DepositAmount] * [InterestRate] / 100) AS TotalRevenue,
            COALESCE(@BusinessUnit, 'Treasury') AS BusinessUnit
        FROM [dbo].[CoreNonRateSensitiveDeposits] cnrs
        WHERE cnrs.[OpenDate] <= @CalculationDate
        AND (cnrs.[MaturityDate] IS NULL OR cnrs.[MaturityDate] >= @CalculationDate)
        HAVING AVG([DepositAmount]) > 0;
        
        COMMIT TRANSACTION;
        
        PRINT 'Turnover ratios calculated successfully for ' + CAST(@CalculationDate AS NVARCHAR(10));
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
