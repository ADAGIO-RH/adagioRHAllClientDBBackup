USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc zkteco.spBuscarFingerPrintEmpleado(
	@IDEmpleado int
) as
	select *
	from zkteco.tblFingerPrintEmpleado
	where IDEmpleado = @IDEmpleado
GO
