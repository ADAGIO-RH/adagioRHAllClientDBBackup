USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc zkteco.spBorrarFingerPrintEmpleado(
	@IDFingerPrintEmpleado int
) as
	delete from zkteco.tblFingerPrintEmpleado
	where IDFingerPrintEmpleado = @IDFingerPrintEmpleado
GO
