USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [RH].[spIUCatClasificacionesCorporativas]  
(  
 @IDClasificacionCorporativa int = 0,  
 @Codigo varchar(25) = null,  
 @Descripcion varchar(50) = null,  
 @CuentaContable varchar(25) = null,  
 @IDUsuario int,
 @Traduccion nvarchar(max)  
)  
AS  
BEGIN  
  
 SET @Codigo         = UPPER(@Codigo)  
 SET @Descripcion = UPPER(@Descripcion)  
 SET @CuentaContable = UPPER(@CuentaContable)  
  

  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

 IF(@IDClasificacionCorporativa = 0 or @IDClasificacionCorporativa is null)  
 BEGIN  
  IF EXISTS(Select Top 1 1 from RH.tblCatClasificacionesCorporativas where Codigo = @Codigo)  
  BEGIN  
   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
   RETURN 0;  
  END  
  
  INSERT INTO RH.tblCatClasificacionesCorporativas  
   (  
   [Codigo]  
   ,[Descripcion]  
   ,[CuentaContable]  
   ,[Traduccion]
   )  
  VALUES(  
   @Codigo  
   ,@Descripcion  
   ,@CuentaContable  
   ,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
   )  
     
   set @IDClasificacionCorporativa = @@IDENTITY  

   	select @NewJSON = a.JSON from [RH].[tblCatClasificacionesCorporativas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClasificacionCorporativa=@IDClasificacionCorporativa;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatClasificacionesCorporativas]','[RH].[spIUCatClasificacionesCorporativas]','INSERT',@NewJSON,''
  
   Select   
    IDClasificacionCorporativa  
    ,Codigo  
    ,Descripcion  
    ,CuentaContable  
	,[Traduccion]
    ,ROW_NUMBER()over(ORDER BY IDClasificacionCorporativa)as ROWNUMBER  
   FROM RH.tblCatClasificacionesCorporativas  
   Where IDClasificacionCorporativa = @IDClasificacionCorporativa  
 END  
 ELSE  
 BEGIN  
    IF EXISTS(Select Top 1 1 from RH.tblCatClasificacionesCorporativas where Codigo = @Codigo and IDClasificacionCorporativa <> @IDClasificacionCorporativa)   
  BEGIN  
   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
   RETURN 0;  
  END  

   	select @OldJSON = a.JSON from [RH].[tblCatClasificacionesCorporativas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClasificacionCorporativa=@IDClasificacionCorporativa;

  
  UPDATE RH.tblCatClasificacionesCorporativas  
  set [Codigo] = @Codigo  
   ,[Descripcion] = @Descripcion  
   ,[CuentaContable] = @CuentaContable  
   ,[Traduccion] = case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
   
  Where IDClasificacionCorporativa = @IDClasificacionCorporativa  
     
	 
   		select @NewJSON = a.JSON from [RH].[tblCatClasificacionesCorporativas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDClasificacionCorporativa=@IDClasificacionCorporativa;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatClasificacionesCorporativas]','[RH].[spIUCatClasificacionesCorporativas]','UPDATE',@NewJSON,@OldJSON



   Select   
    IDClasificacionCorporativa  
    ,Codigo  
    ,Descripcion  
    ,CuentaContable 
	,Traduccion
    ,ROW_NUMBER()over(ORDER BY IDClasificacionCorporativa)as ROWNUMBER  
   FROM RH.tblCatClasificacionesCorporativas  
   Where IDClasificacionCorporativa = @IDClasificacionCorporativa  
 END  


 EXEC [Seguridad].[spIUFiltrosUsuarios] 
	 @IDFiltrosUsuarios  = 0  
	 ,@IDUsuario  = @IDUsuario   
	 ,@Filtro = 'ClasificacionesCorporativas'  
	 ,@ID = @IDClasificacionCorporativa   
	 ,@Descripcion = @Descripcion
	 ,@IDUsuarioLogin = @IDUsuario 

 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO
