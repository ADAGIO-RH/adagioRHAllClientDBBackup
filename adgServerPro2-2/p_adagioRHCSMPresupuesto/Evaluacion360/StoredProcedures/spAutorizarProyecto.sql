USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Autoriza un proyecto y envio notificaciones a los evaluadores.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-25			Aneudy Abreu	Se corregió el bug que enviaba la activación de la cuenta del 
									empleado al evaluador.
2021-07-08			Aneudy Abreu	Se modificó el Subject de los correos
2023-08-17			Aneudy Abreu	Cambios para personalizar las notificaciones de Clima Laboral
***************************************************************************************************/
-- Catálogo de KEY para los Emails:
/*
	* Información Colaboradores y Evaluadores
	NombreColaborador			: Hace referencia al nombre de quién será evaluado.
	NombreEvaluador				: Hace referencia al nombre del evaluador de la prueba.
	RazonSocialEmpleado			: Hace referencia a la empresa que pertenece el colaborador

	* Información de Contactos, Administradores y Auditores del proyecto
	AdministradorProyecto			: Hace referencia al Nombre e Email de la persona que administra el proyecto
	AuditorProyecto					: Hace referencia al Nombre e Email de la persona que audita el proyecto
	ContactoProyecto				: Hace referencia al Nombre e Email de la persona que tendrá la contacto directo con los colaboradores en el proyecto

	* Información del proyecto
	FechaLimitePrueba			: Hace referencia a la fecha máxima que tendrá disponible el Colaborador/Evaluador para responder la prueba.
	LinkPrueba					: Hace referencia al enlace directo para responder la prueba 

*/
 
-- [Evaluacion360].[spAutorizarProyecto] 142,1
CREATE PROC [Evaluacion360].[spAutorizarProyecto](
	 @IDProyecto int
	 ,@IDUsuario int
) as
	declare 
		@OldJSON	varchar(Max) = ''
		,@NewJSON	varchar(Max)
		,@NombreSP	varchar(max) = '[Evaluacion360].[spAutorizarProyecto]'
		,@Tabla		varchar(max) = '[Evaluacion360].[tblEstatusProyectos]'
		,@Accion	varchar(20)	= 'AUTORIZANDO PRUEBA'
		,@Mensaje	varchar(max)
		,@InformacionExtra	varchar(max)
		,@NombrePrueba		varchar(max)
		,@IDTipoProyecto	 INT = 0
		,@IDTipoNotificacion varchar(50)
		,@ID_TIPO_PROYECTO_EVALUACION_DESEMPENIO INT = 2
		,@ID_TIPO_PROYECTO_CLIMA_LABORAL	INT = 3
		,@ID_TIPO_PROYECTO_ENCUESTA			INT = 4

		,@ID_TIPO_RELACION_AUTOEVALUACION	INT = 4
		
		,@IDEmpleadoProyecto		int = 0
		,@IDEvaluacionEmpleado		int = 0
		,@IDTipoRelacion			int = 0
		,@IDNotificacion			int = 0
		,@IDEmpleado				int = 0
		,@IDEvaluador				int = 0
		,@NombreColaborador			varchar(255)
		,@NombreEvaluador			varchar(255)	
		,@RazonSocialEmpleado		varchar(255)	
		,@NombreContactoProyecto	varchar(255)		
		,@EmailContactoProyecto		varchar(255)	
		,@FechaLimitePrueba			date
		,@SiteURL					varchar(max)	
		,@LinkPrueba				varchar(max)	
		,@Subject					varchar(100)

		,@EmailColaborador		varchar(1000)					 
		,@EmailEvaluador		varchar(1000)	

		,@AdministradorProyecto		varchar(255)
		,@AuditorProyecto			varchar(255)
		,@ContactoProyecto			varchar(255)

		,@IdiomaSQL varchar(100) = 'Spanish'	
		,@IDIdioma varchar(20)
		,@HTMLListOut varchar(max)
		,@xmlParametros varchar(max)		
		,@LabelBotton varchar(50) = ''

		,@UsuarioActivo bit = 0
		,@ActiveAccountUrl varchar(max)

		,@IDUsuarioActivar int = 0
		,@key varchar(max)
		,@cols AS NVARCHAR(MAX)
		,@query  AS NVARCHAR(MAX)
	;

	select @InformacionExtra = a.JSON 
	from (
		select IDProyecto
			, Nombre
			, Descripcion
			, FORMAT(isnull(FechaCreacion, GETDATE()),'dd/MM/yyyy') as FechaCreacion
			, Progreso
		from Evaluacion360.tblCatProyectos p with (nolock)
		where IDProyecto = @IDProyecto
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a

	select top 1 @SiteURL = valor 
	from App.tblConfiguracionesGenerales with (nolock)
	where IDConfiguracion = 'Url'

	select top 1 @ActiveAccountUrl = valor 
	from App.tblConfiguracionesGenerales with (nolock) 
	where IDConfiguracion = 'ActiveAccountUrl'

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
	SET LANGUAGE @IdiomaSQL;

	SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto
	set @IDTipoNotificacion = case 
								when @IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL then 'InvitacionRealizarClimaLaboral' 
								when @IDTipoProyecto = @ID_TIPO_PROYECTO_ENCUESTA then 'InvitacionRealizarEncuesta' 
							else 'InvitacionRealizarAutoevaluacion' end;
	
	set @Subject = case 
		when @IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL then '¡Comparte tu voz y mejora nuestro entorno laboral!' 
		when @IDTipoProyecto = @ID_TIPO_PROYECTO_ENCUESTA then 'Tu Voz Cuenta: Participa en la encuesta' 
	else 'Tu Voz Cuenta: Participa con tu Autoevaluación' end

	-- SI EL PROYECTO ES EVALUACION DE DESEMPEÑO NO EVALUA SI EXISTEN PREGUNTAS DIRECTAMENTE EN EL PROYECTO
	IF(@IDTipoProyecto != @ID_TIPO_PROYECTO_EVALUACION_DESEMPENIO)
	BEGIN
		-- Valida si exisiste preguntas en la prueba, si no existen entonces envia un mensaje de error!
		if not exists (select top 1 1 
						from Evaluacion360.tblCatGrupos cg with (nolock)
							join Evaluacion360.tblCatPreguntas cp with (nolock) on cg.IDGrupo = cp.IDGrupo
						where cg.TipoReferencia = 1 and cg.IDReferencia = @IDProyecto) 
		begin
			set @Mensaje = 'Agrega preguntas a la pruebas antes de autorizarla!'

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		= @IDUsuario
				,@Tabla			= @Tabla
				,@Procedimiento	= @NombreSP
				,@Accion		= @Accion
				,@NewData		= @NewJSON
				,@OldData		= @OldJSON
				,@Mensaje		= @Mensaje
				,@InformacionExtra	= @InformacionExtra

			raiserror(@Mensaje,16,1);
			return;
		end;
	END

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra	= @InformacionExtra


	SELECT 
		@AdministradorProyecto	= CASE WHEN tep.IDCatalogoGeneral	= 1 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @AdministradorProyecto end
		,@AuditorProyecto		= CASE WHEN tep.IDCatalogoGeneral	= 2 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @AuditorProyecto end
		,@ContactoProyecto		= CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Nombre,'')+' ('+coalesce(tep.Email,'')+')' ELSE @ContactoProyecto end
		,@NombreContactoProyecto= CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Nombre,'') ELSE @NombreContactoProyecto end
		,@EmailContactoProyecto	= CASE WHEN tep.IDCatalogoGeneral	= 3 THEN coalesce(tep.Email,'') ELSE @EmailContactoProyecto end
	from [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
	WHERE tep.IDProyecto = @IDProyecto

	select 
		@NombrePrueba = Nombre,
		@FechaLimitePrueba = ISNULL(FechaFin, GETDATE())
 	from Evaluacion360.tblCatProyectos with (nolock)
	where IDProyecto = @IDProyecto

	if object_id('tempdb..#tempEmailEvaluadoresEnviados') is not null drop table #tempEmailEvaluadoresEnviados;

	create table #tempEmailEvaluadoresEnviados(
		IDEvaluador int  
	);

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	IF object_id('tempdb..#tempAutoEva') IS NOT NULL DROP TABLE #tempAutoEva;

	SELECT tep.IDEmpleadoProyecto
		,tee.IDEvaluacionEmpleado
		,tep.IDProyecto
		,tep.IDEmpleado
		,tem.ClaveEmpleado
		,tem.Nombre
		,tem.Nombre+' '+coalesce(tem.Paterno, '')+' '+coalesce(tem.Materno, '') AS NombreColaborador
		,tem.Empresa
		,temEva.Nombre+' '+coalesce(temEva.Paterno, '')+' '+coalesce(temEva.Materno, '') AS NombreEvaluador
		--,tuEmp.Email  as EmailColaborador	 
		--,tuEva.Email  as EmailEvaluador		 
		,tee.IDTipoRelacion
		,tee.IDEvaluador
		,'' AS LinkPrueba
	INTO #tempAutoEva
	FROM Evaluacion360.tblEmpleadosProyectos tep		with (nolock)
		JOIN Evaluacion360.tblEvaluacionesEmpleados tee with (nolock) ON tep.IDEmpleadoProyecto = tee.IDEmpleadoProyecto
		JOIN RH.tblEmpleadosMaster tem		with (nolock)	ON tep.IDEmpleado	= tem.IDEmpleado
		JOIN RH.tblEmpleadosMaster temEva	with (nolock)	ON tee.IDEvaluador	= temEva.IDEmpleado
		--LEFT JOIN Seguridad.tblUsuarios tuEmp with (nolock) ON tem.IDEmpleado	= tuEmp.IDEmpleado 
		--LEFT JOIN Seguridad.tblUsuarios tuEva with (nolock) ON temEva.IDEmpleado = tuEva.IDEmpleado 
	WHERE tep.IDProyecto = @IDProyecto --AND tee.IDTipoRelacion = 4

	print 'Notificación: Invitación a realizar la autoevaluación'
	
	SELECT @IDEvaluacionEmpleado = min(tae.IDEvaluacionEmpleado) FROM #tempAutoEva tae

	WHILE exists(SELECT TOP 1 1 FROM #tempAutoEva tae WHERE tae.IDEvaluacionEmpleado >= @IDEvaluacionEmpleado)
	BEGIN
		SELECT 
			 @NombreColaborador			= tae.Nombre
			,@IDEmpleado				= tae.IDEmpleado
			,@RazonSocialEmpleado		= tae.Empresa				
			,@IDEvaluador				= tae.IDEvaluador
			,@NombreEvaluador			= tae.NombreEvaluador
			,@IDTipoRelacion			= tae.IDTipoRelacion
			
			--,@EmailColaborador			= tae.EmailColaborador
			--,@EmailEvaluador			= tae.EmailEvaluador

		--	,@FechaLimitePrueba			= getdate()
			,@LabelBotton				= 'Ir a la evaluación'
		--	,@LinkPrueba				= tae.LinkPrueba	
		from #tempAutoEva tae
		where tae.IDEvaluacionEmpleado = @IDEvaluacionEmpleado;

		-- Se valida si el colaborador está Activo y su usuairo no se encuentr activo.
		if exists(select top 1 1 
					from Seguridad.tblUsuarios u with (nolock) 
						join RH.tblEmpleadosMaster e on u.IDEmpleado = e.IDEmpleado
					where u.IDEmpleado = @IDEvaluador and isnull(u.Activo,cast(0 as bit)) = 0 and isnull(e.Vigente,cast(0 as bit)) = 1) 
 		begin

			set @key = REPLACE(NEWID(),'-','')+''+REPLACE(NEWID(),'-','');

			select top 1 @IDUsuarioActivar = IDUsuario
			from Seguridad.tblUsuarios with (nolock) 
			where IDEmpleado = @IDEvaluador

			insert [Seguridad].TblUsuariosKeysActivacion(IDUsuario,ActivationKey,AvaibleUntil,Activo)
			select @IDUsuarioActivar,@key,dateadd(day,30,getdate()),1

			select 
				@LabelBotton = case when @IDTipoRelacion <> @ID_TIPO_RELACION_AUTOEVALUACION then 'Activa tu cuenta y realiza la evaluación' else  'Activa tu cuenta y realiza tu Auto Evaluación' end
				,@LinkPrueba = @ActiveAccountUrl+@key

		end 
		else
		begin
			select 
				@LabelBotton = case when @IDTipoRelacion <> @ID_TIPO_RELACION_AUTOEVALUACION then 'Realiza la evaluación' else  'Completa la encuesta aquí' end
				,@LinkPrueba = @SiteURL
		end;

		delete from #tempParams;

		insert #tempParams(Variable, Valor)
		values
				('NombreEvaluador',coalesce(@NombreEvaluador,''))
				,('RazonSocialEmpleado',coalesce(@RazonSocialEmpleado,''))
				,('AdministradorProyecto',coalesce(@AdministradorProyecto,''))
				,('ContactoProyecto',coalesce(@ContactoProyecto,''))
				,('NombreContactoProyecto',coalesce(@NombreContactoProyecto,''))
				,('EmailContactoProyecto',coalesce(@EmailContactoProyecto,''))
				,('AuditorProyecto',coalesce(@AuditorProyecto,''))
				,('FechaLimitePrueba',FORMAT(@FechaLimitePrueba, 'dd MMMM yyyy')) 
				--,('FechaLimitePrueba',convert(varchar(11), @FechaLimitePrueba,100))
				,('LinkPrueba',coalesce(@LinkPrueba,''))
				,('NombreEmpresa',coalesce(@RazonSocialEmpleado,''))
				,('LabelBotton',coalesce(@LabelBotton,''))

		IF (@IDTipoRelacion <> @ID_TIPO_RELACION_AUTOEVALUACION)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 
							FROM #tempEmailEvaluadoresEnviados 
							WHERE #tempEmailEvaluadoresEnviados.IDEvaluador = @IDEvaluador)
			BEGIN
				set @HTMLListOut  = '<ul class=''leaders''>'

				select @HTMLListOut = @HTMLListOut + '<li>'+ NombreColaborador +'</li>'
				FROM #tempAutoEva
				where IDEvaluador = @IDEvaluador AND #tempAutoEva.IDTipoRelacion <> 4

				set @HTMLListOut = @HTMLListOut+'</ul>'
			
				insert #tempParams(Variable, Valor)
				Values('ListadoPersonasPorEvaluar',coalesce(@HTMLListOut,''))
						,('Subject',@Subject+' - '+coalesce(@NombrePrueba,''))
			 
				INSERT #tempEmailEvaluadoresEnviados(IDEvaluador)
				values(@IDEvaluador)

				--set @xmlParametros = (select * 
				--	from #tempParams
				--	FOR XML path, ROOT
				--	);
				
				IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
				SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
							FROM #tempParams c
							FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)') 
						,1,1,'')

				set @query = 'SELECT  ' + @cols + ' 
							into ##tempParamsPivot
							from (
								select Variable
									,Valor
								from #tempParams
							) x
							pivot 
							(
								max(Valor)
								for Variable in (' + @cols + ')
							) p '

				execute(@query)

				select @xmlParametros = a.JSON from ##tempParamsPivot b
					Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a


                select @EmailEvaluador= [Utilerias].[fnGetCorreoEmpleado] (@IDEvaluador,0,'InvitacionRealizarEvaluaciones')

				if (len(coalesce(@EmailEvaluador,'')) > 0)
				begin
					insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros, IDIdioma)  
					select 'InvitacionRealizarEvaluaciones',@xmlParametros, @IDIdioma
			
					set @IDNotificacion = @@IDENTITY;

					insert [App].[tblEnviarNotificacionA](  
							IDNotifiacion  
							,IDMedioNotificacion  
							,Destinatario)  
					select @IDNotificacion  
						,templateNot.IDMedioNotificacion  
						,case when templateNot.IDMedioNotificacion = 'Email' then @EmailEvaluador else null end  
					from [App].[tblTiposNotificaciones] tn with (nolock)  
						join [App].[tblTemplateNotificaciones] templateNot with (nolock) on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
							and isnull(templateNot.IDIdioma,'es-MX') = @IDIdioma
					where tn.IDTipoNotificacion = 'InvitacionRealizarEvaluaciones' 
				end;
			END
		END else 
		BEGIN
			IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
			insert #tempParams(Variable, Valor)
			values('Subject',@Subject+' - '+coalesce(@NombrePrueba,''))

			SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
						FROM #tempParams c
						FOR XML PATH(''), TYPE
						).value('.', 'NVARCHAR(MAX)') 
					,1,1,'')

			set @query = 'SELECT  ' + @cols + ' 
							into ##tempParamsPivot
							from (
								select Variable
									, Valor
								from #tempParams
							) x
							pivot 
							(
								max(Valor)
								for Variable in (' + @cols + ')
							) p '

			execute(@query)

			select @xmlParametros = a.JSON from ##tempParamsPivot b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			
            select @EmailColaborador= [Utilerias].[fnGetCorreoEmpleado] (@IDEmpleado,0, @IDTipoNotificacion)

			if (len(coalesce(@EmailColaborador,'')) > 0)							
			begin
				insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros, IDIdioma)  
				select @IDTipoNotificacion,@xmlParametros,@IDIdioma
			
				set @IDNotificacion = @@IDENTITY  ;

				insert [App].[tblEnviarNotificacionA](  
						IDNotifiacion  
						,IDMedioNotificacion  
						,Destinatario)  
				select @IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,case when templateNot.IDMedioNotificacion = 'Email' then @EmailColaborador else null end  
				from [App].[tblTiposNotificaciones] tn with (nolock)  
					join [App].[tblTemplateNotificaciones] templateNot with (nolock) on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
						and isnull(templateNot.IDIdioma,'es-MX') = @IDIdioma
				where tn.IDTipoNotificacion = @IDTipoNotificacion
			end;
		END;

		--	-- Validamos si tiene email el colaborador
		--IF (len(coalesce(@Email,'')) > 0)
		--BEGIN
		--END ELSE 
		--BEGIN
		--	PRINT 'El colaborador no tiene email'
		--end;

		SELECT @IDEvaluacionEmpleado = min(tae.IDEvaluacionEmpleado) FROM #tempAutoEva tae WHERE tae.IDEvaluacionEmpleado > @IDEvaluacionEmpleado
	END;

--SELECT * FROM #tempAutoEva
-- Notificación: Invitación a realizar las Demás tipos de pruebas:
GO
