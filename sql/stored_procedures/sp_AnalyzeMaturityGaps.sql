-- Stored Procedure: Analyze Asset Liability Maturity Gaps
CREATE PROCEDURE [dbo].[sp_AnalyzeMaturityGaps]
    @ReportingDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update maturity buckets based on current positions
        UPDATE alm
        SET [MaturityBucket] = CASE 
            WHEN [BucketEndDays] <= 30 THEN '0-30D'
            WHEN [BucketEndDays] <= 90 THEN '31-90D'
            WHEN [BucketEndDays] <= 180 THEN '91-180D'
            WHEN [BucketEndDays] <= 365 THEN '181-365D'
            ELSE '1Y+'
        END,
        [LastModifiedDate] = GETDATE()
        FROM [dbo].[AssetLiabilityMaturityBuckets] alm
        WHERE alm.[ReportingDate] = @ReportingDate;
        
        -- Calculate gap analysis metrics
        INSERT INTO [dbo].[InterestRateRiskMetrics] (
            [MetricType], [AssetLiabilityType], [TimeHorizon], [MetricValue],
            [BaseScenario], [CalculationDate], [BusinessLine]
        )
        SELECT 
            'Maturity Gap' AS MetricType,
            'Net' AS AssetLiabilityType,
            alm.[MaturityBucket] AS TimeHorizon,
            SUM(CASE WHEN alm.[AssetLiabilityType] = 'Asset' THEN alm.[OutstandingAmount] ELSE -alm.[OutstandingAmount] END) AS MetricValue,
            'Base Case' AS BaseScenario,
            @ReportingDate AS CalculationDate,
            alm.[BusinessUnit] AS BusinessLine
        FROM [dbo].[AssetLiabilityMaturityBuckets] alm
        WHERE alm.[ReportingDate] = @ReportingDate
        GROUP BY alm.[MaturityBucket], alm.[BusinessUnit];
        
        COMMIT TRANSACTION;
        PRINT 'Maturity gap analysis completed successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
