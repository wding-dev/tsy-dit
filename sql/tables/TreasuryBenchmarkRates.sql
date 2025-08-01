-- Treasury Benchmark Rates Table
-- Tracks various benchmark interest rates used in treasury operations

CREATE TABLE [dbo].[TreasuryBenchmarkRates] (
    [BenchmarkRateID] INT IDENTITY(1,1) PRIMARY KEY,
    [RateDate] DATE NOT NULL,
    [BenchmarkName] NVARCHAR(50) NOT NULL, -- LIBOR, SOFR, Fed Funds, Treasury, etc.
    [RateTenor] NVARCHAR(20) NOT NULL, -- ON, 1M, 3M, 6M, 1Y, 2Y, etc.
    [RateValue] DECIMAL(9,6) NOT NULL,
    [CurrencyCode] NCHAR(3) NOT NULL DEFAULT 'USD',
    [RateSource] NVARCHAR(50) NOT NULL, -- Bloomberg, Reuters, Fed, etc.
    [RateType] NVARCHAR(20) NOT NULL, -- Spot, Forward, Swap
    [DayCountConvention] NVARCHAR(20) NOT NULL, -- ACT/360, ACT/365, 30/360
    [BusinessDayConvention] NVARCHAR(20) NOT NULL, -- Following, Modified Following
    [IsBusinessDay] BIT DEFAULT 1,
    [RateChangeFromPrevious] DECIMAL(9,6) NULL,
    [VolatilityMeasure] DECIMAL(9,6) NULL,
    [CreatedDate] DATETIME2 DEFAULT GETDATE(),
    [CreatedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [LastModifiedDate] DATETIME2 DEFAULT GETDATE(),
    [LastModifiedBy] NVARCHAR(100) DEFAULT SYSTEM_USER,
    [IsActive] BIT DEFAULT 1
);

-- Create indexes
CREATE NONCLUSTERED INDEX IX_TreasuryBenchmarkRates_Date_Benchmark 
ON [dbo].[TreasuryBenchmarkRates] ([RateDate], [BenchmarkName]);

CREATE NONCLUSTERED INDEX IX_TreasuryBenchmarkRates_Benchmark_Tenor 
ON [dbo].[TreasuryBenchmarkRates] ([BenchmarkName], [RateTenor]);
