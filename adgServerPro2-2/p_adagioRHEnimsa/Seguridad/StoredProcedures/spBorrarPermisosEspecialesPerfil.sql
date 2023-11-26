USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBorrarPermisosEspecialesPerfil] --1,1  
(  
 @IDPerfil int  
 ,@IDPermiso int  
)  
AS  
BEGIN  
   
 if exists(select 1 from Seguridad.tblPermisosEspecialesPerfiles where IDPerfil = @IDPerfil and IDPermiso = @IDPermiso)  
 Begin  
   Delete Seguridad.tblPermisosEspecialesPerfiles  
   Where IDPerfil = @IDPerfil and IDPermiso = @IDPermiso  
 END  

END
GO
