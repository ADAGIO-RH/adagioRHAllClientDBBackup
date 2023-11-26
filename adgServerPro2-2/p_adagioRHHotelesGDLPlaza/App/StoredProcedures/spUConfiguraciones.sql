USE [p_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [App].[spUConfiguraciones](  
    @IDConfiguracion varchar(255) = null  
    ,@Valor Varchar(max)
)   
as  

update [App].[tblconfiguracionesGenerales]
set valor = @Valor
where IDConfiguracion = @IDConfiguracion

exec [App].[spBuscarConfiguraciones] @IDConfiguracion = @IDConfiguracion
GO
