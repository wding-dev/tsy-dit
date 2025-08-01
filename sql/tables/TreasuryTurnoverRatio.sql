-- Treasury Turnover Ratio Table
-- Tracks asset turnover ratios for treasury portfolio management

CREATE TABLE [dbo].[TreasuryTurnoverRatio] (
    [TurnoverRatioID] INT IDENTITY(1,1) PRIMARY KEY,
    [AssetType] NVARCHAR(50) NOT NULL,
    [AssetCategory] NVARCHAR(100) NOT NULL,
    [TurnoverRatio] DECIMAL(18,6) NOT NULL,
    [CalculationDate] DATE NOT NULL,
    [AverageAssetValue] DECIMAL(18,2) NOT NULL,
    [TotalRevenue] DECIMAL(18,2) NOT NULL,
    [BusinessUnit] NVARCHAR(50) NOT NULL,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes for performance
CREATE NONCLUSTERED INDEX IX_TreasuryTurnoverRatio_AssetType_Date 
ON [dbo].[TreasuryTurnoverRatio] ([AssetType], [CalculationDate]);

CREATE NONCLUSTERED INDEX IX_TreasuryTurnoverRatio_BusinessUnit 
ON [dbo].[TreasuryTurnoverRatio] ([BusinessUnit]);
