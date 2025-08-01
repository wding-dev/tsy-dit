-- Stored Procedure: Analyze Treasury Funding Sources
CREATE PROCEDURE [dbo].[sp_AnalyzeFundingSources]
    @AnalysisDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update funding costs based on current market rates
        UPDATE fs
        SET [FundingCost] = [FundingAmount] * ([FundingRate] / 100) * 
            (DATEDIFF(DAY, [StartDate], [MaturityDate]) / 365.0),
        [LastModifiedDate] = GETDATE()
        FROM [dbo].[TreasuryFundingSources] fs
        WHERE fs.[StartDate] <= @AnalysisDate 
        AND fs.[MaturityDate] >= @AnalysisDate
        AND fs.[IsActive] = 1;
        
        -- Calculate concentration risk by counterparty
        UPDATE fs
        SET [RegulatoryTreatment] = CASE 
            WHEN [CounterpartyRating] IN ('AAA', 'AA+', 'AA', 'AA-') THEN 'Tier1'
            WHEN [CounterpartyRating] IN ('A+', 'A', 'A-') THEN 'Tier2'
            ELSE 'Tier3'
        END
        FROM [dbo].[TreasuryFundingSources] fs
        WHERE fs.[IsActive] = 1;
        
        COMMIT TRANSACTION;
        PRINT 'Funding sources analysis completed successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
