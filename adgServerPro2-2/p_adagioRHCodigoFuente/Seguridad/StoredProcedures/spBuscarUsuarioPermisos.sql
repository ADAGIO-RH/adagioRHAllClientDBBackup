USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarUsuarioPermisos](
	@IDUsuario int
)
AS
BEGIN
	DECLARE  
		@IDIdioma varchar(225)
	;
 
	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
 
	select 
		isnull(PP.IDUsuarioPermiso,0)as IDUsuarioPermiso
		,isnull(PP.IDUsuario,@IDUsuario) as IDUsuario
		,isnull(A.IDArea,0) as IDArea
		,A.Descripcion as Area
		,isnull(M.IDModulo,0) as IDModulo
		,M.Descripcion Modulo
		,ISNULL(U.IDUrl,0) as IDUrl
		,U.URL as URL
		,JSON_VALUE(U.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Accion
		,U.Tipo
		,cast(case when (pp.IDUrl is null) then 0 
			else 1
			end  as bit)as TienePermiso
	from App.tblCatUrls U
		left outer join Seguridad.tblUsuariosPermisos PP on PP.IDUrl = U.IDUrl
			and PP.IDUsuario = @IDUsuario
		inner join App.tblCatModulos M on M.IDModulo = U.IDModulo
		inner join App.tblCatAreas A on A.IDArea = M.IDArea
	
END
GO
