-- Stored Procedure: Calculate Capital Adequacy Ratios
-- Calculates regulatory capital ratios including CET1, Tier1, and Total Capital

CREATE PROCEDURE [dbo].[sp_CalculateCapitalAdequacy]
    @ReportingDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @TotalRWA DECIMAL(18,2);
    DECLARE @Tier1Capital DECIMAL(18,2);
    DECLARE @Tier2Capital DECIMAL(18,2);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Calculate Risk Weighted Assets
        SELECT @TotalRWA = SUM(alm.[OutstandingAmount] * alm.[RiskWeighting])
        FROM [dbo].[AssetLiabilityMaturityBuckets] alm
        WHERE alm.[AssetLiabilityType] = 'Asset'
        AND alm.[ReportingDate] = @ReportingDate;
        
        -- Set capital amounts (would typically come from GL or capital tables)
        SET @Tier1Capital = @TotalRWA * 0.12; -- Assume 12% Tier 1 ratio
        SET @Tier2Capital = @TotalRWA * 0.04; -- Assume 4% Tier 2 ratio
        
        -- Delete existing records for the reporting date
        DELETE FROM [dbo].[CapitalAdequacyRatios] 
        WHERE [ReportingDate] = @ReportingDate;
        
        -- Insert CET1 Ratio
        INSERT INTO [dbo].[CapitalAdequacyRatios] (
            [ReportingDate], [RatioType], [NumeratorAmount], [DenominatorAmount],
            [CalculatedRatio], [RegulatoryMinimum], [ManagementTarget], [ExcessDeficit],
            [RiskWeightedAssets], [Tier1Capital], [Tier2Capital], [TotalCapital]
        )
        VALUES (
            @ReportingDate, 'CET1', @Tier1Capital * 0.85, @TotalRWA,
            (@Tier1Capital * 0.85 / @TotalRWA) * 100, 4.50, 7.00,
            (@Tier1Capital * 0.85) - (@TotalRWA * 0.045),
            @TotalRWA, @Tier1Capital, @Tier2Capital, @Tier1Capital + @Tier2Capital
        );
        
        -- Insert Tier 1 Ratio
        INSERT INTO [dbo].[CapitalAdequacyRatios] (
            [ReportingDate], [RatioType], [NumeratorAmount], [DenominatorAmount],
            [CalculatedRatio], [RegulatoryMinimum], [ManagementTarget], [ExcessDeficit],
            [RiskWeightedAssets], [Tier1Capital], [Tier2Capital], [TotalCapital]
        )
        VALUES (
            @ReportingDate, 'Tier1', @Tier1Capital, @TotalRWA,
            (@Tier1Capital / @TotalRWA) * 100, 6.00, 8.50,
            @Tier1Capital - (@TotalRWA * 0.06),
            @TotalRWA, @Tier1Capital, @Tier2Capital, @Tier1Capital + @Tier2Capital
        );
        
        -- Insert Total Capital Ratio
        INSERT INTO [dbo].[CapitalAdequacyRatios] (
            [ReportingDate], [RatioType], [NumeratorAmount], [DenominatorAmount],
            [CalculatedRatio], [RegulatoryMinimum], [ManagementTarget], [ExcessDeficit],
            [RiskWeightedAssets], [Tier1Capital], [Tier2Capital], [TotalCapital]
        )
        VALUES (
            @ReportingDate, 'Total Capital', @Tier1Capital + @Tier2Capital, @TotalRWA,
            ((@Tier1Capital + @Tier2Capital) / @TotalRWA) * 100, 8.00, 10.50,
            (@Tier1Capital + @Tier2Capital) - (@TotalRWA * 0.08),
            @TotalRWA, @Tier1Capital, @Tier2Capital, @Tier1Capital + @Tier2Capital
        );
        
        COMMIT TRANSACTION;
        
        PRINT 'Capital adequacy ratios calculated successfully for ' + CAST(@ReportingDate AS NVARCHAR(10));
        
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
