USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBuscarTraduccion](@IDUsuario int = 0,@IDPreferencia int = 0)
as 
	
	select 
		I.IDIdioma, 
		I.Traduccion
	   from App.tblIdiomas I
	where I.IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
GO
