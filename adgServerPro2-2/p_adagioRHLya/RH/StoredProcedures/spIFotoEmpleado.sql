USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIFotoEmpleado]  
(  
 @ClaveEmpleado varchar(max) = ''
)  
AS  
BEGIN  

	IF(@ClaveEmpleado not in (select ClaveEmpleado from [RH].[tblFotosEmpleados]))
	BEGIN
		INSERT INTO [RH].[tblFotosEmpleados]
           ([IDEmpleado]
           ,[ClaveEmpleado])
     VALUES
           ((select IDEmpleado from RH.tblEmpleados where ClaveEmpleado = @ClaveEmpleado)
           ,@ClaveEmpleado)
	END;

END
GO
