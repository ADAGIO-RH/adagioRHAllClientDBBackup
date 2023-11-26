USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Docs.spUDocumentoFilePath
(
	@IDItem int,
	@FilePath Varchar(max)
)
AS
BEGIN
	UPDATE Docs.tblCarpetasDocumentos
		set FilePath = @FilePath
	where IDItem = @IDItem
END
GO
