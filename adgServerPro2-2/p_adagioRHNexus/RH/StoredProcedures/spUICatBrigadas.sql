USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar las Brigadas>
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

CREATE PROCEDURE [RH].[spUICatBrigadas]
(
	@IDBrigada int = 0,
	@Descripcion Varchar(MAX),
	@IDUsuario int
)
AS
BEGIN
	set @Descripcion = UPPER(@Descripcion)

	 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF(@IDBrigada = 0)
	BEGIN
		INSERT INTO RH.tblCatBrigadas(Descripcion)
		VALUES(@Descripcion)
		
		SET @IDBrigada = @@IDENTITY

		
		select @NewJSON = a.JSON from [RH].[tblCatBrigadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBrigada = @IDBrigada

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBrigadas]','[RH].[spUICatBrigadas]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN

		
		select @OldJSON = a.JSON from [RH].[tblCatBrigadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBrigada = @IDBrigada

		UPDATE RH.tblCatBrigadas
			set Descripcion = @Descripcion
		Where IDBrigada = @IDBrigada

		
		select @NewJSON = a.JSON from [RH].[tblCatBrigadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBrigada = @IDBrigada

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBrigadas]','[RH].[spUICatBrigadas]','UPDATE',@NewJSON,@OldJSON
	END
	
	SELECT IDBrigada,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDBrigada)as ROWNUMBER
	FROM RH.tblCatBrigadas
	Where IDBrigada = @IDBrigada
END
GO
