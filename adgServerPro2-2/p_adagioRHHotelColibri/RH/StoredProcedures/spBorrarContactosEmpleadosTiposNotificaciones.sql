USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [RH].[spBorrarContactosEmpleadosTiposNotificaciones] 
(
    @IDContactoEmpleadoTipoNotificacion	int  = null
) as

    delete from RH.tblContactosEmpleadosTiposNotificaciones
    where IDContactoEmpleadoTipoNotificacion=@IDContactoEmpleadoTipoNotificacion;
GO
