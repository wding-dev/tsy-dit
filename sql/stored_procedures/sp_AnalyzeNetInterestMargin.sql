-- Stored Procedure: Analyze Net Interest Margin
-- Calculates and analyzes net interest margin by business line and product

CREATE PROCEDURE [dbo].[sp_AnalyzeNetInterestMargin]
    @AnalysisDate DATE,
    @BusinessLine NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Delete existing records for the analysis date
        DELETE FROM [dbo].[NetInterestMarginAnalysis] 
        WHERE [AnalysisDate] = @AnalysisDate
        AND (@BusinessLine IS NULL OR [BusinessLine] = @BusinessLine);
        
        -- Calculate NIM for deposit products
        INSERT INTO [dbo].[NetInterestMarginAnalysis] (
            [AnalysisDate], [BusinessLine], [ProductCategory],
            [InterestIncomeEarningAssets], [InterestExpenseFundingCosts],
            [NetInterestIncome], [AverageEarningAssets], [NetInterestMargin],
            [AssetYield], [FundingCostRate], [InterestRateSpread]
        )
        SELECT 
            @AnalysisDate AS AnalysisDate,
            COALESCE(@BusinessLine, 'Retail Banking') AS BusinessLine,
            cnrs.[DepositType] AS ProductCategory,
            SUM(cnrs.[DepositAmount] * cnrs.[InterestRate] / 100) AS InterestIncomeEarningAssets,
            SUM(fs.[FundingCost]) AS InterestExpenseFundingCosts,
            SUM(cnrs.[DepositAmount] * cnrs.[InterestRate] / 100) - SUM(fs.[FundingCost]) AS NetInterestIncome,
            AVG(cnrs.[DepositAmount]) AS AverageEarningAssets,
            CASE 
                WHEN AVG(cnrs.[DepositAmount]) > 0 
                THEN ((SUM(cnrs.[DepositAmount] * cnrs.[InterestRate] / 100) - SUM(fs.[FundingCost])) / AVG(cnrs.[DepositAmount])) * 100
                ELSE 0 
            END AS NetInterestMargin,
            CASE 
                WHEN AVG(cnrs.[DepositAmount]) > 0 
                THEN (SUM(cnrs.[DepositAmount] * cnrs.[InterestRate] / 100) / AVG(cnrs.[DepositAmount])) * 100
                ELSE 0 
            END AS AssetYield,
            CASE 
                WHEN AVG(cnrs.[DepositAmount]) > 0 
                THEN (SUM(fs.[FundingCost]) / AVG(cnrs.[DepositAmount])) * 100
                ELSE 0 
            END AS FundingCostRate,
            AVG(cnrs.[InterestRate]) - AVG(fs.[FundingRate]) AS InterestRateSpread
        FROM [dbo].[CoreNonRateSensitiveDeposits] cnrs
        LEFT JOIN [dbo].[TreasuryFundingSources] fs ON fs.[FundingType] = 'Deposits'
            AND fs.[StartDate] <= @AnalysisDate 
            AND fs.[MaturityDate] >= @AnalysisDate
        WHERE cnrs.[IsActive] = 1
        AND cnrs.[OpenDate] <= @AnalysisDate
        AND (cnrs.[MaturityDate] IS NULL OR cnrs.[MaturityDate] >= @AnalysisDate)
        GROUP BY cnrs.[DepositType]
        HAVING AVG(cnrs.[DepositAmount]) > 0
        
        UNION ALL
        
        -- Calculate NIM for asset products
        SELECT 
            @AnalysisDate AS AnalysisDate,
            COALESCE(@BusinessLine, alm.[BusinessUnit]) AS BusinessLine,
            alm.[InstrumentType] AS ProductCategory,
            SUM(alm.[OutstandingAmount] * alm.[WeightedAverageRate] / 100) AS InterestIncomeEarningAssets,
            SUM(fs.[FundingCost]) AS InterestExpenseFundingCosts,
            SUM(alm.[OutstandingAmount] * alm.[WeightedAverageRate] / 100) - SUM(fs.[FundingCost]) AS NetInterestIncome,
            AVG(alm.[OutstandingAmount]) AS AverageEarningAssets,
            CASE 
                WHEN AVG(alm.[OutstandingAmount]) > 0 
                THEN ((SUM(alm.[OutstandingAmount] * alm.[WeightedAverageRate] / 100) - SUM(fs.[FundingCost])) / AVG(alm.[OutstandingAmount])) * 100
                ELSE 0 
            END AS NetInterestMargin,
            AVG(alm.[WeightedAverageRate]) AS AssetYield,
            AVG(fs.[FundingRate]) AS FundingCostRate,
            AVG(alm.[WeightedAverageRate]) - AVG(fs.[FundingRate]) AS InterestRateSpread
        FROM [dbo].[AssetLiabilityMaturityBuckets] alm
        LEFT JOIN [dbo].[TreasuryFundingSources] fs ON fs.[StartDate] <= @AnalysisDate 
            AND fs.[MaturityDate] >= @AnalysisDate
        WHERE alm.[AssetLiabilityType] = 'Asset'
        AND alm.[ReportingDate] = @AnalysisDate
        AND (@BusinessLine IS NULL OR alm.[BusinessUnit] = @BusinessLine)
        GROUP BY alm.[InstrumentType], alm.[BusinessUnit]
        HAVING AVG(alm.[OutstandingAmount]) > 0;
        
        COMMIT TRANSACTION;
        
        PRINT 'Net interest margin analysis completed successfully for ' + CAST(@AnalysisDate AS NVARCHAR(10));
        
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
