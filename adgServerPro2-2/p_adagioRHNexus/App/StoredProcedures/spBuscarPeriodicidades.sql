USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarPeriodicidades](
    @IDUsuario int
)

AS
BEGIN
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select 
		cp.IDPeriodicidad
		,JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Periodicidad')) as Periodicidad
	from App.TblCatPeriodicidades cp
	
END
GO
