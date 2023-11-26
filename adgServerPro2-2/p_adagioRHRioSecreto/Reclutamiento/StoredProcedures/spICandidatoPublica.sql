USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Reclutamiento].[spICandidatoPublica](
	@IDPlaza int
	,@Nombre varchar(50) 
	,@SegundoNombre varchar(50)
	,@Paterno varchar(50)
	,@Materno varchar(50)
	,@Sexo  char(1)
	,@FechaNacimiento date
	,@CorreoElectronico varchar(50)
	,@Password Varchar(50)
	,@IDEmpleado int = null
)
AS  
BEGIN  

	DECLARE 
		@IDCandidato int,
		@IDUsuario int,
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@FechaAplicacion date = getdate(),
		@IDTipoContactoEmail int
	;

	select @IDUsuario=cast(Valor as int)  from App.tblConfiguracionesGenerales where IDConfiguracion='IDUsuarioAdmin'
	select top 1 @IDTipoContactoEmail=IDTipoContacto from RH.tblCatTipoContactoEmpleado where IDMedioNotificacion='Email'

	/*Datos De Candidato*/
	INSERT INTO [Reclutamiento].[tblCandidatos]([Nombre],[SegundoNombre],[Paterno],[Materno],[Sexo],[FechaNacimiento],[Email],[Password],[IDEmpleado])
	VALUES(
		UPPER(@Nombre) 
		,UPPER(@SegundoNombre)
		,UPPER(@Paterno)
		,UPPER(@Materno)
		,@Sexo 
		,@FechaNacimiento 
		,@CorreoElectronico
		,@Password
		,CASE WHEN ISNULL(@IDEmpleado,0) = 0 THEN NULL ELSE @IDEmpleado END
	)	

	SET @IDCandidato = @@IDENTITY  

	/*Datos De Vacante Deseada*/
	IF(ISNULL(@IDPlaza,0) > 0)
	BEGIN
		EXEC [Reclutamiento].[spUICandidatoPlaza]
			@IDCandidatoPlaza = 0,
			@IDCandidato = @IDCandidato,
			@IDPlaza = @IDPlaza,
			@IDProceso= null,
			@SueldoDeseado= 0,
			@IDUsuario = @IDUsuario
	END

	/*Correo Electronico*/
	if(isnull(@CorreoElectronico, '') != '')
	BEGIN
		INSERT INTO [Reclutamiento].[tblContactoCandidato]([IDCandidato],[IDTipoContacto],[Value],[Predeterminado])
		VALUES(@IDCandidato,@IDTipoContactoEmail,@CorreoElectronico,0)
	END
END
GO
