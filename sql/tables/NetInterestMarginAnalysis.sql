-- Net Interest Margin Analysis Table
-- Tracks net interest margin calculations and analysis

CREATE TABLE [dbo].[NetInterestMarginAnalysis] (
    [NIMID] INT IDENTITY(1,1) PRIMARY KEY,
    [AnalysisDate] DATE NOT NULL,
    [BusinessLine] NVARCHAR(50) NOT NULL,
    [ProductCategory] NVARCHAR(50) NOT NULL,
    [InterestIncomeEarningAssets] DECIMAL(18,2) NOT NULL,
    [InterestExpenseFundingCosts] DECIMAL(18,2) NOT NULL,
    [NetInterestIncome] DECIMAL(18,2) NOT NULL,
    [AverageEarningAssets] DECIMAL(18,2) NOT NULL,
    [NetInterestMargin] DECIMAL(7,4) NOT NULL,
    [AssetYield] DECIMAL(7,4) NOT NULL,
    [FundingCostRate] DECIMAL(7,4) NOT NULL,
    [InterestRateSpread] DECIMAL(7,4) NOT NULL,
    [NonPerformingAssetImpact] DECIMAL(18,2) DEFAULT 0.00,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_NetInterestMarginAnalysis_Date_BusinessLine 
ON [dbo].[NetInterestMarginAnalysis] ([AnalysisDate], [BusinessLine]);

CREATE NONCLUSTERED INDEX IX_NetInterestMarginAnalysis_ProductCategory 
ON [dbo].[NetInterestMarginAnalysis] ([ProductCategory]);
