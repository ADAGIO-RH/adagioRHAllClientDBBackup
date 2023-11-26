USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc BK.spUpdateAdjuntosEnviarNotificacionA(
	@IDEnviarNotificacionA int,
	@Adjuntos varchar(max)
) as

update App.tblEnviarNotificacionA
--update bk.[tblEnviarNotificacionANoEnvias20213001]
	set Adjuntos = @Adjuntos
where IDEnviarNotificacionA = @IDEnviarNotificacionA
GO
