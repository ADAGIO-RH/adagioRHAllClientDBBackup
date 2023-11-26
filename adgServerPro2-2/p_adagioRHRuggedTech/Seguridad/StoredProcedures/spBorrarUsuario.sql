USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarUsuario]
(
	@IDUsuario int 

)
AS
BEGIN
		Delete Seguridad.tblUsuariosPermisos
		Where IDUsuario = @IDUsuario

		Delete Seguridad.tblPermisosUsuarioControllers
		Where IDUsuario = @IDUsuario

		Delete Seguridad.tblPermisosEspecialesUsuarios 
		Where IDUsuario = @IDUsuario

		Delete App.tblAplicacionUsuario 
		Where IDUsuario = @IDUsuario

		DELETE Seguridad.tblUsuarios
		WHERE IDUsuario = @IDUsuario
	
END
GO
