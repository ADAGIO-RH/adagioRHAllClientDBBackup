USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Intranet.spBorrarConfigDashboardNominaConfig
(
	@IDConfigDashboardNomina int
)
AS
BEGIN
	EXEC intranet.spBuscarConfigDashboardNominaConfig @IDConfigDashboardNomina
	DELETE Intranet.tblConfigDashboardNomina
	WHERE IDConfigDashboardNomina = @IDConfigDashboardNomina
END
GO
