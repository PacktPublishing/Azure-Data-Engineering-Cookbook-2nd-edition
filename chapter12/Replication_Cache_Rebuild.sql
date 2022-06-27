DECLARE @id int, @rowcount INT, @rebuild_cache_qry NVARCHAR(2500),@table_name varchar(2000)
CREATE TABLE #temp(id int, table_name varchar(2000))
INSERT into #temp (id,table_name) 
SELECT Row_number() OVER(Order by t.name) as id,  '[' + sch.[name] + '].[' + t.[name] + ']' AS table_name
	  FROM sys.tables t  
	  JOIN sys.pdw_replicated_table_cache_state c  
		ON c.object_id = t.object_id 
	  JOIN sys.pdw_table_distribution_properties p 
		ON p.object_id = t.object_id 
	  JOIN sys.schemas sch
		ON t.schema_id = sch.schema_id
	WHERE p.[distribution_policy_desc] = 'REPLICATE'
    and c.state = 'NotReady'
SET @id = 1
Select @rowcount = count(*) from #temp
WHILE @id <=@rowcount
BEGIN
SELECT @rebuild_cache_qry = 'SELECT TOP 1 * FROM ' + table_name + ';', @table_name = table_name
FROM #temp 
WHERE id = @id 
EXEC sp_executesql @rebuild_cache_qry;
Print 'Replication Cache of ' + @table_name + ' is being rebuilt'
SET @id = @id + 1
END
DROP TABLE #temp