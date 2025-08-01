-- Stored Procedure: Update Treasury Benchmark Rates
CREATE PROCEDURE [dbo].[sp_UpdateBenchmarkRates]
    @RateDate DATE,
    @RateSource NVARCHAR(50) = 'Bloomberg'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Sample rate updates (would typically come from external feed)
        INSERT INTO [dbo].[TreasuryBenchmarkRates] (
            [RateDate], [BenchmarkName], [RateTenor], [RateValue], [RateSource],
            [RateType], [DayCountConvention], [BusinessDayConvention]
        )
        VALUES 
        (@RateDate, 'SOFR', 'ON', 5.25, @RateSource, 'Spot', 'ACT/360', 'Following'),
        (@RateDate, 'SOFR', '1M', 5.30, @RateSource, 'Spot', 'ACT/360', 'Following'),
        (@RateDate, 'SOFR', '3M', 5.35, @RateSource, 'Spot', 'ACT/360', 'Following'),
        (@RateDate, 'Treasury', '2Y', 4.75, @RateSource, 'Spot', 'ACT/365', 'Following'),
        (@RateDate, 'Treasury', '10Y', 4.25, @RateSource, 'Spot', 'ACT/365', 'Following');
        
        COMMIT TRANSACTION;
        PRINT 'Benchmark rates updated successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
