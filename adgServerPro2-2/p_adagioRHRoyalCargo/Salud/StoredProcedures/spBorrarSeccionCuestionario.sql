USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salud].[spBorrarSeccionCuestionario]
(
	@IDSeccion int,
	@IDUsuario int
)
AS
BEGIN
	DELETE Salud.tblSecciones
	WHERE IDSeccion = @IDSeccion
END
GO
