-- Capital Adequacy Ratios Table
-- Tracks regulatory capital ratios and requirements

CREATE TABLE [dbo].[CapitalAdequacyRatios] (
    [CapitalRatioID] INT IDENTITY(1,1) PRIMARY KEY,
    [ReportingDate] DATE NOT NULL,
    [RatioType] NVARCHAR(50) NOT NULL, -- CET1, Tier1, Total Capital, Leverage
    [NumeratorAmount] DECIMAL(18,2) NOT NULL,
    [DenominatorAmount] DECIMAL(18,2) NOT NULL,
    [CalculatedRatio] DECIMAL(7,4) NOT NULL,
    [RegulatoryMinimum] DECIMAL(7,4) NOT NULL,
    [ManagementTarget] DECIMAL(7,4) NULL,
    [ExcessDeficit] DECIMAL(18,2) NOT NULL,
    [RiskWeightedAssets] DECIMAL(18,2) NOT NULL,
    [Tier1Capital] DECIMAL(18,2) NOT NULL,
    [Tier2Capital] DECIMAL(18,2) NOT NULL,
    [TotalCapital] DECIMAL(18,2) NOT NULL,
    [LeverageExposure] DECIMAL(18,2) NULL,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_CapitalAdequacyRatios_Date_Type 
ON [dbo].[CapitalAdequacyRatios] ([ReportingDate], [RatioType]);

CREATE NONCLUSTERED INDEX IX_CapitalAdequacyRatios_RatioType 
ON [dbo].[CapitalAdequacyRatios] ([RatioType]);
