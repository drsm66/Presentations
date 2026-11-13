USE [master] ;
-- ALTER DATABASE [Bergamo_2026] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 60, INTERVAL_LENGTH_MINUTES = 1, QUERY_CAPTURE_MODE = ALL) ;
-- ALTER DATABASE [Bergamo_2026] SET QUERY_STORE (OPERATION_MODE = READ_ONLY) ;

ALTER DATABASE [Bergamo_2026_quick_demo] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 60, INTERVAL_LENGTH_MINUTES = 1, QUERY_CAPTURE_MODE = ALL) ;




/* ################################################ EXECUTE THIS ################################################ */
-- USE [Bergamo_2026] ;
USE [Bergamo_2026_quick_demo] ;


/* preparing environment */
-- ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = OFF;


-------------------------------------------------
-- Different Execution plans due to:
----- auto-created statistics by SQL.
----- Force Plan 
----- An Index 
-------------------------------------------------
/* ################################################ EXECUTE THIS ################################################ */
-- TRUNCATE TABLE [dbo].[Notes]
DROP TABLE IF EXISTS [dbo].[Notes]
CREATE TABLE [dbo].[Notes](
	[ID] [int] NULL,
	[NAME] [varchar](200) NULL,
	[id2] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Notes] PRIMARY KEY CLUSTERED ([id2] ASC))
--NO-- CREATE INDEX Notes_idx1 ON Notes ([ID])


/* ################################################ EXECUTE THIS ################################################ */
-------------------------------------------------
-- Create the store procedure
--------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GiveNotes
   @N1 AS INT = null
   , @N2 AS INT = null
AS
-- retrieve the number of records depending on the [ID] range as by input parameters
-- SELECT count(Name),name, 'easyfilter' AS easyfilter FROM Notes where ID<@N1 AND ID>@N2 group by Name
SELECT count(Name),name, 'easyfilter' AS easyfilter FROM Notes where ID BETWEEN @N2 AND @N1 group by Name



--NO-- Prompt #1: Find the queries in Query Store that were executed by the stored procedure dbo.GiveNotes or that reference the notes table
--NO-- Prompt #2: Great! how many times has been executed the query id #1
--NO-- Prompt #3: do you find any performance issue with the query id #1?


/* ################################################ EXECUTE THIS ################################################ */
/* performing the test */
-- execute 1 time (2 records after the execution)
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) 
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) FROM Notes

 
/* ################################################ EXECUTE THIS ################################################ */
-- start the powershell routine


/* ################################################ EXECUTE THIS ################################################ */
-- cleanup everything to collect a clear situation
-- ALTER DATABASE Bergamo_2026 SET QUERY_STORE CLEAR;
ALTER DATABASE Bergamo_2026_quick_demo SET QUERY_STORE CLEAR;
DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS

-->> powershell response time is 0 msec average
-->> verify the query store -->> there is only one execution plan


/* ################################################ EXECUTE THIS ################################################ */
-- execute 10 times
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) 
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) FROM Notes


DECLARE @RowCount BIGINT; SELECT @RowCount = COUNT_BIG(*) FROM Notes (NOLOCK); PRINT 'Number of records: ' + CAST(@RowCount AS varchar(20));
-->> 4.094 records after this step is executed
-->> powershell response time is 2-5 msec average
-->> verify the query store -->>  2 execution plans are created


/* ################################################ EXECUTE THIS ################################################ */
-- execute 7 times
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) 
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) FROM Notes


DECLARE @RowCount BIGINT; SELECT @RowCount = COUNT_BIG(*) FROM Notes (NOLOCK); PRINT 'Number of records: ' + CAST(@RowCount AS varchar(20));
-->> 524.286  records after this step is executed
-->> powershell response time is 80-100 msec average
-->> verify the query store -->>  3 execution plans are created



/* ################################################ EXECUTE THIS ################################################ */
-- execute 3 times
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) 
INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) FROM Notes

DECLARE @RowCount BIGINT; SELECT @RowCount = COUNT_BIG(*) FROM Notes (NOLOCK); PRINT 'Number of records: ' + CAST(@RowCount AS varchar(20));
-->>  4.194.302  records after this step is executed
-->> powershell response time is 100-200 msec average
-->> verify the query store -->>  4 execution plans are created


/* ################################################ EXECUTE THIS ################################################ */
-- stop the powershell routine
-- issue is simulated, response time increased from 1-2 msec to 100-200 msec


--NO--------------------------------
--NO-- -- execute 4 times
--NO-- INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) 
--NO-- INSERT INTO Notes (ID,Name) SELECT RAND()*(100000 - 1) + 1, 'Info:'+convert(varchar(200),RAND()*(100000 - 1) + 1) FROM Notes
--NO-- -- at this point, powershell is completing stored procedure in approx 300-500 msec


