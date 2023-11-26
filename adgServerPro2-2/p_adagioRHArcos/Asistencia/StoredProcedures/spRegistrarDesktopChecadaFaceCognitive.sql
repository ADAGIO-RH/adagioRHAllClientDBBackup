USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Asistencia].[spRegistrarDesktopChecadaFaceCognitive](      
	@IDLector int = 0,      
	@personsIds varchar(max)
)      
AS      
BEGIN      
	--declare  @IDLector int = 1,      
	-- @ClaveEmpleado Varchar(20) = '007189'  


	if (isnull(@IDLector, 0) = 0) 
	begin
		select top 1 @IDLector = IDLector
		from [Asistencia].[tblLectores] with (nolock)
		where Lector like '%login%' and IDTipoLector = 'LectorLogin'

		if (isnull(@IDLector, 0) = 0) 
		begin
			raiserror(
				'No existe lector configurado para registro de asistencia. Contacte con un administrador.',
				16,
				1
			)
			return
		end
	end

	declare 
		@personId varchar(max)-- = '08910d87-a780-4cd5-81db-fe7c585d0f92',
		,@ClaveEmpleado Varchar(20)
	;

	select top 1 @personId = item from App.Split(@personsIds, ',')

	select @ClaveEmpleado = UserData from AzureCognitiveServices.tblPersons where PersonId = @personId

	SET DATEFORMAT ymd;   
      
	DECLARE @dtUTC DATETIME = getdate(),      
		@dtLectorZonaHoraria Varchar(100),      
		@dtFechaZonaHoraria Datetime,      
		@IDZonaHoraria int,      
		@IDChecada int = 0,      
		@Valida bit = 1,      
		@FechaOrigen Date,      
		@TipoChecada Varchar(5),      
		@Mensaje Varchar(1000),    
		@IDEmpleado int ,
		@dtEmpleados [RH].[dtEmpleados] ,
		@RequiereChecar bit,  
		@PermiteChecar bit,
		@EsRepetida bit= 0 
	;

	insert into @dtEmpleados
	select top 1 * from RH.tblEmpleadosMaster with (nolock) where ClaveEmpleado = @ClaveEmpleado

	if exists(select top 1 1 from @dtEmpleados where ClaveEmpleado = @ClaveEmpleado)    
	begin    
		select top 1 @IDEmpleado = IDEmpleado from @dtEmpleados where ClaveEmpleado = @ClaveEmpleado    
	end    
	else    
	BEGIN    
		set @IDEmpleado = 0    
	end    
    
	if(@IDEmpleado <> 0)    
	BEGIN    
		select @dtLectorZonaHoraria = 'Chetumal'  
		--isnull(z.Name,'UTC')       
		--  ,@IDZonaHoraria = isnull(z.Id ,(select top 1 id from tzdb.Zones where Name = 'UTC'))      
		-- from Asistencia.tblLectores l      
		--  left join Tzdb.Zones z      
		--   on l.IDZonaHoraria = z.Id      
		--where l.IDLector = @IDLector      
      
		set  @dtFechaZonaHoraria = getdate() --Tzdb.UtcToLocal(@dtUTC,@dtLectorZonaHoraria)      
      
		select  @FechaOrigen = t.FechaOrigen,      
				@TipoChecada = t.TipoChecada      
		From [Asistencia].[fnValidaDiaOrigen](@IDEmpleado,@dtFechaZonaHoraria) t      
      
		--select @IDEmpleado,@FechaOrigen,@TipoChecada,@IDLector, @dtFechaZonaHoraria      
		select top 1 @RequiereChecar = RequiereChecar, @PermiteChecar = PermiteChecar from @dtEmpleados where IDEmpleado = @IDEmpleado
     
		if(@RequiereChecar = 1) 
		begin
			exec Asistencia.spValidarChecada      
				@IDEmpleado = @IDEmpleado,      
				@dtEmpleados2 = @dtEmpleados,
				@FechaOrigen = @FechaOrigen,      
				@Tipochecada = @TipoChecada,      
				@IDLector = @IDLector,      
				@dtFechaZonaHoraria = @dtFechaZonaHoraria,      
				@outChecadaValida = @Valida output,      
				@outMensajeValidacion = @Mensaje output,
				@outEsRepetida = @EsRepetida output      
		end
		else
		begin
			set @Valida = 1
			set @Mensaje = ''
		end

		--select @Valida, @Mensaje  
		if ((@Valida = 1) and (@EsRepetida = 0))
		BEGIN      
			insert into Asistencia.tblChecadas(Fecha,FechaOrigen,IDLector,IDEmpleado,IDTipoChecada,IDZonaHoraria,Automatica,FechaReg,FechaOriginal)      
			select @dtFechaZonaHoraria as Fecha      
					,@FechaOrigen      
					,case when isnull(@IDLector, 0) = 0 then null else @IDLector end      
					,@IDEmpleado      
					,@TipoChecada      
					,Null      
					,1      
					,@dtUTC      
					,@dtFechaZonaHoraria
					
			set @IDChecada = @@IDENTITY      
      
			Select       
				c.IDChecada,      
				c.Fecha,      
				c.FechaOrigen,      
				isnull(c.IDLector,0) as IDLector,      
				isnull(l.Lector,'NINGUNO') as Lector,      
				isnull(c.IDEmpleado,0) as IDEmpleado,      
				isnull(m.ClaveEmpleado,'00000') as ClaveEmpleado,      
				m.NOMBRECOMPLETO as NombreCompleto,      
				m.Departamento as Departamento,      
				m.Sucursal as Sucursal,      
				m.Puesto as Puesto,       
				isnull(c.IDUsuario,0) as IDUsuario,      
				c.Comentario,      
				c.IDTipoChecada,      
				tc.TipoChecada,      
				isnull(c.IDZonaHoraria,0) as IDZonaHoraria,      
				z.Name as ZonaHoraria,      
				c.FechaReg,      
				@Valida as Valida,      
				cast('Checada Registrada Satisfactoriamente. Tipo Checada: ' + tc.TipoChecada as varchar(1000))  as MensajeChecada      
			from Asistencia.tblChecadas c with (nolock)       
				inner join Asistencia.tblLectores l with (nolock) on c.IDLector = l.IDLector      
				inner join RH.tblEmpleadosMaster m with (nolock) on c.IDEmpleado = m.IDEmpleado      
				inner join Asistencia.tblCatTiposChecadas tc with (nolock) on c.IDTipoChecada = tc.IDTipoChecada    
				left join tzdb.Zones z with (nolock) on z.Id = c.IDZonaHoraria     
			where IDChecada = @IDChecada      
		END      
		ELSE      
		BEGIN      
			Select       
				0 as IDChecada,      
				@dtFechaZonaHoraria  as Fecha,      
				@FechaOrigen as FechaOrigen,      
				isnull(l.IDLector,0) as IDLector,      
				'Lector' as Lector,      
				isnull(m.IDEmpleado,0) as IDEmpleado,      
				isnull(m.ClaveEmpleado,'00000') as ClaveEmpleado,      
				m.NOMBRECOMPLETO as NombreCompleto,      
				m.Departamento as Departamento,          
				m.Sucursal as Sucursal,      
				m.Puesto as Puesto,       
				0 as IDUsuario,      
				'' as Comentario,      
				'' as IDTipoChecada,      
				'' as TipoChecada,      
				isnull(@IDZonaHoraria,0) as IDZonaHoraria,      
				@dtLectorZonaHoraria as ZonaHoraria,      
				@dtUTC as FechaReg,      
				@Valida as Valida,      
				@Mensaje as MensajeChecada      
			FROM Asistencia.tblLectores l with (nolock)       
				cross apply RH.tblEmpleadosMaster m with (nolock)       
			WHERE l.IDLector = @IDLector and M.IDEmpleado = @IDEmpleado      
      
			EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,@Mensaje      
		END      
	END    
	else     
	begin    
		Select       
			0 as IDChecada,      
			getdate()  as Fecha,      
			getdate() as FechaOrigen,      
			0 as IDLector,      
			'Lector' as Lector,      
			0 as IDEmpleado,      
			'00000' as ClaveEmpleado,      
			'...' as NombreCompleto,      
			'...' as Departamento,      
			'...' as Sucursal,      
			'...' as Puesto,       
			0 as IDUsuario,      
			'' as Comentario,      
			'' as IDTipoChecada,      
			'' as TipoChecada,      
			0 as IDZonaHoraria,      
			'' as ZonaHoraria,      
			getdate() as FechaReg,      
			cast(0 as bit) as Valida,      
			'Empleado no existente en la base de datos.'as MensajeChecada      

		EXEC Asistencia.spIBitacoraChecadas @IDEmpleado,@dtUTC,@IDLector,'Empleado no existente en la base de datos.'  
	end    
  
	Select Mensaje          
	from Asistencia.tblMensajesEmpleados with (nolock)          
	where IDEmpleado = @IDEmpleado  
	and  @dtUTC Between FechaInicio and FechaFin       
  
END
GO
