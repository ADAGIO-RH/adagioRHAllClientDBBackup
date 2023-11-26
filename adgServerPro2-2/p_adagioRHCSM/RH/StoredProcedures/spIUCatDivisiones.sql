USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatDivisiones]
(
	@IDDivision int = 0,
	@Codigo varchar(25) = null,
	@Descripcion varchar(50) = null,
	@CuentaContable varchar(25) = null,
	@IDEmpleado int = 0,
	@JefeDivision varchar(100) = null,
	@IDUsuario int
)
AS
BEGIN

	SET @Codigo				= UPPER(@Codigo			)
	SET @Descripcion 		= UPPER(@Descripcion 	)
	SET @CuentaContable 	= UPPER(@CuentaContable )
	SET @JefeDivision 	= UPPER(@JefeDivision)

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


	IF(@IDDivision = 0 or @IDDivision is null)
	BEGIN
	     IF EXISTS(Select Top 1 1 from RH.tblcatDivisiones where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO RH.tblcatDivisiones
			(
			[Codigo]
			,[Descripcion]
			,[CuentaContable]
			,[IDEmpleado]
			,[JefeDivision])
		VALUES(
			@Codigo
			,@Descripcion
			,@CuentaContable
			,CASE WHEN @IDEmpleado = 0 THEN null ELSE @IDEmpleado END
			,@JefeDivision
			)
			
			set @IDDivision = @@IDENTITY

			Select 
				IDDivision
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,JefeDivision
				,ROW_NUMBER()over(ORDER BY IDDivision)as ROWNUMBER
			FROM RH.tblCatDivisiones
			Where IDDivision = @IDDivision

		select @NewJSON = a.JSON from [RH].[tblCatDivisiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDivision = @IDDivision

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDivisiones]','[RH].[spIUCatDivisiones]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		  IF EXISTS(Select Top 1 1 from RH.tblcatDivisiones where Codigo = @Codigo and IDDivision <> @IDDivision)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
		select @OldJSON = a.JSON from [RH].[tblCatDivisiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDivision = @IDDivision

		UPDATE RH.tblCatDivisiones
		set [Codigo] = @Codigo
			,[Descripcion] = @Descripcion
			,[CuentaContable] = @CuentaContable
			,[IDEmpleado] = case when @IDEmpleado = 0 then null else @IDEmpleado end
			,[JefeDivision] = @JefeDivision
		Where IDDivision = @IDDivision
			
			Select 
				IDDivision
				,Codigo
				,Descripcion
				,CuentaContable
				,isnull(IDEmpleado,0) as IDEmpleado
				,JefeDivision
				,ROW_NUMBER()over(ORDER BY IDDivision)as ROWNUMBER
			FROM RH.tblCatDivisiones
			Where IDDivision = @IDDivision

		select @NewJSON = a.JSON from [RH].[tblCatDivisiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDivision = @IDDivision

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDivisiones]','[RH].[spIUCatDivisiones]','UPDATE',@NewJSON,@OldJSON
	END

	 EXEC [Seguridad].[spIUFiltrosUsuarios] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'Divisiones'  
	 ,@ID = @IDDivision   
	 ,@Descripcion = @Descripcion
	 ,@IDUsuarioLogin = @IDUsuario 

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO
