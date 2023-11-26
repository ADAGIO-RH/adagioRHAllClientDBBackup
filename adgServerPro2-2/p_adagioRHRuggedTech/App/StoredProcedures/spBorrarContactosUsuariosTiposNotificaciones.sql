USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [App].[spBorrarContactosUsuariosTiposNotificaciones] 
(
    @IDContactoUsuarioTipoNotificacion	int  = null
) as

    delete from App.tblContactosUsuariosTiposNotificaciones  
    where IDContactoUsuarioTipoNotificacion=@IDContactoUsuarioTipoNotificacion;
GO
