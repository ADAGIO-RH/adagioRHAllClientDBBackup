USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Docs].[spBorrarCatFiltroDocumento](    
 @IDCatFiltroDocumento int    
 ,@IDUsuarioCreo int    
)    
as    
 declare @IDDocumento int = 0;    
    
 select @IDDocumento = IDDocumento    
 from [Docs].[tblCatFiltrosDocumentos]    
 where IDCatFiltroDocumento= @IDCatFiltroDocumento
 
  Delete [Docs].[tblCatFiltrosDocumentos]
 where IDCatFiltroDocumento  = @IDCatFiltroDocumento 

 --Delete [Seguridad].[tblFiltrosUsuarios]
 --where IDCatFiltroUsuario = @IDCatFiltroUsuario  
 
 -- HAY QUE HACER EL PROCEDIMIENTO DE FILTROS
        
 --exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuarioCreo
GO
