
/* 
#-------------------------------------------
# SQL Server on RDS Backup and Restore Summary
#-------------------------------------------
*/

-- Back up SQL DB from SQL Server RDS instance to target S3 bucket
exec msdb.dbo.rds_backup_database 
    @source_db_name='DBNAME',
    @s3_arn_to_backup_to='BUCKETARN/PATHTOFILE',
    @overwrite_S3_backup_file=1,
    @type='FULL';

-- Restore SQL DB backup from target S3 bucket to SQL Server RDS instance 

exec msdb.dbo.rds_restore_database
	@restore_db_name='DBNAME',
	@s3_arn_to_restore_from='BUCKETARN/PATHTOFILE'

-- Check task status
exec msdb.dbo.rds_task_status @db_name='DBNAME';




/* 
#-------------------------------------------
# SQL Server User Creation
#-------------------------------------------
*/

CREATE LOGIN myusername WITH PASSWORD=N'mypassword', 
                 DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

EXEC sp_addsrvrolemember 'myusername', 'desired_role'
CREATE USER myusername FOR LOGIN myusername WITH DEFAULT_SCHEMA=[dbo]