USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-06
-- Description:	Procedimiento para obtener todo el listado de Proveedores
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarProveedoresBolsaDeTrabajo]
	(
	@IDProveedoresBolsaDeTrabajo int = 0
	)
AS
BEGIN
	IF(@IDProveedoresBolsaDeTrabajo <> 0)
		select * from [Reclutamiento].[tblProveedoresBolsaDeTrabajo] where IDProveedorBolsaDeTrabajo = @IDProveedoresBolsaDeTrabajo
	else
	begin
		select * from [Reclutamiento].[tblProveedoresBolsaDeTrabajo]
	end
END
GO
