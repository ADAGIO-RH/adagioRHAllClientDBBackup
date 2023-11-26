USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBorrarFiltroUsuario](    
 @IDFiltrosUsuarios int    
 ,@IDUsuarioLogin int    
)    
as    
 declare @IDUsuario int = 0;    
    
 select @IDUsuario = IDUsuario    
 from [Seguridad].[tblFiltrosUsuarios]    
 where IDFiltrosUsuarios = @IDFiltrosUsuarios  
 
 Delete [Seguridad].[tblFiltrosUsuarios]
 where IDFiltrosUsuarios = @IDFiltrosUsuarios  
 
        
 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuarioLogin
GO
