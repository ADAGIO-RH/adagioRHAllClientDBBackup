USE [p_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBuscarIdiomas
(
	@IDIdioma Varchar(10) = null
)
AS
BEGIN
	
	SELECT 
		IDIdioma
		,Idioma 
	FROM App.tblIdiomas
	WHERE (IDIdioma = @IDIdioma) OR (@IDIdioma is null)

END
GO
