Declare @id INT,@rnd int
Declare @sql nvarchar(1000)
SET @id = 1

WHILE @id < 100
BEGIN

SELECT @rnd = convert(int,rand() * 300000)
SET @id = @id + 1

SET @sql = 'SELECT tid,transaction_date,order_count,c1,c2 FROM dbo.transaction_tbl where tid = ' 
+ convert(varchar,@rnd)

EXEC sp_executesql @sql

END
GO
Select t1.pid,t1.c1,t2.c2,sum(t2.order_count)
FROM dbo.transaction_tbl t1 
inner join dbo.transaction_tbl t2 on t1.transaction_date = t2.transaction_date
WHERE t1.tid < 100
Group by t1.pid,t1.c1,t2.c2
order by sum(t2.order_count)
GO
