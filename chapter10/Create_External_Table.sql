IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 USE_TYPE_DEFAULT = FALSE
			 ,FIRST_ROW = 2
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'synapse_packtadesynapse_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [synapse_packtadesynapse_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://synapse@packtadesynapse.dfs.core.windows.net', 
		TYPE = HADOOP 
	)
GO

CREATE EXTERNAL TABLE ext_transaction_tbl (
	[tid] bigint,
	[transaction_date] bigint,
	[order_count] bigint,
	[total_cost] bigint,
	[sid] bigint,
	[pid] bigint,
	[c1] varchar(200) ,
	[c2] varchar(200) 
	)
	WITH (
	LOCATION = 'files/transaction-tbl.csv',
	DATA_SOURCE = [synapse_packtadesynapse_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.ext_transaction_tbl
GO
CREATE TABLE dbo.transaction_tbl WITH (DISTRIBUTION = ROUND_ROBIN)
AS 
Select * from dbo.ext_transaction_tbl;
GO
Select TOP 100 *  from dbo.transaction_tbl
