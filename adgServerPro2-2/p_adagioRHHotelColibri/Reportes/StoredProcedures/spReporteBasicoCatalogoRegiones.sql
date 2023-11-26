USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [Reportes].[spReporteBasicoCatalogoRegiones] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	Select
		Codigo
		,Descripcion
		,CuentaContable as [Cuenta Contable]
		,JefeRegion  as [Jefe de Region]
	From RH.tblCatRegiones
GO
