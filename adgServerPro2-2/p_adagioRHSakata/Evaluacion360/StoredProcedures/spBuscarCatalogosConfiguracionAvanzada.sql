USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [Evaluacion360].[spBuscarCatalogosConfiguracionAvanzada](
	@IDConfiguracionAvanzada int = 0
) as
	select 
	IDCatalogoConfiguracionAvanzada
	,IDConfiguracionAvanzada
	,isnull(IDCatalogo,0) as IDCatalogo
	,DescripcionCatalogo
	from [Evaluacion360].[tblCatalogosConfiguracionAvanzada]
	where IDConfiguracionAvanzada = @IDConfiguracionAvanzada or @IDConfiguracionAvanzada = 0
GO
