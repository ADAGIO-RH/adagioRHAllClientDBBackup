USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBorrarConfiguracionCatalogos --6
(
	@IDCliente int
)
AS
BEGIN
	DELETE [App].[tblConfiguracionCatalogos]
	WHERE IDCliente = @IDCliente
		
END
GO
