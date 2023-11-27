USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Asistencia].[spUIChecada] --1, 19959      
(      
	@IDChecada int    
	,@Fecha Datetime    
	,@FechaOrigen Date =null  
	,@IDEmpleado int    
	,@IDTipoChecada varchar(20)    
	,@IDUsuario int    
	,@Comentario varchar(500)    
)      
AS      
BEGIN      
	declare 
		 @Fechas [App].[dtFechas] 
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificiar el día actual)'
		,@CALENDARIO0003 bit = 0 --No Modificar calendraio de mañana en adelante')
        ,@CALENDARIO0007 bit = 0 --El usuario puede modificar su propio calendario de incidencias.
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
		,@Message varchar(max)
	;
	

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	BEGIN -- Permisos de calendario
		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0002')
		begin
			set @CALENDARIO0002 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0003')
		begin
			set @CALENDARIO0003 = 1
		end;

        if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0007')
		begin
			set @CALENDARIO0007 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO')
		begin
			set @DIAS_MODIFICAR_CALENDARIO = 1

			select @DIAS_MODIFICAR_CALENDARIO_DIAS = CAST(isnull(cpe.[Data], 0) as int)
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO'
		end;
	END
    
    if (@CALENDARIO0007 = 0)
	begin
		if (@IDEmpleado = (isnull((SELECT IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @IDUsuario),0)))
		begin
			
            set @Message = FORMATMESSAGE('No tienes permiso para modificar su propio calendario.')
			raiserror(@Message,16,1)
			return;
			return;
		end
	end

	if (@DIAS_MODIFICAR_CALENDARIO = 1)
	begin
		set @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA = DATEADD(DAY, @DIAS_MODIFICAR_CALENDARIO_DIAS * -1, GETDATE())

		if (@FechaOrigen < @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA)
		begin
			set @Message = FORMATMESSAGE('No tienes permiso para crear checadas mayores a %d dias previos.', @DIAS_MODIFICAR_CALENDARIO_DIAS)
			raiserror(@Message,16,1)
			return;
		end
	end

	if(@FechaOrigen is null OR @Comentario = 'Importación Checadas')  
	BEGIN  
		select   @FechaOrigen = t.FechaOrigen,
				@IDTipoChecada = t.TipoChecada     
		From [Asistencia].[fnValidaDiaOrigen](@IDEmpleado,@Fecha) t      
	END  

	insert into @Fechas(Fecha)
    SELECT d
    FROM (
		SELECT d = DATEADD(DAY, rn - 1, @FechaOrigen)
		FROM (
			SELECT TOP (DATEDIFF(DAY, @FechaOrigen, @FechaOrigen) +1) 
				rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM sys.all_objects AS s1
				CROSS JOIN sys.all_objects AS s2
				-- on my system this would support > 5 million days
		   ORDER BY s1.[object_id]
		) AS x
	) AS y;

	DELETE from @Fechas
	where (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
		or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)

	if(isnull(@IDChecada,0) = 0)    
	BEGIN    
		insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDEmpleado,IDTipoChecada,IDUsuario, FechaOriginal)      
		select @Fecha ,@FechaOrigen ,@IDEmpleado ,@IDTipoChecada, @IDUsuario, @Fecha 
		from @Fechas 
		where Fecha = @FechaOrigen   

		set @IDChecada = @@IDENTITY      

		select @NewJSON = a.JSON from [Asistencia].[tblChecadas] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDChecada = @IDChecada

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblChecadas]','[Asistencia].[spUIChecada]','INSERT',@NewJSON,''
	END    
	ELSE    
	BEGIN    
		select @OldJSON = a.JSON from [Asistencia].[tblChecadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDChecada = @IDChecada
		UPDATE c
			set c.Fecha = @Fecha,    
				c.fechaOrigen = @fechaOrigen,    
				c.IDTipoChecada = @IDTipoChecada,    
				c.IDUsuario = @IDUsuario,
				c.FechaOriginal = @Fecha,
				c.Automatica = 0
		from Asistencia.tblChecadas c   
			join @Fechas fecha on @fechaOrigen = fecha.Fecha
		Where IDChecada = @IDChecada and IDEmpleado = @IDEmpleado    
		
		select @NewJSON = a.JSON from [Asistencia].[tblChecadas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDChecada = @IDChecada

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblChecadas]','[Asistencia].[spUIChecada]','UPDATE',@NewJSON,@OldJSON
	END    
      
	exec [Asistencia].[spBuscarChecadasEmpleadoPorID] @IDChecada,@IDEmpleado, @IDUsuario    
END
GO
