USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [RH].[spBorrarUbicacionEmpleado](
 	@IDEmpleado int = 0
	,@IDUsuario int
   
)
as BEGIN
	delete from [RH].[tblUbicacionesEmpleados] 
	where IDEmpleado =@IDEmpleado
END
GO
