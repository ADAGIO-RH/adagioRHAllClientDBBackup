USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Docs.spIDocumentosFavoritos
(
	@IDDocumento int,
	@IDUsuario int
) 
AS
BEGIN
	IF NOT EXISTS(Select * from Docs.tblDocumentosFavoritos where IDDocumento = @IDDocumento and IDUsuario = @IDUsuario)
	BEGIN
		INSERT INTO Docs.tblDocumentosFavoritos (IDDocumento, IDUsuario)
		VALUES(@IDDocumento,@IDUsuario)
	END
END;
GO
