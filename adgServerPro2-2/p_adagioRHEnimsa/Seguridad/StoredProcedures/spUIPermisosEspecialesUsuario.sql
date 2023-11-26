USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spUIPermisosEspecialesUsuario]--  1,1
(
	@IDUsuario int
	,@IDPermiso int
	
)
AS
BEGIN



	if not exists(select 1 from Seguridad.tblPermisosEspecialesUsuarios where IDUsuario = @IDUsuario and IDPermiso = @IDPermiso)
	Begin
			insert into Seguridad.tblPermisosEspecialesUsuarios(IDUsuario,IDPermiso)
			select @IDUsuario,@IDPermiso
	END

	
END
GO
