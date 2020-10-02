CREATE PROCEDURE [dbo].[SQL_REST_API] (@json VARCHAR(MAX))AS
BEGIN

/*
Notes:
-- Everything has single quotes placed around the values.  SQL Server ignores for numeric data types.

-- This is the supported operations:
-- table: required -> the table to interact
-- operation: required -> valid values: select, insert, delete, update, upsert
-- select: fields -> the fields to select, the values are ignored
--         match  -> the fields and values to which to filter
-- insert: fields -> the fields to insert with their values
--         match  -> is ignored
--         note   -> do not provide any identity columns
-- update: fields -> the fields to update with their values
--         match  -> the fields and values to which to identify the records to update
--         note   -> do not provide any identity columns (they cannot be updated)
-- upsert: fields -> the fields to insert with their values
--         match  -> the fields and values to which to perform the update, if no match then an insert is performed
--         note   -> do not provide any identity columns
-- delete: fields -> not required
--         match  -> the fields and values to which to identify the records to delete

-- The match clause is "optional", but you really need to provide it to prevent actions such as selecting the
-- entire table or deleting an entire table.

-- Sample JSON
{
    "schema" : "dbo",
    "table" : "TestCrud",
    "operation" : "select",
    "field-Field1" : "",
    "field-Field2" : "",
    "field-Field3" : "",
    "match-Field1" : "3"
}
*/

SET NOCOUNT ON;  

/*
To Test:
	declare @json varchar(max)

	SET @json = 
	'
	{
		"schema" : "dbo",
		"table" : "States",
		"operation" : "select",
		"field-StateAbbreviation" : "",
		"field-StateName" : ""
	}
	'

	SET @json = 
	'
	{
		"operation" : "select",
		"sql" : "SELECT TOP 10 * FROM dbo.States"
	}
	'

	exec [dbo].[SQL_REST_API] @json

	drop TABLE #tbl
*/

DECLARE @jsonKey VARCHAR(100); 
DECLARE @jsonValue VARCHAR(100);
DECLARE @jsonType INT;
DECLARE @SchemaName VARCHAR(100);
DECLARE @TableName VARCHAR(100);
DECLARE @OperationName VARCHAR(100);
DECLARE @SQLStatement VARCHAR(100);
DECLARE @FieldNameList VARCHAR(5000);
DECLARE @FieldValueList VARCHAR(5000);
DECLARE @MatchList VARCHAR(5000);
DECLARE @UpdateList VARCHAR(5000);
DECLARE @TempString VARCHAR(100);
DECLARE @SQL VARCHAR(5000);

SET @FieldNameList = '';
SET @FieldValueList = '';
SET @UpdateList = '';
SET @MatchList = 'WHERE ';


/*
-- Loop through the JSON posted and create a list of fields and values to build the subsuquent SQL statement.
-- The type of SQL (select, insert, update, delete) that is required is not known at this point; therefore,
-- all the information to construct the different types is created at this point.
*/
CREATE TABLE #tbl ([Sequence] INT, [key] VARCHAR(100), [value] VARCHAR(100), [type] VARCHAR(100))
WITH (DISTRIBUTION = ROUND_ROBIN) ;

--CREATE TABLE #tbl WITH (DISTRIBUTION = ROUND_ROBIN) AS
INSERT INTO #tbl ([Sequence], [key], [value], [type])
SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY (SELECT NULL))) AS Sequence,
       CONVERT(VARCHAR(100),[key]), 
	   CONVERT(VARCHAR(100),[value]), 
	   CONVERT(VARCHAR(100),[type])
  FROM OPENJSON(@json);
  
DECLARE @nbr_statements INT = (SELECT COUNT(*) FROM #tbl);
DECLARE @i INT = 1;

WHILE   @i <= @nbr_statements
BEGIN
    SELECT @jsonKey = [key], @jsonValue = [value], @jsonType = [type] FROM #tbl WHERE Sequence = @i;
    IF @jsonKey = 'schema'
      BEGIN
      -- The schema for the SQL statement
      SET @SchemaName = '[' + @jsonValue + ']';
      END
    ELSE IF @jsonKey = 'table'
      BEGIN
      -- The table for the SQL statement
      SET @TableName = '[' + @jsonValue + ']';
      END
    ELSE IF @jsonKey = 'sql'
      BEGIN
      -- Ad-hoc SQL
      SET @SQLStatement =  @jsonValue ;
      END
	ELSE IF @jsonKey = 'operation'
      BEGIN
      -- The type of operation which determines the type of SQL statement to build
      SET @OperationName = @jsonValue;
      END
    ELSE IF LEFT(@jsonKey, 6) = 'field-'
       BEGIN
       -- The list of fields and values for either an insert or update statement
       SET @TempString = SUBSTRING(@jsonKey,7,LEN(@jsonKey)-6);
       SET @FieldNameList = @FieldNameList + '[' + @TempString + '],';
       SET @FieldValueList = @FieldValueList + '''' + @jsonValue + ''',';
       SET @UpdateList = @UpdateList + '[' + @TempString + '] = ''' + REPLACE(@jsonValue,'''','''''') + ''',';
       END
    ELSE IF LEFT(@jsonKey, 6) = 'match-'
       BEGIN
       -- The match, or WHERE clause for the SQL statement
       SET @TempString = SUBSTRING(@jsonKey,7,LEN(@jsonKey)-6);
       IF @jsonType = 2
          BEGIN
          -- numeric (no quotes needed and we don't want SQL converting INTs to STRINGs and slowing down indexes being used)
          SET @MatchList = @MatchList + '[' + @TempString + '] = ' + @jsonValue + ' AND ';
          END
       ELSE
          BEGIN
          -- string or such
          -- https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql?view=sql-server-2017#return-value
          SET @MatchList = @MatchList + '[' + @TempString + '] = ''' + REPLACE(@jsonValue,'''','''''') + ''' AND ';
          END
       END


    SET     @i +=1;
END


/*
DECLARE jsonCursor CURSOR FOR SELECT [key], [value], [type] FROM OPENJSON(@json);
OPEN jsonCursor;
FETCH NEXT FROM jsonCursor INTO @jsonKey, @jsonValue, @jsonType;
  
WHILE @@FETCH_STATUS = 0  
BEGIN 

    FETCH NEXT FROM jsonCursor INTO @jsonKey, @jsonValue, @jsonType;
END -- WHILE
CLOSE jsonCursor;  
DEALLOCATE jsonCursor;
*/

/*
-- Clean up trailing characters
*/
IF LEN(@FieldNameList) > 0
   BEGIN
   -- Remove trailing comma
   SET @FieldNameList = SUBSTRING(@FieldNameList,1,LEN(@FieldNameList)-1);
   SET @FieldValueList = SUBSTRING(@FieldValueList,1,LEN(@FieldValueList)-1);
   END

IF @MatchList = 'WHERE '
   BEGIN
   SET @MatchList = ''
   END
ELSE 
   BEGIN
   -- Remove trailing AND
   SET @MatchList = SUBSTRING(@MatchList,1,LEN(@MatchList)-4);
   END

IF @UpdateList != ''
   BEGIN
   -- Remove trailing comma
   SET @UpdateList = SUBSTRING(@UpdateList,1,LEN(@UpdateList)-1);
   END


/*
-- Generate the SQL Statement
*/
IF ISNULL(@SQLStatement,'') != ''
   BEGIN
   SET @SQL =@SQLStatement;
   END
ELSE
   BEGIN
	IF @OperationName = 'select'
	   BEGIN
	   -- Create a SELECT statement with the field list and a WHERE clause
	   SET @SQL = 'SELECT ' + @FieldNameList + ' FROM ' + @SchemaName + '.' + @TableName;
	   IF @MatchList != ''
		  BEGIN
		  SET @SQL = @SQL + ' ' + @MatchList;
		  END
	   --SET @SQL = @SQL + ' FOR JSON PATH, ROOT(''Results'');';
	   END
	ELSE IF @OperationName = 'insert'
	   BEGIN
	   -- Create an INSERT statement with the fields and values (Match list is not used)
	   SET @SQL = 'INSERT INTO ' + @SchemaName + '.' + @TableName +' (' + @FieldNameList + ') VALUES (' + @FieldValueList + ');'; 
	   END
	ELSE IF @OperationName = 'update'
	   BEGIN
	   -- CREATE an UPDATE statement with the fiels and values along with a WHERE clause (optional)
	   SET @SQL = 'UPDATE ' + @SchemaName + '.' + @TableName + ' SET ' + @UpdateList;
	   IF @MatchList != ''
		  BEGIN
		  SET @SQL = @SQL + ' ' + @MatchList;
		  END   
	   SET @SQL = @SQL + ';';
	   END
	ELSE IF @OperationName = 'upsert'
	   BEGIN
	   -- Create an INSERT and UPDATE statement with the fields and values.  An If..Then tests for the records existance to UPSERT. 
	   SET @SQL = 'IF EXISTS (SELECT 1 FROM ' + @SchemaName + '.' + @TableName ;
	   IF @MatchList != ''
		  BEGIN
		  SET @SQL = @SQL + ' ' + @MatchList;
		  END
	   SET @SQL = @SQL + ') '
	   SET @SQL = @SQL + 'BEGIN '
	   SET @SQL = @SQL + 'UPDATE ' + @SchemaName + '.' + @TableName +' SET ' + @UpdateList;
	   IF @MatchList != ''
		  BEGIN
		  SET @SQL = @SQL + ' ' + @MatchList;
		  END   
	   SET @SQL = @SQL + ' END '
	   SET @SQL = @SQL + 'ELSE '
	   SET @SQL = @SQL + 'BEGIN '
	   SET @SQL = @SQL + 'INSERT INTO ' + @SchemaName + '.' + @TableName +' (' + @FieldNameList + ') VALUES (' + @FieldValueList + ');'; 
	   SET @SQL = @SQL + '; END ';    
	   END
	ELSE IF @OperationName = 'delete'
	   BEGIN
	   -- Create a DELETE statement with a WHERE clause (fields are not used)
	   SET @SQL = 'DELETE FROM ' + @SchemaName + '.' + @TableName ; 
	   IF @MatchList != ''
		  BEGIN
		  SET @SQL = @SQL + ' ' + @MatchList;
		  END
	   SET @SQL = @SQL + ';';
	   END
   END

-- Debugging
PRINT @SQL; 

EXECUTE(@SQL);         

END
GO
