-- Stored Procedure: Calculate Interest Rate Risk Metrics
-- Calculates duration, convexity, and VaR for interest rate risk management

CREATE PROCEDURE [dbo].[sp_CalculateInterestRateRisk]
    @CalculationDate DATE,
    @BusinessLine NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Delete existing records for the calculation date
        DELETE FROM [dbo].[InterestRateRiskMetrics] 
        WHERE [CalculationDate] = @CalculationDate
        AND (@BusinessLine IS NULL OR [BusinessLine] = @BusinessLine);
        
        -- Calculate Duration metrics
        INSERT INTO [dbo].[InterestRateRiskMetrics] (
            [MetricType], [AssetLiabilityType], [TimeHorizon], [MetricValue],
            [BaseScenario], [CalculationDate], [BusinessLine], [RiskLimit]
        )
        SELECT 
            'Duration' AS MetricType,
            alm.[AssetLiabilityType],
            '1Y' AS TimeHorizon,
            AVG(alm.[WeightedAverageMaturity] / 365.0) AS MetricValue,
            'Base Case' AS BaseScenario,
            @CalculationDate AS CalculationDate,
            COALESCE(@BusinessLine, alm.[BusinessUnit]) AS BusinessLine,
            5.0 AS RiskLimit -- 5 year duration limit
        FROM [dbo].[AssetLiabilityMaturityBuckets] alm
        WHERE alm.[ReportingDate] = @CalculationDate
        AND (@BusinessLine IS NULL OR alm.[BusinessUnit] = @BusinessLine)
        GROUP BY alm.[AssetLiabilityType], alm.[BusinessUnit]
        
        UNION ALL
        
        -- Calculate VaR metrics
        SELECT 
            'VaR_99' AS MetricType,
            'Net' AS AssetLiabilityType,
            '1D' AS TimeHorizon,
            SUM(alm.[OutstandingAmount]) * 0.025 AS MetricValue, -- 2.5% VaR assumption
            'Base Case' AS BaseScenario,
            @CalculationDate AS CalculationDate,
            COALESCE(@BusinessLine, alm.[BusinessUnit]) AS BusinessLine,
            1000000.0 AS RiskLimit -- $1M VaR limit
        FROM [dbo].[AssetLiabilityMaturityBuckets] alm
        WHERE alm.[ReportingDate] = @CalculationDate
        AND (@BusinessLine IS NULL OR alm.[BusinessUnit] = @BusinessLine)
        GROUP BY alm.[BusinessUnit];
        
        -- Update limit utilization
        UPDATE irr
        SET [LimitUtilization] = CASE 
            WHEN irr.[RiskLimit] > 0 THEN (ABS(irr.[MetricValue]) / irr.[RiskLimit]) * 100
            ELSE 0 
        END,
        [LastModifiedDate] = GETDATE(),
        [LastModifiedBy] = SYSTEM_USER
        FROM [dbo].[InterestRateRiskMetrics] irr
        WHERE irr.[CalculationDate] = @CalculationDate
        AND (@BusinessLine IS NULL OR irr.[BusinessLine] = @BusinessLine);
        
        COMMIT TRANSACTION;
        
        PRINT 'Interest rate risk metrics calculated successfully for ' + CAST(@CalculationDate AS NVARCHAR(10));
        
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
