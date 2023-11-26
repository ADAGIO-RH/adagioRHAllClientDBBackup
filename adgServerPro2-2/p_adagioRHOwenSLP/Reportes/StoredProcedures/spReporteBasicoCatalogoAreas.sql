USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [Reportes].[spReporteBasicoCatalogoAreas] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	SELECT 	
		Codigo
		,Descripcion
		,CuentaContable	
		,JefeArea 
	FROM RH.tblCatArea
GO
