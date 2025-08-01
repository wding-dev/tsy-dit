-- Asset Liability Maturity Buckets Table
-- Tracks maturity distribution of assets and liabilities for ALM analysis

CREATE TABLE [dbo].[AssetLiabilityMaturityBuckets] (
    [MaturityBucketID] INT IDENTITY(1,1) PRIMARY KEY,
    [AssetLiabilityType] NVARCHAR(20) NOT NULL, -- Asset, Liability
    [InstrumentType] NVARCHAR(50) NOT NULL,
    [MaturityBucket] NVARCHAR(20) NOT NULL, -- 0-30D, 31-90D, 91-180D, etc.
    [BucketStartDays] INT NOT NULL,
    [BucketEndDays] INT NOT NULL,
    [OutstandingAmount] DECIMAL(18,2) NOT NULL,
    [WeightedAverageRate] DECIMAL(7,4) NOT NULL,
    [WeightedAverageMaturity] DECIMAL(10,2) NOT NULL,
    [ReportingDate] DATE NOT NULL,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [BusinessUnit] NVARCHAR(50) NOT NULL,
    [RiskWeighting] DECIMAL(5,4) DEFAULT 1.0000,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_AssetLiabilityMaturityBuckets_Type_Date 
ON [dbo].[AssetLiabilityMaturityBuckets] ([AssetLiabilityType], [ReportingDate]);

CREATE NONCLUSTERED INDEX IX_AssetLiabilityMaturityBuckets_Bucket 
ON [dbo].[AssetLiabilityMaturityBuckets] ([MaturityBucket]);
