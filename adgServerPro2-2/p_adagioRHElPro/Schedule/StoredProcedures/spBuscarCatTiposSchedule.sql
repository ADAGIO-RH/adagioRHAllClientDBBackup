USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Schedule.spBuscarCatTiposSchedule
AS
BEGIN
	Select 
		IDTipoSchedule
		,Descripcion
		,Value
	from [Schedule].[tblTipoSchedule]
END
GO
