USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [Reportes].[spReporteBasicoCatalogoDivisiones] (
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
		,CuentaContable		
		,JefeDivision   
	from RH.tblCatDivisiones  with(nolock)
GO
