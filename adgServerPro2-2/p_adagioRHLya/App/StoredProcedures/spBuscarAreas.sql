USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBuscarAreas
AS
BEGIN
	Select IDArea,Descripcion 
	from App.tblCatAreas
END
GO
