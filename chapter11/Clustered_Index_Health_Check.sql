select schema_name(t.schema_id) [schema_name], t.name as Table_Name, 
Avg(total_rows) as Average_Rows_Per_Segment,
Count(*) as Total_segments,
Sum(Case when state_description = 'COMPRESSED' and total_rows < 1048576 then 1 else 0 end ) as Not_Optimized_Segments,
Sum(Case when state_description = 'OPEN' then 1 else 0 end) as Open_Segments,
Sum(Case when state_description = 'CLOSED' then 1 else 0 end) as Closed_Segments ,
Case when Avg(total_rows) < 100000 then 'Table doesn''t have enough rows for columnstore index. Consider moving to heap (table without index), if the table is expected to have less than 100000 rows per distribution'
When Sum(Case when state_description = 'CLOSED' then 1 else 0 end)  > 10 then 'Many segments in Closed State. Run Alter table <table name> Reorganize to move closed segments to compressed state' 
When Sum(Case when state_description = 'COMPRESSED' and total_rows < 1048576 then 1 else 0 end ) > 0 then 'Many sub optimal segments found. Recompress the table using ALTER TABLE <table name> rebuild or reload the table using CTAS with higher resource class' 
When Sum(Case when state_description = 'OPEN' then 1 else 0 end) > 10 then 'Too many open segments suggest data loading across partitions. Double check the partitioning strategy to make sure it is sound' End as Recommendation,
Sum(total_rows) as Row_Count
FROM sys.pdw_nodes_column_store_row_groups rg
JOIN sys.pdw_nodes_tables pt
ON rg.object_id = pt.object_id AND rg.pdw_node_id = pt.pdw_node_id AND pt.distribution_id = rg.distribution_id
JOIN sys.pdw_table_mappings tm
ON pt.name = tm.physical_name
INNER JOIN sys.tables t
ON tm.object_id = t.object_id
INNER JOIN sys.schemas s
ON t.schema_id = s.schema_id
Group by schema_name(t.schema_id), t.name
Having Avg(total_rows) < 100000 or 
Sum(Case when state_description = 'CLOSED' then 1 else 0 end)  > 10
or Sum(Case when state_description = 'COMPRESSED' and total_rows < 1048576 then 1 else 0 end ) > 0 
or Sum(Case when state_description = 'OPEN' then 1 else 0 end) > 10
