USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[INotificacionSolicitudIntranet](  
	@IDSolicitud int    
	,@TipoCambio Varchar(50)
) as  
	declare   
		@IDNotificacion int = 0  
		,@IDTipoNotificacion varchar(100) = 'SolicitudIntranet'  
		,@ClaveEmpleado  varchar(50)  
		,@Nombre  varchar(255)    
		,@SegundoNombre  varchar(255)    
		,@Paterno  varchar(255)    
		,@Materno  varchar(255)    
		,@Email   varchar(255)  
		,@Fecha date  
		,@Fechaini date  
		,@FechaFin date  
		,@valor varchar(max)
		,@Folio Varchar(50)
		,@TipoSolicitud Varchar(50)
		,@EstatusSolicitud Varchar(50)
		,@IDIncidencia Varchar(10)
		,@UsuarioAutoriza Varchar(100)
		,@CantidadDias int
		,@IDEmpleado int
		,@IDIdioma varchar(10)
		,@CreateSupervisorMensaje	varchar(100)
		,@CreateUsuarioMensaje		varchar(100)
		,@UpdateSupervisorMensaje	varchar(100)
		,@UpdateUsuarioMensaje		varchar(100)
		,@AprobadaMensaje	varchar(100)
		,@RechazadaMensaje	varchar(100)
		--,@Folio		varchar(100)
		,@Tipo		varchar(100)
		,@Estatus		varchar(100)
		--,@Fecha		varchar(100)
		,@FavorRevisar varchar(100)
		,@Confirmar	varchar(100)
		,@json nvarchar(max)
		,@notificaciones nvarchar(max) = N'
		{
			"esmx": {
				"Create": {
					"Supervisor": "Se ha generado una solicitud de Intranet por parte de ",
					"Usuario": "Se ha creado tu solicitud de Intranet."
				},
				"Update": {
					"Supervisor": "Se ha Modificado la solicitud de Intranet por parte de ",
					"Usuario": "Has Modificado tu solicitud de Intranet"
				},
				"Aprobada": "La solicitud de Intranet fue APROBADA",
				"Rechazada": "La solicitud de Intranet fue RECHAZADA",
				"Folio": "Folio",
				"Tipo": "Tipo",
				"Estatus": "Estatus",
				"Fecha": "Fecha",
				"FavorRevisar": "Favor de revisar.",
				"Confirmar": "No es necesario confirmar de recibido."
			},
			"enus": {
				"Create": {
					"Supervisor": "An intranet request has been generated by ",
					"Usuario": "Your intranet request has been created."
				},
				"Update": {
					"Supervisor": "Modified Intranet request by ",
					"Usuario": "You have modified your Intranet request"
				},
				"Aprobada": "Intranet request was APPROVED",
				"Rechazada": "Intranet request was REJECTED",
				"Folio": "Invoice",
				"Tipo": "Type",
				"Estatus": "Status",
				"Fecha": "Date",
				"FavorRevisar": "Please check.",
				"Confirmar": "It is not necessary to confirm receipt."
			}
		}
	'

	if object_id('tempdb..#tempParams') is not null drop table #tempParams;

	create table #tempParams(
		ID int identity(1,1) not null,
		Variable varchar(max),
		Valor varchar(max)
	);

	select top 1 
		@IDIdioma=App.fnGetPreferencia('Idioma', u.IDUsuario, 'es-MX')
	from Intranet.tblSolicitudesEmpleado SE
		join Seguridad.tblUsuarios u on u.IDEmpleado = SE.IDEmpleado
	WHERE SE.IDSolicitud = @IDSolicitud

	select 
		@IDEmpleado		= SE.IDEmpleado 
		,@ClaveEmpleado = m.ClaveEmpleado
		,@Nombre		= m.Nombre
		,@SegundoNombre = m.SegundoNombre
		,@Paterno		= m.Paterno
		,@Materno		= m.Materno
		,@Fecha		= SE.FechaCreacion
		,@Fechaini	= SE.FechaIni
		,@Folio		= 'S'+cast(IDSolicitud as Varchar(10))
		,@TipoSolicitud		= JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
		,@EstatusSolicitud	= JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
		,@IDIncidencia		= I.Descripcion
		,@UsuarioAutoriza	= coalesce(U.Nombre, '') +' '+ coalesce(U.Apellido, '')
	from Intranet.tblSolicitudesEmpleado SE with (nolock)
		inner join Intranet.tblCatEstatusSolicitudes ES on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		inner join Intranet.tblCatTipoSolicitud TS on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		inner join RH.tblEmpleadosMaster M with (nolock) on SE.IDEmpleado = m.IDEmpleado
		left join Asistencia.tblCatIncidencias I on SE.IDIncidencia = I.IDIncidencia
		left join Seguridad.tblUsuarios U on SE.IDUsuarioAutoriza = U.IDUsuario
		left join Seguridad.tblUsuarios UU on UU.IDEmpleado = SE.IDEmpleado
	WHERE SE.IDSolicitud = @IDSolicitud
	
	/*select top 1 
		@Email = ISNULL(CE.Value,U.Email)
	from APP.tblTiposNotificaciones TN
		inner join App.tblTemplateNotificaciones Template on TN.IDTipoNotificacion = Template.IDTipoNotificacion
		left join [RH].[tblContactosEmpleadosTiposNotificaciones] CETN on TN.IDTipoNotificacion = CETN.IDTipoNotificacion
				and CETN.IDEmpleado = @IDEmpleado
		left join RH.tblContactoEmpleado CE on CE.IDContactoEmpleado = CETN.IDContactoEmpleado
		left join Seguridad.tblUsuarios u  on U.IDEmpleado = @IDEmpleado
	WHERE TN.IDTipoNotificacion = @IDTipoNotificacion
		and Template.IDMedioNotificacion = 'EMAIL'*/

    SELECT @Email= [Utilerias].[fnGetCorreoEmpleado] (@IDEmpleado,0,@IDTipoNotificacion);

    
	select 
		@CreateSupervisorMensaje	= info.CreateSupervisor
		,@CreateUsuarioMensaje		= info.CreateUsuario
		,@UpdateSupervisorMensaje	= info.UpdateSupervisor
		,@UpdateUsuarioMensaje		= info.UpdateUsuario
		,@AprobadaMensaje		= info.Aprobada
		,@RechazadaMensaje	= info.Rechazada
		,@FavorRevisar	= info.FavorRevisar
		,@Confirmar		= info.Confirmar		
	from OPENJSON(@notificaciones, formatmessage('$.%s', lower(replace(@IDIdioma, '-',''))))
		WITH  (
			CreateSupervisor varchar(100) N'$.Create.Supervisor',
			UpdateSupervisor varchar(100) N'$.Update.Supervisor',
			CreateUsuario varchar(100) N'$.Create.Usuario',
			UpdateUsuario varchar(100) N'$.Update.Usuario',
			Aprobada	varchar(100) N'$.Aprobada',
			Rechazada	varchar(100) N'$.Rechazada',
			Folio		varchar(100) N'$.Folio',
			Tipo		varchar(100) N'$.Tipo',
			Estatus		varchar(100) N'$.Estatus',
			Fecha		varchar(100) N'$.Fecha',
			FavorRevisar varchar(100)N'$.FavorRevisar',
			Confirmar	varchar(100) N'$.Confirmar'
		) info

	insert #tempParams(Variable, Valor)
	values
		('NombreColaborador',coalesce(@Nombre,'')+' '+coalesce(@SegundoNombre,'') +' '+coalesce(@Paterno,'')+' '+coalesce(@Materno,''))
		,('ClaveColaborador',coalesce(@ClaveEmpleado,''))
		,('Folio',		isnull(@Folio,'')) 		
		,('Tipo',		isnull(@TipoSolicitud,'')) 		
		,('Estatus',	@EstatusSolicitud)	
		,('Fecha',		FORMAT(getdate(), 'd',  @IDIdioma )+' '+FORMAT(getdate(), 'HH:mm',  @IDIdioma)) 		
		,('Favor',		@FavorRevisar) 		
		,('confirmar',	@Confirmar) 	

	IF(@TipoCambio = 'CREATE-SUPERVISOR')
	BEGIN
		insert #tempParams(Variable, Valor)
		values('Mensaje', @CreateSupervisorMensaje) 
	END

	IF(@TipoCambio = 'UPDATE-SUPERVISOR')
	BEGIN
		insert #tempParams(Variable, Valor)
		values('Mensaje', @UpdateSupervisorMensaje) 
	END

	IF(@TipoCambio = 'CREATE-USUARIO')
	BEGIN
		insert #tempParams(Variable, Valor)
		values('Mensaje', @CreateUsuarioMensaje) 
	END

	IF(@TipoCambio = 'UPDATE-USUARIO')
	BEGIN
		insert #tempParams(Variable, Valor)
		values('Mensaje', @UpdateUsuarioMensaje) 
	END	
 
	IF(@TipoCambio = 'APROBADA-USUARIO')
	BEGIN
		insert #tempParams(Variable, Valor)
		values('Mensaje', @AprobadaMensaje) 
	END	

	IF(@TipoCambio = 'RECHAZADA-USUARIO')
	BEGIN
		insert #tempParams(Variable, Valor)
		values('Mensaje', @RechazadaMensaje) 
	END

	DECLARE 
		@cols AS NVARCHAR(MAX),
		@query  AS NVARCHAR(MAX)
	;

	IF OBJECT_ID('TEMPDB.dbo.##tempParamsPivot') IS NOT NULL DROP TABLE ##tempParamsPivot
	
	SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Variable) 
            FROM #tempParams c
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

	set @query = 'SELECT  ' + @cols + ' 
			into ##tempParamsPivot
			from 
            (
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

	select @valor = a.JSON 
	from ##tempParamsPivot b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	
	BEGIN TRY
		BEGIN TRAN TransaccionNotificaciones
			insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros, IDIdioma)  
			SELECT @IDTipoNotificacion,@valor, @IDIdioma
	
			set @IDNotificacion = @@IDENTITY  
			IF(@TipoCambio = 'CREATE-SUPERVISOR')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				) 
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,c.Email
					,NULL 
                from RH.tblJefesEmpleados JE					
					LEFT JOIN Utilerias.fnBuscarCorreosEmpleados(@IDTipoNotificacion) c on c.IDEmpleado=JE.IDJefe					
					INNER JOIN [App].[tblTemplateNotificaciones] templateNot on templateNot.IDTipoNotificacion = @IDTipoNotificacion and templateNot.IDIdioma = @IDIdioma
				where JE.IDEmpleado = @IDEmpleado and c.Email is not null
				
			END

			IF(@TipoCambio = 'UPDATE-SUPERVISOR')
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				) 
				select 
				  @IDNotificacion  
				  ,templateNot.IDMedioNotificacion  
				  ,c.Email
				  ,NULL 
			    FROM RH.tblJefesEmpleados JE					
					LEFT JOIN Utilerias.fnBuscarCorreosEmpleados(@IDTipoNotificacion) c on c.IDEmpleado=JE.IDJefe					
					INNER JOIN [App].[tblTemplateNotificaciones] templateNot on templateNot.IDTipoNotificacion = @IDTipoNotificacion and templateNot.IDIdioma = @IDIdioma
				where JE.IDEmpleado = @IDEmpleado and c.Email is not null                            
			END

			IF(@TipoCambio = 'CREATE-USUARIO' and @Email is not null)
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				)  
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,@Email 
					,NULL
				from [App].[tblTiposNotificaciones] tn  
					join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
						and templateNot.IDIdioma = @IDIdioma
				where tn.IDTipoNotificacion = @IDTipoNotificacion
			END

			IF(@TipoCambio = 'UPDATE-USUARIO' and @Email is not null)
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				)  
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,@Email 
					,NULL
				from [App].[tblTiposNotificaciones] tn  
					join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
						and templateNot.IDIdioma = @IDIdioma
				where tn.IDTipoNotificacion = @IDTipoNotificacion
			END	

			IF(@TipoCambio = 'APROBADA-USUARIO' and @Email is not null)
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				)  
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,@Email 
					,NULL
				from [App].[tblTiposNotificaciones] tn  
					join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
						and templateNot.IDIdioma = @IDIdioma
				where tn.IDTipoNotificacion = @IDTipoNotificacion
			END	

			IF(@TipoCambio = 'RECHAZADA-USUARIO' and @Email is not null)
			BEGIN
				insert [App].[tblEnviarNotificacionA](  
					IDNotifiacion  
					,IDMedioNotificacion  
					,Destinatario
					,Adjuntos
				)  
				select 
					@IDNotificacion  
					,templateNot.IDMedioNotificacion  
					,@Email 
					,NULL
				from [App].[tblTiposNotificaciones] tn  
					join [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
						and templateNot.IDIdioma = @IDIdioma
				where tn.IDTipoNotificacion = @IDTipoNotificacion
			END	
	COMMIT TRAN TransaccionNotificaciones
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransaccionNotificaciones
	END CATCH
GO
