USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc Resguardo.spMarcarHisarialImpreso(
	@IDHistorial int
) as
	update Resguardo.tblHistorial
		set TicketImpreso = 1,
			FechaHoraImpresion = getdate()
	where IDHistorial = @IDHistorial
GO
