USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarCompetencias]
(
	@IDCompetencia int = null
)
AS
BEGIN

		select 
		IDCompetencia
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatCompetencias]
		where IDCompetencia = @IDCompetencia or @IDCompetencia is null
END
GO
