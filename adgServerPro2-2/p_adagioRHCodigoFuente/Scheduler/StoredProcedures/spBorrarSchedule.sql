USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Scheduler].[spBorrarSchedule]
(
	@IDSchedule int,
	@IDUsuario int
)
AS
BEGIN

	Delete [Scheduler].[tblSchedule]
	Where IDSchedule = @IDSchedule
END
GO
