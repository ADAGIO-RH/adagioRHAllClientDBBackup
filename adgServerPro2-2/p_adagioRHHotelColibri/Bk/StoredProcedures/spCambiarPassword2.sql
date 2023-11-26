USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Bk].[spCambiarPassword2]
(
	@IDUsuario int,
	@Password varchar(max)
)
AS
BEGIN	
	update Seguridad.tblUsuarios
		set Password = case when Password is null then @Password else Password end,
		Activo = 1
	where IDUsuario = @IDUsuario
END
GO
