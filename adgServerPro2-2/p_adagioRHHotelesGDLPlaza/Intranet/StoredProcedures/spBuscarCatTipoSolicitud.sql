USE [p_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Intranet.spBuscarCatTipoSolicitud
AS
BEGIN
	Select IDTipoSolicitud
		,Descripcion 
	from Intranet.tblCatTipoSolicitud
END
GO
