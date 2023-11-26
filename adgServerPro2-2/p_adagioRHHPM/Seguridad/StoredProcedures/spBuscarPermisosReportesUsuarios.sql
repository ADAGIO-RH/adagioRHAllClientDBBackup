USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarPermisosReportesUsuarios](
	@IDUsuario int	
	,@IDUsuarioLogin int
) as
	declare 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuarioLogin, 'esmx')

	select
		 cr.IDReporteBasico
		,cr.IDAplicacion
		,JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Aplicacion
		,cr.Nombre
		,cr.Descripcion
		,cr.NombreReporte
		,isnull(cr.Personalizado,0) as Personalizado
		,isnull(prp.IDPermisoReporteUsuario,0) as IDPermisoReporteUsuario
		,isnull(prp.IDUsuario,0) as IDPerfil
		,ISNULL(prp.Acceso,0) as Acceso
	from [Reportes].[tblCatReportesBasicos]  cr
		join [App].[tblCatAplicaciones] a on a.IDAplicacion = cr.IDAplicacion
		left join Seguridad.tblPermisosReportesUsuarios prp on cr.IDReporteBasico = prp.IDReporteBasico and prp.IDUsuario = @IDUsuario
	order by cr.IDAplicacion, cr.Nombre
GO
