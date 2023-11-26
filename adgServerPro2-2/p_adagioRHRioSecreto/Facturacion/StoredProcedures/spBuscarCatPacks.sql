USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Facturacion.spBuscarCatPacks
(
	@IDPack int = null
)
AS
BEGIN
	SELECT 
		IDPack
		,NombrePack
	from Facturacion.tblCatPacks
	WHERE IDPack = @IDPack or @IDPack is null
END
GO
