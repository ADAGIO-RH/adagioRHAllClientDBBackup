USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comunicacion].[spBorrarNotificacionBirthday](
	@IDNotificacionBirthday int,
	@IDUsuario int
) as

	delete Comunicacion.tblNotificacionBirthday
	where IDNotificacionBirthday = @IDNotificacionBirthday
GO
