USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ELE].[spBorrarServicioEmpleado]-- 2,1
(
	@IDServicioEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	
	
    DECLARE @OldJSON Varchar(Max),
    @NewJSON Varchar(Max)

    select @OldJSON = a.JSON from [RH].[tblCatClientes] b
    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
    WHERE b.IDCliente = @IDServicioEmpleado

    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblServicioEmpleados]','[ELE].[spBorrarServicioEmpleado]','DELETE','',@OldJSON


   BEGIN TRY  
	  Delete ELE.[tblServicioEmpleados] 
	    WHERE IDServicioEmpleado = @IDServicioEmpleado
	  
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO
