USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spBorrarCatTipoMenu](@IDTipoMenu int = 0
										   ,@IDUsuario  int
										   )
as
	begin try
		delete [Comedor].[tblCatTiposMenus]
		where 
			  [IDTipoMenu] = @IDTipoMenu;
	end try
	begin catch
		exec [App].[spObtenerError] 
			 @IDUsuario = @IDUsuario,
			 @CodigoError = '0302002';
		return 0;
	end catch;
GO
