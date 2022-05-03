CREATE VIEW dbo.table_partition_boundary
AS
Select t.name,rng.boundary_id, rng.value,prt.rows
from sys.partitions prt inner join sys.tables t 
on prt.object_id = t.object_id
INNER JOIN  sys.indexes    idx ON  prt.[object_id] = idx.[object_id]               
AND        prt.[index_id]  = idx.[index_id]
INNER JOIN  sys.data_spaces ds ON  idx.[data_space_id] = ds.[data_space_id]
INNER JOIN  sys.partition_schemes    ps  ON  ds.[data_space_id]  = ps.[data_space_id]
INNER JOIN sys.partition_functions   pf  ON  ps.[function_id]    = pf.[function_id]
LEFT JOIN sys.partition_range_values rng ON  pf.[function_id]    = rng.[function_id]
AND  rng.[boundary_id] = prt.[partition_number]
