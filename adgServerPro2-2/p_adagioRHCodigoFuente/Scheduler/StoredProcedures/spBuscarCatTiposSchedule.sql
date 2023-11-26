USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [Scheduler].[spBuscarCatTiposSchedule]
AS
BEGIN
	Select 
		IDTipoSchedule
		,Descripcion
		,Value
	from [Scheduler].[tblTipoSchedule]
END
GO
