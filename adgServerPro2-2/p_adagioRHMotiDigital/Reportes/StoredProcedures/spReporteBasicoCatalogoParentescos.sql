USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC  [Reportes].[spReporteBasicoCatalogoParentescos] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as

SELECT  IDParentesco as [ID Parentesco],
		   Descripcion
	FROM [RH].[TblCatParentescos]
GO
