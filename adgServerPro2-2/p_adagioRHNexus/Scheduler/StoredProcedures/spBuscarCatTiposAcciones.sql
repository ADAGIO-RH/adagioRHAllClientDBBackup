USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Scheduler].[spBuscarCatTiposAcciones]
AS
BEGIN
	Select 
		IDTipoAccion
		,Descripcion
	from [Scheduler].tblCatTipoAcciones
END
GO
