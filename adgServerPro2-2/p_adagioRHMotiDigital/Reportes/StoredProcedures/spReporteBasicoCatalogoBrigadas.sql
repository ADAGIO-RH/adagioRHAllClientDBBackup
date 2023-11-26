USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC  [Reportes].[spReporteBasicoCatalogoBrigadas] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as

SELECT IDBrigada as [ID Brigada],
		   Descripcion
	FROM RH.tblCatBrigadas
GO
