USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Intranet.spBuscarCatEstatusSolicitud
AS
BEGIN
	select IDEstatusSolicitud,
		   Descripcion  
	from Intranet.tblCatEstatusSolicitudes
END
GO
