USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarFacIntegracionEmpleado]
(
	@IDFacIntegracionEmpleado int 
	
)
AS
BEGIN
	
	
	declare @IDEmpleado int = 0;

	select @IDEmpleado = IDEmpleado from RH.tblFacIntegracionEmpleado 
	where IDFacIntegracionEmpleado = @IDFacIntegracionEmpleado


	DELETE RH.tblFacIntegracionEmpleado 
	where IDFacIntegracionEmpleado = @IDFacIntegracionEmpleado
		
	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
END
GO
