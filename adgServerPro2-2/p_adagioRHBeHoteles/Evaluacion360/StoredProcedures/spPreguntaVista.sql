USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc Evaluacion360.spPreguntaVista(
	@IDPregunta int
	,@IDUsuario int
) as
	update Evaluacion360.tblCatPreguntas
		set Vista = 1
	where IDPregunta = @IDPregunta
GO
