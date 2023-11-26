USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spAltaEmpleadoWizard]  
(  
 @IDUsuario int  
 ,@ClaveEmpleado varchar(20)  
 ,@RFC varchar(20) = null  
 ,@CURP varchar(20) = null  
 ,@IMSS varchar(20) = null  
 ,@Nombre varchar(50)  
 ,@SegundoNombre varchar(50) = null  
 ,@Paterno varchar(50) = null  
 ,@Materno varchar(50) = null  
 ,@IDLocalidadNacimiento int  
 ,@IDMunicipioNacimiento int  =null
 ,@IDEstadoNacimiento int  
 ,@IDPaisNacimiento int  
 ,@LocalidadNacimiento Varchar(100) = null  
 ,@MunicipioNacimiento Varchar(100) = null  
 ,@EstadoNacimiento Varchar(100) = null  
 ,@PaisNacimiento Varchar(100) = null  
 ,@FechaNacimiento datetime  
 ,@IDEstadoCivil int  
 ,@Sexo varchar(1)  
 ,@IDEscolaridad int = null  
 ,@DescripcionEscolaridad varchar(max) = null  
 ,@IDInstitucion int  = null  
 ,@IDProbatorio int = null  
 ,@FechaPrimerIngreso date = null  
 ,@FechaIngreso date  
 ,@FechaAntiguedad date = null  
 ,@Sindicalizado bit = 0  
 ,@IDJornadaLaboral int = null  
 ,@UMF varchar(10) = null  
 ,@CuentaContable varchar(50) = null  
 ,@IDTipoRegimen int = null  
 ,@IDRegimenFiscal int = null  
 ,@IDCandidatoPlaza int = 0
 ,@IDEmpleado int OUTPUT  
)  
AS  
BEGIN  
	declare
		@IDUsuarioAdmin int   
	;

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);


	Select top 1 @IDUsuarioAdmin = cast(Valor as int) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'    
	
	IF EXISTS (select 1 from RH.tblEmpleados where ClaveEmpleado = @ClaveEmpleado)  
	BEGIN  
		EXEC [app].[spObtenerError] @IDUsuario, '0000004'  
		RETURN;  
	END  
  --select case when @IDTipoRegimen = 0 then null else @IDTipoRegimen end
	INSERT INTO  RH.tblEmpleados  
	(  
		ClaveEmpleado  
		,RFC  
		,CURP  
		,IMSS  
		,Nombre  
		,SegundoNombre  
		,Paterno  
		,Materno  
		,IDLocalidadNacimiento  
		,IDMunicipioNacimiento  
		,IDEstadoNacimiento  
		,IDPaisNacimiento  
		,LocalidadNacimiento  
		,MunicipioNacimiento  
		,EstadoNacimiento  
		,PaisNacimiento  
		,FechaNacimiento  
		,IDEstadoCivil  
		,Sexo  
		,IDEscolaridad  
		,DescripcionEscolaridad  
		,IDInstitucion  
		,IDProbatorio  
		,FechaPrimerIngreso  
		,FechaIngreso  
		,FechaAntiguedad  
		,Sindicalizado  
		,IDJornadaLaboral  
		,UMF  
		,CuentaContable  
		,IDTipoRegimen 
		,IDRegimenFiscal 
		,RequiereChecar
		,PermiteChecar 
	)  
	VALUES(  
		@ClaveEmpleado  
		,@RFC  
		,@CURP  
		,@IMSS  
		,rtrim(ltrim(UPPER(@Nombre)))
		,rtrim(ltrim(UPPER(@SegundoNombre)))  
		,rtrim(ltrim(UPPER(@Paterno)))  
		,rtrim(ltrim(UPPER(@Materno)))  
		,case when @IDLocalidadNacimiento = 0 then null else @IDLocalidadNacimiento end  
		,case when @IDMunicipioNacimiento = 0 or @IDMunicipioNacimiento is  null then null else @IDMunicipioNacimiento end  
		,case when @IDEstadoNacimiento = 0 then null else @IDEstadoNacimiento end  
		,case when @IDPaisNacimiento = 0 then null else @IDPaisNacimiento end  
		,@LocalidadNacimiento  
		,@MunicipioNacimiento  
		,@EstadoNacimiento  
		,@PaisNacimiento  
		,@FechaNacimiento  
		,@IDEstadoCivil  
		,@Sexo  
		,case when @IDEscolaridad = 0 then null else @IDEscolaridad end  
		,@DescripcionEscolaridad  
		,case when @IDInstitucion = 0 then null else @IDInstitucion end  
		,case when @IDProbatorio = 0 then null else @IDProbatorio end  
		,CASE WHEN @FechaPrimerIngreso IS NULL THEN @FechaIngreso ELSE @FechaPrimerIngreso END  
		,@FechaIngreso  
		,CASE WHEN @FechaAntiguedad IS NULL THEN @FechaIngreso ELSE @FechaAntiguedad END  
		,@Sindicalizado  
		,case when @IDJornadaLaboral = 0 then null else @IDJornadaLaboral end  
		,@UMF  
		,@CuentaContable  
		,case when @IDTipoRegimen = 0 then null else @IDTipoRegimen end  
		,case when @IDRegimenFiscal = 0 then null else @IDRegimenFiscal end  
		,1 --RequiereChecar
		,1 --PermiteChecar 
	)  
  
	set @IDEmpleado = @@IDENTITY  

		 select @NewJSON = a.JSON from [RH].[tblEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  IDEmpleado = @IDEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblEmpleados]','[RH].[spAltaEmpleadoWizard]','Alta de Empleado - INSERT',@NewJSON,''
	--if (@IDUsuario != @IDUsuarioAdmin)
	--begin
	--	insert into Seguridad.tblDetalleFiltrosEmpleadosUsuarios(IDUsuario, IDEmpleado, Filtro, ValorFiltro,IDCatFiltroUsuario)
	--	values
	--		(@IDUsuario,@IDEmpleado,'Empleados','Empleados | '+UPPER(coalesce(@Nombre,''))+' '+UPPER(coalesce(@SegundoNombre,''))+' '+UPPER(coalesce(@Paterno,''))+' '+UPPER(coalesce(@Materno,'')),null)
	--		,(@IDUsuarioAdmin,@IDEmpleado,'Empleados','Empleados | '+UPPER(coalesce(@Nombre,''))+' '+UPPER(coalesce(@SegundoNombre,''))+' '+UPPER(coalesce(@Paterno,''))+' '+UPPER(coalesce(@Materno,'')),null)
	--end else 
	--begin
	--	insert into Seguridad.tblDetalleFiltrosEmpleadosUsuarios(IDUsuario, IDEmpleado, Filtro, ValorFiltro,IDCatFiltroUsuario)
	--	values
	--		(@IDUsuario,@IDEmpleado,'Empleados','Empleados | '+UPPER(coalesce(@Nombre,''))+' '+UPPER(coalesce(@SegundoNombre,''))+' '+UPPER(coalesce(@Paterno,''))+' '+UPPER(coalesce(@Materno,'')),null)
	--end;

	insert into Seguridad.tblDetalleFiltrosEmpleadosUsuarios(IDUsuario, IDEmpleado, Filtro, ValorFiltro,IDCatFiltroUsuario)
	select u.IDUsuario,@IDEmpleado ,'Empleados','Empleados | '+UPPER(coalesce(@Nombre,''))+' '+UPPER(coalesce(@SegundoNombre,''))+' '+UPPER(coalesce(@Paterno,''))+' '+UPPER(coalesce(@Materno,'')),0
	from Seguridad.tblUsuarios u
		inner join Seguridad.tblCatPerfiles p
			on u.IDPerfil = p.IDPerfil
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios eu
			on eu.IDEmpleado = @IDEmpleado
			and u.IDUsuario = eu.IDUsuario
	where p.Descripcion <> 'EMPLEADOS'
	and eu.IDDetalleFiltrosEmpleadosUsuarios is null

    EXEC [Scheduler].[spSchedulerNotificacionEspecial_NuevoColaborador]   
    @IDEmpleado =@IDEmpleado

	IF(isnull(@IDCandidatoPlaza,0) > 0)
	BEGIN
		DECLARE @IDCandidato int;

		SELECT @IDCandidato = IDCandidato 
		FROM Reclutamiento.tblCandidatoPlaza with(nolock) 
		WHERE IDCandidatoPlaza = @IDCandidatoPlaza

		UPDATE Reclutamiento.tblCandidatos
			SET IDEmpleado = @IDEmpleado
		WHERE IDCandidato = @IDCandidato
	END


	--declare @tran int 

	--set @tran = @@TRANCOUNT

	--if(@tran = 0)
	--BEGIN
	--	exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
	--END
END
GO
