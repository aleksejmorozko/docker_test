select name, physical_name from sys.master_files
where database_id < 5

alter database tempdb
modify file (name = tempdev, filename = '/var/opt/mssql/data/tempdb.mdf')

use [master]
restore database [AdventureWorks2017] from disk = N'/app/AdventureWorks2017.bak' 
  WITH FILE = 1,  
  RECOVERY;
GO  

CREATE DATABASE testDB;

USE testDB
GO

CREATE TABLE SQLTest (
   ID INT NOT NULL PRIMARY KEY,
   c1 VARCHAR(100) NOT NULL,
   dt1 DATETIME NOT NULL DEFAULT GETDATE()
)

INSERT INTO SQLTest (ID, c1) VALUES (1, 'test1')
INSERT INTO SQLTest (ID, c1) VALUES (2, 'test2')
INSERT INTO SQLTest (ID, c1) VALUES (3, 'test3')
INSERT INTO SQLTest (ID, c1) VALUES (4, 'test4')
INSERT INTO SQLTest (ID, c1) VALUES (5, 'test5')
GO

use [testDB]
select * from SQLTest
go

BACKUP DATABASE testDB
TO DISK = '/var/opt/mssql/TestDB.bak'
   WITH FORMAT,
      MEDIANAME = 'SQLServerBackups',
      NAME = 'Full Backup of SQLTestDB';
GO

restore database [testDB] from disk = N'/var/opt/mssql/TestDB.bak' 
    WITH FILE = 1, 
    REPLACE, 
    NORECOVERY, 
    STATS = 5
GO


drop database testDB
go
use master
go

----------------------------------------
RESTORE DATABASE testDB  
  FROM DISK =  N'/var/opt/mssql/TestDB.bak'
  WITH FILE=1,   
  RECOVERY;
GO 
----------------------------------------  
--Restore the regular log backup (from backup set 2).  
RESTORE LOG testDB   
  FROM DISK =  N'/var/opt/mssql/TestDB.bak'
  WITH FILE=2,   
    NORECOVERY;
 
--Restore the tail-log backup (from backup set 3).  
RESTORE LOG testDB 
  FROM DISK =  N'/var/opt/mssql/TestDB.bak'
  WITH FILE=3,   
    NORECOVERY;  
GO  
--recover the database:  
RESTORE DATABASE testDB WITH RECOVERY;  
GO


use AdventureWorks2017
select * from HumanResources.Department

SELECT TABLE_NAME AS [Название таблицы]
   FROM INFORMATION_SCHEMA.TABLES
   WHERE table_type='BASE TABLE'


--------- Backup POWERSHELL ---------------------
  Backup-SqlDatabase -ServerInstance localhost\
    -Database AdventureWorks2017\
    -BacupAction Log\
    -BackupFile 'C:\Backup\awLogs.bak'

--------- Backup ServerManagmentStudio --------------------
  Backup LOG AdventureWorks2017
    To Disk = N'C:\Backup\AdvWorks.bak'
    with init;
  Go
  
  Backup Database AdventureWorks2017
    To Disk = N'C:\Backup\AdvWorks.bak'
    with differential;                        --тип бэкапа
  Go

  -- Partial backup - нельзя сделать в SMS, только TransactSQL, 
  Backup database LargeDB read_write_filegroups to DISK = 'R:\bacups\LrgRW.bak' WITH INIT;

  --A FILE GROUP:`
  Backup database LargeDB Filegroup='LrgFG' to DISK='R:\backups\LrgFG.bak' WITH INIT;

  ------------------ Пример процесса восстановления БД ------------------------------- 
RESTORE DATABASE work_demo FROM DISK='d:\bacups\work_demo_full.bak' WITH NORECOVERY, REPLACE
RESTORE DATABASE work_demo FROM DISK='d:\bacups\work_demo_diff.bak' WITH NORECOVERY
RESTORE DATABASE work_demo FROM DISK='d:\bacups\work_demo_log1.trn' WITH NORECOVERY
RESTORE DATABASE work_demo FROM DISK='d:\bacups\work_demo_log2.trn' WITH NORECOVERY
RESTORE DATABASE work_demo FROM DISK='d:\bacups\work_demo_log3.trn' WITH NORECOVERY
RESTORE DATABASE work_demo FROM DISK='d:\bacups\work_demo_TailLog.trn' WITH NORECOVERY
RESTORE DATABASE work_demo WITH RECOVERY

  
-------   Bulk Copy Program: bcp - выгрузка/загрузка в/из файл данных ----------------
--Export
bcp AdventureWorks2017.HumanResources.Department format nul -x -f d:\dept_format.xml -c -T
bcp AdventureWorks2017.HumanResources.Department OUT d:\dept.bcp -T -c
--Import
bcp Resources.dbo.Depts IN D:\dept.bcp -f D:\dept_format.xml 

BULK INSERT dbo.Depts
  FROM 'd:\dept.bcp'
  WITH (formatfile = 'd:\dept_format.xml')


select * into dbo.Departments
  FROM OPENROWSET (
    BULK 'D:\depts.bcp',
    FORMATFile = 'D:\depts_format.xml'
  ) AS t1;
GO


--HomeWork_11
USE master
DROP DATABASE IF EXISTS [CorruptionTest]
CREATE DATABASE [CorruptionTest]
ALTER DATABASE [CorruptionTest] MODIFY FILE ( NAME = N'CorruptionTest', SIZE = 2GB )
ALTER DATABASE [CorruptionTest] MODIFY FILE ( NAME = N'CorruptionTest_log', SIZE = 2GB )
ALTER DATABASE [CorruptionTest] SET RECOVERY FULL;
ALTER DATABASE [CorruptionTest] SET PAGE_VERIFY CHECKSUM  
CREATE TABLE CorruptionTest.dbo.mssqltips 
(increment INT, randomGUID uniqueidentifier, randomValue INT, BigCol CHAR(2000) DEFAULT 'a', INDEX CIX_SQLShack_increment1 UNIQUE CLUSTERED (increment))

SET NOCOUNT ON;
DECLARE @counter INT = 1;
BEGIN TRAN
   WHILE @counter <= 250000
   BEGIN
      INSERT INTO CorruptionTest.dbo.mssqltips (increment, randomGUID, randomValue) 
      VALUES (@counter, NEWID(), ABS(CHECKSUM(NewId())) % 140000000)
      SET @counter += 1
   END;
COMMIT TRAN;

------2------
USE master;
ALTER DATABASE [CorruptionTest] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DBCC WRITEPAGE ('CorruptionTest', 1, 8330, 4000, 1, 0x0, 1)
ALTER DATABASE [CorruptionTest] SET MULTI_USER;

-----3------
SELECT * FROM [CorruptionTest].[dbo].mssqltips 
ORDER BY increment DESC

-----6------
USE [CorruptionTest]
CREATE TABLE [FillerTable] (
[c1] INT IDENTITY,
[c2] CHAR (8000) DEFAULT 'filler');

INSERT INTO [FillerTable] DEFAULT VALUES;
USE [CorruptionTest]
CREATE TABLE [ProdTable] (
[c1] INT IDENTITY,
[c2] CHAR (8000) DEFAULT 'production');
CREATE CLUSTERED INDEX [prod_cl] ON [ProdTable] ([c1]);

INSERT INTO [ProdTable] DEFAULT VALUES;

--7-----
USE [CorruptionTest]
DROP TABLE [FillerTable];


DBCC SHRINKDATABASE ([CorruptionTest]);
