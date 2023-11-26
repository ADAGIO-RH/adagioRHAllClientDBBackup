USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBuscarUrls
(
	@IDModulo int = 0
)
AS
BEGIN
	Select IDUrl
			,IDModulo
			,Descripcion
			,URL
			,Tipo
	from App.tblCatUrls
	Where (IDModulo = @IDModulo) OR (@IDModulo = 0)
END
GO
