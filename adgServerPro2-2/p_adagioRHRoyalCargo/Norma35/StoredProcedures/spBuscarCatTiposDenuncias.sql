USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarCatTiposDenuncias]
(
	  @IDTipoDenuncia INT = NULL
	 ,@IDUsuario INT
)
AS
BEGIN

	SELECT [IDTipoDenuncia]
		  ,[Descripcion]
		  ,[Disponible]
	  FROM [Norma35].[tblCatTiposDenuncias]
	  WHERE (ISNULL(@IDTipoDenuncia,0) = 0 OR IDTipoDenuncia = @IDTipoDenuncia)

	 
END
GO
