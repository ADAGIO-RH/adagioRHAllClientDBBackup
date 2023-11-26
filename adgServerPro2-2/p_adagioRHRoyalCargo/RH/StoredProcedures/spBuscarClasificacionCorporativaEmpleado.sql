USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarClasificacionCorporativaEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
		    PE.IDClasificacionCorporativaEmpleado,
			PE.IDEmpleado,
			PE.IDClasificacionCorporativa,
			P.Codigo,
			P.Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblClasificacionCorporativaEmpleado PE
			Inner join RH.tblCatClasificacionesCorporativas P
				on PE.IDClasificacionCorporativa = P.IDClasificacionCorporativa
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO
