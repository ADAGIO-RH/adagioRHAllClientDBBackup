USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc App.spBorrarIdioma(
	@IDIdioma varchar(10),
	@IDUsuario int
) as
	delete from App.tblIdiomas
	where IDIdioma = @IDIdioma
GO
