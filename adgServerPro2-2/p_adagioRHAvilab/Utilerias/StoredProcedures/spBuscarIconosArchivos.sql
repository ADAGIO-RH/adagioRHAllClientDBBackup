USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Utilerias.spBuscarIconosArchivos
AS
BEGIN
	Select Icono from Utilerias.tblIconosArchivos
END
GO
