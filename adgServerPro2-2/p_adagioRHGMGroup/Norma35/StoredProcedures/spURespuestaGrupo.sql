USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create  proc [Norma35].[spURespuestaGrupo](
	@IDCatGrupo int,
	@RespuestaGrupo bit
) as
	update [Norma35].[tblCatGrupos]
		set RespuestaGrupo = @RespuestaGrupo
	where IDCatGrupo = @IDCatGrupo
GO
