USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar el Catálogo de Rutas de Transporte>
** Autor			: <Jose Rafael Roman Gil>
** Email			: <jose.roman@adagio.com.mx>
** FechaCreacion	: <08/06/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [RH].[spUICatRutasTransporte]
(
	@IDRuta int = 0,
	@Descripcion Varchar(MAX),
	@IDUsuario int
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)


	IF(@IDRuta = 0)
	BEGIN
		INSERT INTO RH.tblCatRutasTransporte(Descripcion)
		VALUES(@Descripcion)
		
		SET @IDRuta = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatRutasTransporte] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRuta = @IDRuta
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRutasTransporte]','[RH].[spUICatRutasTransporte]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [RH].[tblCatRutasTransporte] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRuta = @IDRuta

		UPDATE RH.tblCatRutasTransporte
			set Descripcion = @Descripcion
		Where IDRuta = @IDRuta

		select @NewJSON = a.JSON from [RH].[tblCatRutasTransporte] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRuta = @IDRuta
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRutasTransporte]','[RH].[spUICatRutasTransporte]','UPDATE',@NewJSON,@OldJSON
	END
	
	SELECT IDRuta,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDRuta)as ROWNUMBER
	FROM RH.tblCatRutasTransporte
	Where IDRuta = @IDRuta
END
GO
