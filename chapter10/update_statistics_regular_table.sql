Declare @id int = 1,@rowcount int = 0,@query nvarchar(2500)
CREATE TABLE #tmp(id int, full_stat_name varchar(2000))
Insert into #tmp
SELECT 
        ROW_NUMBER()
        OVER(ORDER BY (SELECT NULL))                                            AS [seq_nmbr]
, QUOTENAME(sm.[name])+'.'+QUOTENAME(tb.[name]) + '(' +QUOTENAME(st.[name] )+')' as Full_stat_Name
FROM    sys.objects            AS ob
JOIN    sys.stats            AS st    ON    ob.[object_id]        = st.[object_id]
JOIN    sys.tables            AS tb    ON    st.[object_id]        = tb.[object_id]
JOIN    sys.schemas            AS sm    ON    tb.[schema_id]        = sm.[schema_id]
WHERE    DATEDIFF(dd,STATS_DATE(st.[object_id],st.[stats_id]),GETDATE()) > 7 
AND is_external = 0
Select @rowcount = count(*)
FROM #tmp

WHILE @id <=@rowcount
BEGIN
Select @query = 'Update Statistics ' + Full_stat_Name
FROM #tmp 
WHERE @id = id 
EXEC sp_executesql @query
SET @id = @id + 1  
END

