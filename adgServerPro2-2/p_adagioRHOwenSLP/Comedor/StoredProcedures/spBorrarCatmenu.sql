USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spBorrarCatmenu](@IDMenu    int = 0
									   ,@IDUsuario int
									   )
as
	begin try
		delete [Comedor].[tblCatMenus]
		where 
			  [Comedor].[tblCatMenus].[IDMenu] = @IDMenu;
	end try
	begin catch
		exec [App].[spObtenerError] 
			 @IDUsuario = @IDUsuario,
			 @CodigoError = '0302002';
		return 0;
	end catch;
GO
