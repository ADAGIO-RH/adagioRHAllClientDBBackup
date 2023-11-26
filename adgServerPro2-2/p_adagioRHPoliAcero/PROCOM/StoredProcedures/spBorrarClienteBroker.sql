USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBorrarClienteBroker(
	@IDClienteBroker int,
	@IDUsuario int
)
AS
BEGIN
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Procom].[tblClienteBrokers] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDClienteBroker = @IDClienteBroker

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[tblClienteBrokers]','[Procom].[spBorrarClienteBroker]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
		  DELETE [Procom].[tblClienteBrokers]
			WHERE IDClienteBroker = @IDClienteBroker

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
