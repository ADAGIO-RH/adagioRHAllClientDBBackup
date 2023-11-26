USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spUDocumentoFilePath]
(
	@IDItem int,
	@FilePath Varchar(max),
	@IDUsuario int
)
AS
BEGIN
	UPDATE Docs.tblCarpetasDocumentos
		set FilePath = @FilePath
		, IDPublicador = @IDUsuario
	where IDItem = @IDItem
END
GO
