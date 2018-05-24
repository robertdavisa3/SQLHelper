/*
Post-Deployment Script Template                            
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.        
 Use SQLCMD syntax to include a file in the post-deployment script.            
 Example:      :r .\myfile.sql                                
 Use SQLCMD syntax to reference a variable in the post-deployment script.        
 Example:      :setvar TableName MyTable                            
               SELECT * FROM [$(TableName)]                    
--------------------------------------------------------------------------------------
*/
:r .\Data.ProcHelper.AlwaysIgnoreList.sql
:r .\Data.ProcHelper.DefaultValues.sql
:r .\Data.ProcHelper.ExampleValues.sql
:r .\Data.ProcHelper.InsertIgnoreList.sql
:r .\Data.ProcHelper.UpdateIgnoreList.sql