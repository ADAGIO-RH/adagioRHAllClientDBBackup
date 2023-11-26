USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC  [Reportes].[spReporteBasicoCatalogoExpedientesDigitales] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as

declare @IDIdioma varchar(20);
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

  select 		
		JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,c.Mask	
		,c.IDMedioNotificacion
		,JSON_VALUE(mn.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as MedioNotificacion
    from [RH].[tblCatTipoContactoEmpleado] c with (nolock)
		join App.tblMediosNotificaciones mn on mn.IDMedioNotificacion = c.IDMedioNotificacion
GO
