USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spBorrarDetalleMenu](@IDDetalleMenu int
										   ,@IDUsuario     int
										   )
as
	begin try
		delete [Comedor].[tblDetalleMenu]
		where 
			  [IDDetalleMenu] = @IDDetalleMenu;
	end try
	begin catch
		exec [App].[spObtenerError] 
			 @IDUsuario = @IDUsuario,
			 @CodigoError = '0302002';
		return 0;
	end catch;
GO
