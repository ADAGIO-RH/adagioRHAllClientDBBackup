USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Guarda y actualizar Horarios de los empleados
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-08-14
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE proc [Asistencia].[spIUHorariosEmpleado] (
     @IDEmpleado int
    ,@IDHorario int 
    ,@FechaIni date 
    ,@FechaFin date     
    ,@Dias varchar(20) 
    ,@IDUsuario int 
 ) as

	SET DATEFIRST 7;

	declare @Fechas [App].[dtFechas]
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificiar el día actual)'
		,@CALENDARIO0003 bit = 0 --Modificar calendario solo de mañana en adelante
		,@CALENDARIO0004 bit = 0 --Validar hora de entrada al asignar horarios
	;

	BEGIN -- Permisos de calendario
		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes with (nolock)	
				join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0002')
		begin
			set @CALENDARIO0002 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes with (nolock)	
				join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0003')
		begin
			set @CALENDARIO0003 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes with (nolock)	
				join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0004')
		begin
			select @CALENDARIO0004 = 1
				 ,@CALENDARIO0003 = 0
		end;
	END
 
    select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u
	   Inner join App.tblPreferencias p with (nolock)
		  on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp with (nolock)
		  on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp with (nolock)
		  on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	   where u.IDUsuario = @IDUsuario
		  and tp.TipoPreferencia = 'Idioma'

	select @IdiomaSQL = [SQL]
    from app.tblIdiomas with (nolock)
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

    if not exists (SELECT top 1 * 
			 from Asistencia.tblCatHorarios with (nolock)
			 where IDHorario = @IDHorario) 
    BEGIN
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0611002'
	  -- return 0;
    END;

    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @FechaIni
	   , @FechaFin = @FechaFin
	
    --DELETE from @Fechas
    --where DATEPART(dw,Fecha) NOT in (SELECT cast(item as int) from [App].[Split](@Dias,',') )

	DELETE from @Fechas
	where DATEPART(dw,Fecha) NOT in (SELECT cast(item as int) from [App].[Split](@Dias,',') )
		or (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
		or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)
   
   
    select @CALENDARIO0004 
	if (
		(exists(select top 1 1 
			from Asistencia.tblHorariosEmpleados he
				join Asistencia.tblCatHorarios ch on he.IDHorario = ch.IDHorario
				join @Fechas fechas on he.Fecha = fechas.Fecha and fechas.Fecha = CAST(GETDATE() as date)
			where he.IDEmpleado = @IDEmpleado and ch.HoraEntrada <= CAST(GETDATE() as time))
		and @CALENDARIO0004  = 1)

		or 

		((exists(select top 1 1 
			from Asistencia.tblCatHorarios ch 
			where ch.IDHorario = @IDHorario 
					and ch.HoraEntrada <= CAST(GETDATE() as time))
					and @CALENDARIO0004  = 1
					and CAST(GETDATE() as date) in (select Fecha from @Fechas)))
		)
	begin
		raiserror('No puede cambiar el horario del día de hoy porque ya pasó su hora de entrada.',16,1)

		return
	end;

 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

 SELECT @NewJson ='['+ STUFF(
            ( select ','+ a.JSON
							from @Fechas b
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.Fecha, @IDEmpleado as IDEmpleado, @IDHorario as IDHorario For XML Raw)) ) a
												FOR xml path('')
            )
            , 1
            , 1
            , ''
						)
						+']'

 SELECT @OldJson ='['+ STUFF(
            ( select ','+ a.JSON
							from @Fechas b
							join [Asistencia].[tblHorariosEmpleados] c
								on b.Fecha = c.Fecha
							and c.IDEmpleado = @IDEmpleado
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select c.* For XML Raw)) ) a
												FOR xml path('')
            )
            , 1
            , 1
            , ''
						)
						+']'

   EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblHorariosEmpleados]','[Asistencia].[spIUHorariosEmpleado]','MERGE',@NewJSON,@OldJSON
		

    MERGE [Asistencia].[tblHorariosEmpleados] AS TARGET
    USING @Fechas as SOURCE
    on TARGET.Fecha = SOURCE.Fecha and (TARGET.IDEmpleado = @IDEmpleado)
    WHEN MATCHED THEN
	   update 
		  set TARGET.IDHorario = @IDHorario
    WHEN NOT MATCHED BY TARGET THEN 
	   INSERT(IDEmpleado,IDHorario,Fecha)
	   values(@IDEmpleado,@IDHorario, SOURCE.Fecha)

    --WHEN NOT MATCHED BY SOURCE and  (TARGET.IDEmpleado = @IDEmpleado) THEN 
    --DELETE
    ;
    

    --select *
    --from [Asistencia].[tblHorariosEmpleados]
    --select *
    --from @Fechas
GO
