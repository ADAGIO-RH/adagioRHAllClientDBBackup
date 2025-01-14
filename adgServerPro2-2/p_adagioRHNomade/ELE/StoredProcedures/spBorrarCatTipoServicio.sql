USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ELE].[spBorrarCatTipoServicio]-- 2,1
(
	@IDTipoServicio int,
	@IDUsuario int
)
AS
BEGIN
	
	IF EXISTS(Select Top 1 1 from ELE.tblServicioEmpleados where IDTipoServicio = @IDTipoServicio)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '0302002'
		return 0;
	END	
		
    DECLARE @OldJSON Varchar(Max),
    @NewJSON Varchar(Max)

    select @OldJSON = a.JSON from [RH].[tblCatClientes] b
    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
    WHERE b.IDCliente = @IDTipoServicio

    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblCatTiposServicios]','[ELE].[spBorrarCatTipoServicio]','DELETE','',@OldJSON


   BEGIN TRY  
	  Delete ELE.[tblCatTiposServicios] 
	WHERE IDTipoServicio = @IDTipoServicio
	  
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO
