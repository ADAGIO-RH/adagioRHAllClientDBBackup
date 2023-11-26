USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Resguardo].[spBorrarLocker](
	@IDLocker int 
	,@IDUsuario int
) as
	
	BEGIN TRY  
		DELETE [Resguardo].[tblCatLockers]
		WHERE IDLocker = @IDLocker
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
