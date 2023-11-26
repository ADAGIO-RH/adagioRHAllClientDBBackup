USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc App.spBuscarAdjuntosNotificacion (
	@IDEnviarNotificacionA int
) as

	select 
		IDAdjuntoNotificacion
		,IDEnviarNotificacionA
		,[FileName]
		,Extension
		,[Data]
		,FechaReg
	from App.tblAdjuntosNotificaciones
	where IDEnviarNotificacionA = @IDEnviarNotificacionA
GO
