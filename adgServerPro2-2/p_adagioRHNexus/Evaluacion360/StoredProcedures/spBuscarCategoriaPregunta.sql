USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Evaluacion360].[spBuscarCategoriaPregunta](
	@IDCategoriaPregunta int = 0
) as
	select IDCategoriaPregunta
		,Nombre
	from [Evaluacion360].[tblCatCategoriasPreguntas]
	where (IDCategoriaPregunta = @IDCategoriaPregunta or @IDCategoriaPregunta = 0)
GO
