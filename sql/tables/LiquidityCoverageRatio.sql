-- Liquidity Coverage Ratio (LCR) Table
-- Tracks regulatory liquidity coverage ratio calculations

CREATE TABLE [dbo].[LiquidityCoverageRatio] (
    [LCRID] INT IDENTITY(1,1) PRIMARY KEY,
    [ReportingDate] DATE NOT NULL,
    [HighQualityLiquidAssets] DECIMAL(18,2) NOT NULL,
    [Level1Assets] DECIMAL(18,2) NOT NULL,
    [Level2AAssets] DECIMAL(18,2) NOT NULL,
    [Level2BAssets] DECIMAL(18,2) NOT NULL,
    [TotalNetCashOutflows] DECIMAL(18,2) NOT NULL,
    [RetailDepositOutflows] DECIMAL(18,2) NOT NULL,
    [WholesaleOutflows] DECIMAL(18,2) NOT NULL,
    [SecuredFundingOutflows] DECIMAL(18,2) NOT NULL,
    [DerivativeOutflows] DECIMAL(18,2) NOT NULL,
    [CreditFacilityOutflows] DECIMAL(18,2) NOT NULL,
    [LCRRatio] DECIMAL(5,2) NOT NULL,
    [RegulatoryMinimum] DECIMAL(5,2) DEFAULT 100.00,
    [ExcessDeficit] DECIMAL(18,2) NOT NULL,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_LiquidityCoverageRatio_ReportingDate 
ON [dbo].[LiquidityCoverageRatio] ([ReportingDate]);

CREATE NONCLUSTERED INDEX IX_LiquidityCoverageRatio_Currency 
ON [dbo].[LiquidityCoverageRatio] ([CurrencyCode]);
