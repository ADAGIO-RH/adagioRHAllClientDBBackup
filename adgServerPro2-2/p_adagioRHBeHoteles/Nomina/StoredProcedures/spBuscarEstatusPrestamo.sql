USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Nomina.spBuscarEstatusPrestamo
AS
BEGIN
	Select 
	IDEstatusPrestamo
	,Descripcion 
	from Nomina.tblCatEstatusPrestamo
END
GO
