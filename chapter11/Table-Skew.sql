
Select schema_name,
	   table_name,
	   distribution_policy_name,
	   table_row_count,
	   [Max_distribution_row_count],
	   [Min_distribution_row_count],
	   [avg_distribution_row_count],
	   CASE WHEN table_row_count = 0 then -1
	   else abs([Max_distribution_row_count] *1.0 - [Min_distribution_row_count]*1.0) / [Max_distribution_row_count] *100.0
	   END  as [Table Skew Percent]

FROM (
SELECT
 s.name                                                                 AS  [schema_name]
, t.name                                                                AS  [table_name]
, tp.[distribution_policy_desc]                                         AS  [distribution_policy_name]

, sum([row_count])                                                      AS  [table_row_count]
, max(row_count)														AS  [Max_distribution_row_count]
, min(row_count)														AS  [Min_distribution_row_count]
, avg(row_count)													    AS  [avg_distribution_row_count]
from
    sys.schemas s
INNER JOIN sys.tables t
    ON s.[schema_id] = t.[schema_id]
INNER JOIN sys.pdw_table_distribution_properties tp
    ON t.[object_id] = tp.[object_id]
INNER JOIN sys.pdw_table_mappings tm
    ON t.[object_id] = tm.[object_id]
INNER JOIN sys.pdw_nodes_tables nt
    ON tm.[physical_name] = nt.[name]
INNER JOIN sys.dm_pdw_nodes pn
    ON  nt.[pdw_node_id] = pn.[pdw_node_id]
INNER JOIN sys.pdw_distributions di
    ON  nt.[distribution_id] = di.[distribution_id]
INNER JOIN sys.dm_pdw_nodes_db_partition_stats nps
 ON nt.[object_id] = nps.[object_id]
    AND nt.[pdw_node_id] = nps.[pdw_node_id]
    AND nt.[distribution_id] = nps.[distribution_id]
where tp.[distribution_policy_desc] ='HASH'
 AND row_count > 0
GROUP BY
  s.name
, t.name
, tp.[distribution_policy_desc]
)  A

