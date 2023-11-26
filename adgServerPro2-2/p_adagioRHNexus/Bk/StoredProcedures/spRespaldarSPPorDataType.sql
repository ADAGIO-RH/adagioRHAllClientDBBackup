USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Bk].[spRespaldarSPPorDataType](
   -- @schema varchar(256)
    @DataType varchar(256)
    ,@BKID varchar(50)
)
as
    insert into [Bk].[tblStoredProcedures]([Definition],NombreSP,BKID)
    select m.definition, '['+s.name+'].['+o.name+']',@BKID 
    From sys.sql_modules m
	    join sys.objects o
		    on m.object_ID = o.object_ID
	   join sys.schemas s on o.schema_id = s.schema_id 
    where o.Name in (Select SPECIFIC_NAME 
				    From   Information_Schema.PARAMETERS 
				    Where  USER_DEFINED_TYPE_NAME = @DataType
						--and SPECIFIC_SCHEMA = @schema
						)

    select *
    from [Bk].[tblStoredProcedures]
    where BKID = @BKID
GO
