-- Stored Procedure: Process Core Non-Rate Sensitive Deposits
-- Processes and analyzes core deposit stability and characteristics

CREATE PROCEDURE [dbo].[sp_ProcessCoreDeposits]
    @ProcessingDate DATE,
    @BranchCode NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update stability scores based on deposit behavior
        UPDATE cnrs
        SET [StabilityScore] = CASE 
            WHEN DATEDIFF(DAY, [OpenDate], @ProcessingDate) > 365 
                AND [DepositAmount] >= 10000 THEN 0.95
            WHEN DATEDIFF(DAY, [OpenDate], @ProcessingDate) > 180 
                AND [DepositAmount] >= 5000 THEN 0.85
            WHEN DATEDIFF(DAY, [OpenDate], @ProcessingDate) > 90 THEN 0.75
            ELSE 0.65
        END,
        [LastModifiedDate] = GETDATE(),
        [LastModifiedBy] = SYSTEM_USER
        FROM [dbo].[CoreNonRateSensitiveDeposits] cnrs
        WHERE cnrs.[IsActive] = 1
        AND (@BranchCode IS NULL OR cnrs.[BranchCode] = @BranchCode);
        
        -- Update risk weightings based on regulatory requirements
        UPDATE cnrs
        SET [RiskWeighting] = CASE 
            WHEN [DepositType] = 'Checking' THEN 0.0000
            WHEN [DepositType] = 'Savings' AND [StabilityScore] >= 0.90 THEN 0.0500
            WHEN [DepositType] = 'Money Market' THEN 0.2000
            ELSE 0.5000
        END,
        [LastModifiedDate] = GETDATE(),
        [LastModifiedBy] = SYSTEM_USER
        FROM [dbo].[CoreNonRateSensitiveDeposits] cnrs
        WHERE cnrs.[IsActive] = 1
        AND (@BranchCode IS NULL OR cnrs.[BranchCode] = @BranchCode);
        
        -- Insert summary into liquidity analysis
        INSERT INTO [dbo].[LiquidityCoverageRatio] (
            [ReportingDate], [HighQualityLiquidAssets], [Level1Assets],
            [Level2AAssets], [Level2BAssets], [TotalNetCashOutflows],
            [RetailDepositOutflows], [LCRRatio], [ExcessDeficit]
        )
        SELECT 
            @ProcessingDate AS ReportingDate,
            SUM(CASE WHEN [StabilityScore] >= 0.90 THEN [DepositAmount] ELSE 0 END) AS HighQualityLiquidAssets,
            SUM(CASE WHEN [DepositType] = 'Checking' THEN [DepositAmount] ELSE 0 END) AS Level1Assets,
            SUM(CASE WHEN [DepositType] = 'Savings' THEN [DepositAmount] ELSE 0 END) AS Level2AAssets,
            SUM(CASE WHEN [DepositType] = 'Money Market' THEN [DepositAmount] ELSE 0 END) AS Level2BAssets,
            SUM([DepositAmount] * 0.05) AS TotalNetCashOutflows, -- 5% outflow assumption
            SUM([DepositAmount] * 0.03) AS RetailDepositOutflows, -- 3% retail outflow
            CASE 
                WHEN SUM([DepositAmount] * 0.05) > 0 
                THEN (SUM(CASE WHEN [StabilityScore] >= 0.90 THEN [DepositAmount] ELSE 0 END) / SUM([DepositAmount] * 0.05)) * 100
                ELSE 0 
            END AS LCRRatio,
            SUM(CASE WHEN [StabilityScore] >= 0.90 THEN [DepositAmount] ELSE 0 END) - SUM([DepositAmount] * 0.05) AS ExcessDeficit
        FROM [dbo].[CoreNonRateSensitiveDeposits] cnrs
        WHERE cnrs.[IsActive] = 1
        AND (@BranchCode IS NULL OR cnrs.[BranchCode] = @BranchCode)
        AND NOT EXISTS (
            SELECT 1 FROM [dbo].[LiquidityCoverageRatio] lcr 
            WHERE lcr.[ReportingDate] = @ProcessingDate
        );
        
        COMMIT TRANSACTION;
        
        PRINT 'Core deposits processed successfully for ' + CAST(@ProcessingDate AS NVARCHAR(10));
        
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
