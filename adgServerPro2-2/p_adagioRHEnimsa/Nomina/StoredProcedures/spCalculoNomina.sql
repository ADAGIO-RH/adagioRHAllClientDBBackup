USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [Nomina].[spCalculoNomina]  1,4,289                  
CREATE PROC [Nomina].[spCalculoNomina] (                  
	@IDUsuario int                   
	,@IDTipoNomina int                   
	,@IDPeriodo int = 0                  
	,@dtFiltros [Nomina].[dtFiltrosRH] READONLY                
	,@isPreviewFiniquito bit=0        
	,@ExcluirBajas bit =1                
	,@AjustaISRMensual bit =0                 
)                  
as 
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spCalculoNomina]',
		@Tabla		varchar(max) = '[Nomina].[tblDetallePeriodo]',
		@Accion		varchar(20)	= 'Cálculo de Nómina',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	--set @ExcluirBajas =1                
      
	 
	select @NewJSON = '['+ STUFF(
				( select ','+ a.JSON
				  from @dtFiltros b
					Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
				  FOR xml path('')
				)
				, 1
				, 1
				, ''
				)
				+']'

	declare                   
		@i int = 0                   
		,@IDPeriodoSeleccionado int=0                  
		,@periodo [Nomina].[dtPeriodos]                  
		,@configs [Nomina].[dtConfiguracionNomina]                  
		,@empleados [RH].[dtEmpleados]                  
		,@empleadosEliminarDelCalculo [RH].[dtEmpleados]                  
		,@Conceptos [Nomina].[dtConceptos]                  
		,@DetallePeriodo [Nomina].[dtDetallePeriodo]                  
		,@spConcepto nvarchar(255)                  
		,@IDConcepto int = 0                  
		,@CodigoConcepto varchar(20)                  
		,@fechaIniPeriodo  date                  
		,@fechaFinPeriodo  date      
		,@fechaIniIncPeriodo  date                  
		,@fechaFinIncPeriodo  date             
		,@Homologa varchar(10)
		,@dtEmpleadosMovimientoSalario RH.dtEmpleados 
		,@dtEmpleadosAEliminarDelCalculo RH.dtEmpleados 
		,@fechas [App].[dtFechas]   
		,@fechasUltimaVigencia [App].[dtFechas]              
		,@ListaFechasUltimaVigencia [App].[dtFechasVigenciaEmpleado]
		,@EliminarDetallePeriodo bit
		,@DescripcionPeriodo varchar(500)

		/* Estos conceptos no serán considerados por el proceso que ejecuta los stored procedured de la                   
		formula de cada concepto */                  
		,@ConceptosExcluidos varchar(1000) = '500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,303,519,520,521';                  
                  
	SET @EliminarDetallePeriodo = isnull((select top 1 cast([Value] as bit) from @dtFiltros where Catalogo = 'EliminarDetallePeriodo'),0)

	if object_id('tempdb..#tempDetallePeriodo') is not null drop table #tempDetallePeriodo;                  
                  
    CREATE table #tempDetallePeriodo (                  
		[IDDetallePeriodo] [int] NULL,                  
		[IDEmpleado] [int] NOT NULL,                  
		[IDPeriodo] [int] NOT NULL,                  
		[IDConcepto] [int] NOT NULL,                  
		[CantidadMonto] [decimal](18, 4)  NULL default 0,                  
		[CantidadDias] [decimal](18, 4)   NULL default 0,                  
		[CantidadVeces] [decimal](18, 4)  NULL default 0,                  
		[CantidadOtro1] [decimal](18, 4)  NULL default 0,                  
		[CantidadOtro2] [decimal](18, 4)  NULL default 0,                  
		[ImporteGravado] [decimal](18, 4) NULL default 0,                  
		[ImporteExcento] [decimal](18, 4) NULL default 0,                  
		[ImporteOtro] [decimal](18, 4)   NULL default 0,                  
		[ImporteTotal1] [decimal](18, 4)  NULL default 0,                  
		[ImporteTotal2] [decimal](18, 4)  NULL default 0,                  
		[Descripcion] [Varchar](255) COLLATE DATABASE_DEFAULT NULL,                  
		[IDReferencia] int null                  
    );                  
                  
	/* Se busca el ID de periodo seleccionado del tipo de nómina */                  
                  
	IF(isnull(@IDPeriodo,0)=0)                  
	BEGIN                   
		select @IDPeriodoSeleccionado = IDPeriodo                  
		from Nomina.tblCatTipoNomina with (nolock)                  
		where IDTipoNomina=@IDTipoNomina                  
		END                  
	ELSE                  
	BEGIN                  
		set @IDPeriodoSeleccionado = @IDPeriodo                  
	END                  
                  
	/* Se buscar toda la información del periodo seleccionado y se guarda en @periodo*/                  
	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos with (nolock)                  
	where IDPeriodo = @IDPeriodoSeleccionado                  
                  
	select 
		@fechaIniPeriodo	= FechaInicioPago
		,@fechaFinPeriodo	= FechaFinPago
		,@fechaIniIncPeriodo	= FechaInicioIncidencia 
		,@fechaFinIncPeriodo	= FechaFinIncidencia 
		,@DescripcionPeriodo	= coalesce(ClavePeriodo,'')+' - '+coalesce(Descripcion,'')
	from Nomina.TblCatPeriodos with (nolock)                
	where IDPeriodo = @IDPeriodoSeleccionado  
	
	select @InformacionExtra = a.JSON 
	from (
		select 
			@IDUsuario			  as IDUsuario			
			,@IDTipoNomina		  as IDTipoNomina		
			,@IDPeriodo			  as IDPeriodo		
			,@DescripcionPeriodo  as Periodo
			,@isPreviewFiniquito  as isPreviewFiniquito
			,@ExcluirBajas		  as ExcluirBajas		
			,@AjustaISRMensual	  as AjustaISRMensual	
	) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario			= @IDUsuario
		,@Tabla				= @Tabla
		,@Procedimiento		= @NombreSP
		,@Accion			= @Accion
		,@NewData			= @NewJSON
		,@OldData			= @OldJSON
		,@Mensaje			= @Mensaje
		,@InformacionExtra	= @InformacionExtra
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	if(isnull(@isPreviewFiniquito,0) = 0 )
	BEGIN             
		insert into @empleados   
		exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros  , @IDUsuario = @IDUsuario                
	END
	ELSE
	BEGIN
		insert into @empleados   
		exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario
	END 

	BEGIN ---- CALCULAR SUELDO PROMEDIO
		insert into @fechas
		exec [App].[spListaFechas]@fechaIniPeriodo,@fechaFinPeriodo

		insert into @dtEmpleadosMovimientoSalario
		select E.* 
		from @empleados E
			inner join IMSS.tblMovAfiliatorios M with(nolock)
				on M.IDEmpleado = e.IDEmpleado
					and M.Fecha Between @fechaIniPeriodo and @fechaFinPeriodo
			inner join IMSS.tblCatTipoMovimientos TM with(nolock)
				on TM.IDTipoMovimiento = M.IDTipoMovimiento
					and TM.Codigo = 'M'
		order by IDEmpleado, m.Fecha

		if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados    
		if object_id('tempdb..#tempEmpleadosSueldos') is not null drop table #tempEmpleadosSueldos  
		if object_id('tempdb..#tempEmpleadosSueldosAVG') is not null drop table #tempEmpleadosSueldosAVG  

		Create Table #tempVigenciaEmpleados(    
			IDEmpleado int null,    
			Fecha Date null,    
			Vigente bit null    
		)
		
		insert into #tempVigenciaEmpleados   
		exec [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleadosMovimientoSalario,@fechas,@IDUsuario

		select *,
			(select top 1 M.SalarioDiario 
				from IMSS.tblMovAfiliatorios M with (nolock)
					inner join IMSS.tblCatTipoMovimientos TM with (nolock)
						on TM.IDTipoMovimiento = M.IDTipoMovimiento
						and TM.Codigo = 'M'
				where VE.IDEmpleado = M.IDEmpleado
				and M.Fecha <= VE.Fecha
				order by M.Fecha desc
				)  SalarioDiario,
				(select top 1 M.SalarioIntegrado 
				from IMSS.tblMovAfiliatorios M with (nolock)
					inner join IMSS.tblCatTipoMovimientos TM with (nolock)
						on TM.IDTipoMovimiento = M.IDTipoMovimiento
						and TM.Codigo = 'M'
				where VE.IDEmpleado = M.IDEmpleado
				and M.Fecha <= VE.Fecha
				order by M.Fecha desc
				)  SalarioIntegrado,
				(select top 1 M.SalarioDiarioReal 
				from IMSS.tblMovAfiliatorios M with (nolock)
					inner join IMSS.tblCatTipoMovimientos TM with (nolock)
						on TM.IDTipoMovimiento = M.IDTipoMovimiento
						and TM.Codigo = 'M'
				where VE.IDEmpleado = M.IDEmpleado
				and M.Fecha <= VE.Fecha
				order by M.Fecha desc
				)  SalarioDiarioReal
		into #tempEmpleadosSueldos
		from  #tempVigenciaEmpleados VE
		WHERE VE.Vigente = 1
		order by VE.IDEmpleado, Ve.Fecha asc

		select IDEmpleado
			, cast(AVG(SalarioDiario) as decimal(18,2)) as SalarioDiario
			, cast(AVG(SalarioIntegrado) as decimal(18,2)) as SalarioIntegrado
			, cast(AVG(SalarioDiarioReal) as decimal(18,2)) as SalarioDiarioReal
		into #tempEmpleadosSueldosAVG
		from #tempEmpleadosSueldos
		Group by IDEmpleado

		update e
		   set 	e.SalarioDiario = EA.SalarioDiario,
		   		e.SalarioIntegrado = EA.SalarioIntegrado,
				e.SalarioDiarioReal = EA.SalarioDiarioReal
		from @empleados e
			inner join #tempEmpleadosSueldosAVG EA
				on EA.IDEmpleado = e.IDEmpleado

	END   ---- CALCULAR SUELDO PROMEDIO
	           
	-- VALIDA SI EXISTEN COLABORADORES DUPLICADOS              
	if exists (select IDEmpleado,count(*)
		from @empleados
		group by IDEmpleado
		having count(*) >= 2)
	begin
		raiserror('Existen colaboradores dublicados en el cálculo, revise con su asesor de soporte.',16,1);  
		return;
	end;	   
			      
   --select * from @empleados                  
                  
	/* Se carga la configuración de la nómina */                  
	insert into @configs                  
	select                   
		Configuracion                  
		,Valor                  
		,TipoDato                  
		,Descripcion                   
	from Nomina.tblConfiguracionNomina  with (nolock)           
                  
	insert into @configs                  
	select 'isPreviewFiniquito',@isPreviewFiniquito,'bit','Preview finiquito'     
     
	insert into @configs                  
	select 'AjusteISRMensual',@AjustaISRMensual,'bit','0=NO HACE AJUSTE;1=AJUSTA ISR MES CON MES.'                 
              
	if exists( select top 1 1 from @configs where Configuracion = 'HomologarIMSS')          
	BEGIN          
		select top 1 @Homologa = ISNULL(valor,'0') from @configs where Configuracion = 'HomologarIMSS'          
	END          
	ELSE          
	BEGIN          
		set @Homologa = '0'          
	END              
          
	IF((select valor from @configs where Configuracion = 'PAGOFINIQUITONOMINA')=0 and @isPreviewFiniquito = 0)                  
	BEGIN                  
		DELETE @empleados                  
		where IDEmpleado in (Select IDEmpleado                   
								from Nomina.tblControlFiniquitos with (nolock)
								where IDPeriodo = @IDPeriodoSeleccionado and IDEStatusFiniquito = (Select IDEStatusFiniquito                   
																								from Nomina.tblCatEstatusFiniquito with (nolock)                  
																								where Descripcion = 'Aplicar')                  
								);                  
	END           
           
	IF(@isPreviewFiniquito = 1)        
	BEGIN        
		set @ExcluirBajas = 0        
	END               
              
	IF(isnull(@isPreviewFiniquito,0) = 0)         
	BEGIN       
		insert into @fechasUltimaVigencia
		exec [App].[spListaFechas]@fechaFinPeriodo,@fechaFinPeriodo
	
		--if object_id('tempdb..#tempUltimaVigenciaEmpleados') is not null drop table #tempUltimaVigenciaEmpleados    

		--create Table #tempUltimaVigenciaEmpleados(    
		--	IDEmpleado int null,    
		--	Fecha Date null,    
		--	Vigente bit null    
		--);
		
		--insert into #tempUltimaVigenciaEmpleados   
		insert @ListaFechasUltimaVigencia
		exec [RH].[spBuscarListaFechasVigenciaEmpleado] @empleados,@fechasUltimaVigencia,@IDUsuario

		insert @empleadosEliminarDelCalculo
		exec Nomina.spBuscarColaboradoresAExcluirDelCalculo
			@FechaIni				= @fechaIniPeriodo
			,@FechaFin				= @fechaIniPeriodo
			,@empleados				= @empleados        
			,@fechasUltimaVigencia	= @ListaFechasUltimaVigencia
			,@IDPeriodo				= @IDPeriodoSeleccionado  
			,@ExcluirBajas			= @ExcluirBajas
			,@IDUsuario				= @IDUsuario

		DELETE e
		from @empleados e
			join @empleadosEliminarDelCalculo d on e.IDEmpleado = d.IDEmpleado
	END;       
        
	/* Se buscan todos los conceptos activos para el cálculo excluyendo los código que está en la lista @ConceptosExcluidos*/                  
	insert into @Conceptos(                  
		IDConcepto                  
		,Codigo                  
		,Descripcion                  
		,IDTipoConcepto                  
		,Estatus                  
		,Impresion                  
		,IDCalculo                  
		,CuentaAbono                  
		,CuentaCargo                  
		,bCantidadMonto                  
		,bCantidadDias                  
		,bCantidadVeces                  
		,bCantidadOtro1                  
		,bCantidadOtro2                  
		,IDCodigoSAT                  
		,NombreProcedure                  
		,OrdenCalculo                  
		,LFT                  
		,Personalizada                  
		,ConDoblePago                  
	)      
	select *                   
	from Nomina.tblCatConceptos with (nolock)                   
	where Estatus = 1 and codigo not in (select Item from App.split(@ConceptosExcluidos,','))                  
	
	BEGIN -- Elimina los posibles registros de conceptos que no están activos.
		DELETE dp
		FROM Nomina.tblDetallePeriodo dp with (nolock)
			inner join @empleados e on dp.IDEmpleado = e.IDEmpleado
			inner join Nomina.tblCatConceptos c with (nolock)
				on dp.IDConcepto = c.IDConcepto
				and isnull(c.Estatus,0) = 0
			inner join @periodo p 
				on p.IDPeriodo = dp.IDPeriodo
	 
		DELETE dp
		FROM Nomina.tblDetallePeriodoFiniquito dp
			inner join @empleados e on dp.IDEmpleado = e.IDEmpleado
			inner join Nomina.tblCatConceptos c
				on dp.IDConcepto = c.IDConcepto
				and isnull(c.Estatus,0) = 0  
			inner join @periodo p 
				on p.IDPeriodo = dp.IDPeriodo              
	END
                  
	if(@isPreviewFiniquito = 0)                  
	BEGIN                  
		/* Se carga el detalle del periodo al momento del cálculos (Capturas de nóminia y/o montos previamente calculados) */                  
		insert into @DetallePeriodo(IDDetallePeriodo,IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1                  
			,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,[IDReferencia])                  
		select detallePeriodo.IDDetallePeriodo,detallePeriodo.IDEmpleado,detallePeriodo.IDPeriodo,detallePeriodo.IDConcepto,detallePeriodo.CantidadMonto                  
			,detallePeriodo.CantidadDias,detallePeriodo.CantidadVeces,detallePeriodo.CantidadOtro1,detallePeriodo.CantidadOtro2,detallePeriodo.ImporteGravado                  
			,detallePeriodo.ImporteExcento,detallePeriodo.ImporteOtro,detallePeriodo.ImporteTotal1,detallePeriodo.ImporteTotal2,detallePeriodo.Descripcion,[IDReferencia]                  
		from Nomina.tblDetallePeriodo detallePeriodo with (nolock)                  
		JOIN @empleados e on detallePeriodo.IDEmpleado = e.IDEmpleado                  
		where detallePeriodo.IDPeriodo=@IDPeriodoSeleccionado                  
	END                  
	ELSE                  
	BEGIN                  
		insert into @DetallePeriodo(IDDetallePeriodo,IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1                  
			,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,[IDReferencia])                  
		select detallePeriodo.IDDetallePeriodo,detallePeriodo.IDEmpleado,detallePeriodo.IDPeriodo,detallePeriodo.IDConcepto,detallePeriodo.CantidadMonto                  
		,detallePeriodo.CantidadDias,detallePeriodo.CantidadVeces,detallePeriodo.CantidadOtro1,detallePeriodo.CantidadOtro2,detallePeriodo.ImporteGravado                  
		,detallePeriodo.ImporteExcento,detallePeriodo.ImporteOtro,detallePeriodo.ImporteTotal1,detallePeriodo.ImporteTotal2,detallePeriodo.Descripcion,[IDReferencia]                  
		from Nomina.tblDetallePeriodoFiniquito detallePeriodo with (nolock)                  
			JOIN @empleados e on detallePeriodo.IDEmpleado = e.IDEmpleado                  
		where detallePeriodo.IDPeriodo=@IDPeriodoSeleccionado                  
	END                  
                  
	--select * from @DetallePeriodo                  
	select @i=min(OrdenCalculo) from @Conceptos;                   
	declare @date Varchar(100) = getdate()        
	
	/* Se recorren todos los conceptos y se ejecuta su respectivo Stored procedure pasandole los debidos parámetros */                     
	while exists(select 1 from @Conceptos where OrdenCalculo >= @i)                   
	begin                   
		select @spConcepto=NombreProcedure                  
			,@IDConcepto=IDConcepto                  
			,@CodigoConcepto=Codigo                  
		from @Conceptos 
		where OrdenCalculo=@i;                   
		--set @date = getdate()                  
		-- RAISERROR(@spConcepto, 16, 1) WITH NOWAIT;                  
		-- RAISERROR(@date, 16, 1) WITH NOWAIT;                  
                  
		INSERT INTO #tempDetallePeriodo(IDDetallePeriodo,IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1                  
			,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,[IDReferencia])                     
		exec sp_executesql N'exec @miSP @dtconfigs,@dtempleados,@dtConceptos,@dtPeriodo,@dtDetallePeriodo'                   
			,N' @dtconfigs [Nomina].[dtConfiguracionNomina] READONLY                   
				,@dtempleados [RH].[dtEmpleados] READONLY                   
				,@dtConceptos [Nomina].[dtConceptos] READONLY                   
				,@dtPeriodo [Nomina].[dtPeriodos] READONLY                   
				,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY                  
				,@miSP varchar(255)',                          
				@dtconfigs =@configs                  
				,@dtempleados =@empleados                  
				,@dtConceptos = @Conceptos                  
				,@dtPeriodo = @periodo                  
				,@dtDetallePeriodo =@DetallePeriodo                  
				,@miSP = @spConcepto ;                                    
                  
		set @date = getdate()                
		--RAISERROR(@spConcepto, 16, 1) WITH NOWAIT;                  
		--RAISERROR(@date, 16, 1) WITH NOWAIT;                  
		--select * from #tempDetallePeriodo                  
                  
		if (@CodigoConcepto = '302')                      
		begin
			MERGE @DetallePeriodo AS TARGET                  
			USING #tempDetallePeriodo AS SOURCE                  
				ON TARGET.IDConcepto = SOURCE.IDConcepto                   
				and TARGET.IDEmpleado = SOURCE.IDEmpleado                  
				and TARGET.IDPeriodo = SOURCE.IDPeriodo                  
				and ISNULL(TARGET.Descripcion,'') = ISNULL(SOURCE.Descripcion,'')                  
			WHEN MATCHED Then                  
			update                  
				Set                       
					TARGET.CantidadMonto  = SOURCE.CantidadMonto                  
				,TARGET.CantidadDias   = SOURCE.CantidadDias                  
				,TARGET.CantidadVeces  = SOURCE.CantidadVeces                  
				,TARGET.CantidadOtro1  = SOURCE.CantidadOtro1                  
				,TARGET.CantidadOtro2  = SOURCE.CantidadOtro2                  
				,TARGET.ImporteGravado = SOURCE.ImporteGravado                  
				,TARGET.ImporteExcento = SOURCE.ImporteExcento                  
				,TARGET.ImporteOtro    = SOURCE.ImporteOtro                  
				,TARGET.ImporteTotal1  = SOURCE.ImporteTotal1                  
				,TARGET.ImporteTotal2  = SOURCE.ImporteTotal2                  
				,TARGET.Descripcion  = SOURCE.Descripcion                  
				,TARGET.IDReferencia    = SOURCE.IDReferencia                  
			WHEN NOT MATCHED BY TARGET THEN                   
				INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)                  
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto                  
						,SOURCE.CantidadMonto,SOURCE.CantidadDias,SOURCE.CantidadVeces,SOURCE.CantidadOtro1,SOURCE.CantidadOtro2                  
					,SOURCE.ImporteGravado,SOURCE.ImporteExcento,SOURCE.ImporteOtro,SOURCE.ImporteTotal1,SOURCE.ImporteTotal2,SOURCE.Descripcion,SOURCE.IDReferencia)                  
			WHEN NOT MATCHED BY SOURCE 
					and (TARGET.IDConcepto in (select c.IDConcepto from Nomina.tblCatConceptos c where c.Codigo in (select item from App.split(@ConceptosExcluidos,',')) or TARGET.IDConcepto = @IDConcepto)
					and TARGET.IDEmpleado in (Select IDEmpleado from @Empleados)) 
				THEN                   
			DELETE;          
             
			if @Homologa = 1           
			BEGIN          
				DELETE @DetallePeriodo          
				WHERE IDConcepto = (Select top 1 IDConcepto from Nomina.tblCatConceptos where Codigo = '303')          
			END          
		end else                  
		begin
			--  if(@CodigoConcepto = '301')              
			-- BEGIN              
			--delete dp               
			--From @DetallePeriodo dp              
			-- inner join @Conceptos c              
			--  on dp.IDConcepto = c.IDConcepto              
			--where c.Codigo in ('180','301')              
			-- END               
                  
			-- select * from #tempDetallePeriodo
			MERGE @DetallePeriodo AS TARGET                  
			USING #tempDetallePeriodo AS SOURCE                 
				ON (TARGET.IDConcepto = SOURCE.IDConcepto                   
				and TARGET.IDEmpleado = SOURCE.IDEmpleado                  
				and TARGET.IDPeriodo = SOURCE.IDPeriodo                  
				and isnull(TARGET.Descripcion,'') = ISNULL(SOURCE.Descripcion,'')                  
				and ISNULL(TARGET.IDReferencia,0) = ISNULL(SOURCE.IDReferencia,0))                  
			WHEN MATCHED  Then                  
				update                  
				Set                       
					TARGET.CantidadMonto  = SOURCE.CantidadMonto                  
				,TARGET.CantidadDias   = SOURCE.CantidadDias                  
				,TARGET.CantidadVeces  = SOURCE.CantidadVeces                  
				,TARGET.CantidadOtro1  = SOURCE.CantidadOtro1                  
				,TARGET.CantidadOtro2  = SOURCE.CantidadOtro2                  
				,TARGET.ImporteGravado = SOURCE.ImporteGravado                  
				,TARGET.ImporteExcento = SOURCE.ImporteExcento                  
				,TARGET.ImporteOtro    = SOURCE.ImporteOtro                  
				,TARGET.ImporteTotal1  = SOURCE.ImporteTotal1                  
				,TARGET.ImporteTotal2  = SOURCE.ImporteTotal2                  
				,TARGET.Descripcion  = SOURCE.Descripcion                  
				,TARGET.IDReferencia    = SOURCE.IDReferencia                  
			WHEN NOT MATCHED BY TARGET THEN                   
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)                  
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto                  
					,SOURCE.CantidadMonto,SOURCE.CantidadDias,SOURCE.CantidadVeces,SOURCE.CantidadOtro1,SOURCE.CantidadOtro2                  
				,SOURCE.ImporteGravado,SOURCE.ImporteExcento,SOURCE.ImporteOtro,SOURCE.ImporteTotal1,SOURCE.ImporteTotal2,SOURCE.Descripcion, SOURCE.IDReferencia)                  
			WHEN NOT MATCHED BY SOURCE and TARGET.IDConcepto = @IDConcepto and TARGET.IDEmpleado in (Select IDEmpleado from @Empleados) THEN                   
			DELETE;                  
		end;                  
                      
		set @date = getdate()     
		--RAISERROR('END MERGE', 16, 1) WITH NOWAIT;                  
		--RAISERROR(@date, 16, 1) WITH NOWAIT;                  
           
		delete from #tempDetallePeriodo;                  
		select @i=min(OrdenCalculo) from @Conceptos where OrdenCalculo > @i;                   
	end;                     
	
	--select * from @Empleados
	IF(@isPreviewFiniquito = 0)                  
	BEGIN                  
		MERGE Nomina.tblDetallePeriodo AS TARGET                  
		USING @DetallePeriodo AS SOURCE                  
			ON (TARGET.IDConcepto = SOURCE.IDConcepto                   
			and TARGET.IDEmpleado = SOURCE.IDEmpleado                  
			and TARGET.IDPeriodo = SOURCE.IDPeriodo                  
			and TARGET.Descripcion = SOURCE.Descripcion                  
			and TARGET.IDReferencia = SOURCE.IDReferencia)                  
		WHEN MATCHED Then                  
			update                  
			Set                       
				TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)                  
			,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)                  
			,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)                  
			,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)                  
			,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)                  
			,TARGET.ImporteGravado = isnull(SOURCE.ImporteGravado,0)                  
			,TARGET.ImporteExcento = isnull(SOURCE.ImporteExcento,0)                  
			,TARGET.ImporteOtro    = isnull(SOURCE.ImporteOtro   ,0)                  
			,TARGET.ImporteTotal1  = isnull(SOURCE.ImporteTotal1 ,0)                  
			,TARGET.ImporteTotal2  = isnull(SOURCE.ImporteTotal2 ,0)                  
			,TARGET.Descripcion  = SOURCE.Descripcion                  
			,TARGET.IDReferencia  = SOURCE.IDReferencia                  
                      
		WHEN NOT MATCHED BY TARGET THEN             
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)                  
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto                  
			,isnull(SOURCE.CantidadMonto ,0)                  
			,isnull(SOURCE.CantidadDias ,0)                  
			,isnull(SOURCE.CantidadVeces ,0)                  
			,isnull(SOURCE.CantidadOtro1 ,0)                  
			,isnull(SOURCE.CantidadOtro2 ,0)                  
			,isnull(SOURCE.ImporteGravado,0)                  
			,isnull(SOURCE.ImporteExcento,0)                  
			,isnull(SOURCE.ImporteOtro ,0)                  
			,isnull(SOURCE.ImporteTotal1 ,0)                  
			,isnull(SOURCE.ImporteTotal2 ,0)                  
			,SOURCE.Descripcion                  
			,SOURCE.IDReferencia)       
			WHEN NOT MATCHED BY SOURCE and TARGET.IDPeriodo = @IDPeriodoSeleccionado and TARGET.IDEmpleado in (Select IDEmpleado from @Empleados) THEN                   
		DELETE;                  
                  
		if object_id('tempdb..#tempSumatoriaPeriodo') is not null drop table #tempSumatoriaPeriodo;

           -- ARMAR SUMATORIA       
		select dp.IDPeriodo                  
			,cp.Descripcion as Periodo                  
			,dp.IDConcepto                  
			,ccp.Codigo                  
			,ccp.Descripcion as Concepto                  
			,ccp.IDTipoConcepto                  
			,ccp.OrdenCalculo                  
			,'' as Descripcion--dp.Descripcion                  
			,SUM(isnull(dp.CantidadMonto,0)) as CantidadMonto                  
			,SUM(isnull(dp.CantidadDias,0)) as CantidadDias                  
			,SUM(isnull(dp.CantidadVeces,0)) as CantidadVeces                  
			,SUM(isnull(dp.CantidadOtro1,0)) as CantidadOtro1                  
			,SUM(isnull(dp.CantidadOtro2,0)) as CantidadOtro2                  
			,SUM(isnull(dp.ImporteGravado,0)) as ImporteGravado                  
			,SUM(isnull(dp.ImporteExcento,0)) as ImporteExcento                  
			,SUM(isnull(dp.ImporteOtro,0)) as ImporteOtro                  
			,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1                  
			,SUM(isnull(dp.ImporteTotal2,0)) ImporteTotal2                      
			,(SUM(isnull(dp.ImporteTotal1,0)) * SUM(isnull(dp.ImporteTotal2,0))) as ImporteAcumuladoTotales                  
		INTO #tempSumatoriaPeriodo                  
		from @DetallePeriodo dp                  
			join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo                  
			join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto                     
			join @empleados e on dp.IDEmpleado = e.IDEmpleado                  
		where cp.IDPeriodo = @IDPeriodoSeleccionado                  
		group by  dp.IDPeriodo                  
			,cp.Descripcion                   
			,dp.IDConcepto                  
			,ccp.Codigo                  
			,ccp.Descripcion                  
			,ccp.IDTipoConcepto                  
			,ccp.OrdenCalculo                  
			--,dp.Descripcion    
            --DETALLE 
		
		if object_id('tempdb..#tempListaPago') is not null drop table #tempListaPago;   

		select distinct E.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as NombreCompleto
			,isnull(dpPercepciones.ImporteTotal1,0) as TotalPercepciones 
			,isnull(dpDeducciones.ImporteTotal1,0) as TotalDeducciones 
			,isnull(dpPago.ImporteTotal1,0) as TotalPagado 
			,isnull(CCPago.Codigo,'000') +' - '+ isnull(CCPago.Descripcion,'NO ASIGNADO') as ConceptoPago
			into #tempListaPago
		from @empleados E
			left join @DetallePeriodo dpPercepciones
				on e.IDEmpleado = dpPercepciones.IDEmpleado
					and dpPercepciones.IDPeriodo = @IDPeriodoSeleccionado
					and dpPercepciones.IDConcepto = (Select top 1 IDConcepto from @Conceptos where Codigo = '550')
			left join [Nomina].[tblCatConceptos] CCPercepciones with (nolock)
				on CCPercepciones.IDConcepto = dpPercepciones.IDConcepto

			left join @DetallePeriodo dpDeducciones
				on e.IDEmpleado = dpDeducciones.IDEmpleado
					and dpDeducciones.IDPeriodo = @IDPeriodoSeleccionado
					and dpDeducciones.IDConcepto = (Select top 1 IDConcepto from @Conceptos where Codigo = '560')
			left join [Nomina].[tblCatConceptos] CCDeducciones
				on CCDeducciones.IDConcepto = dpDeducciones.IDConcepto
				  	
			left join @DetallePeriodo dpPago
				on e.IDEmpleado = dpPago.IDEmpleado
					and dpPago.IDPeriodo = @IDPeriodoSeleccionado
					and dpPago.IDConcepto in(Select IDConcepto from @Conceptos where IDTipoConcepto in (select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion = 'CONCEPTOS DE PAGO' ))
			left join [Nomina].[tblCatConceptos] CCPago with (nolock)
				on dpPago.IDConcepto = CCPago.IDConcepto
	
		select * from #tempListaPago

		--SUMATORIA          
		select                   
			IDPeriodo                  
			,Periodo                  
			,IDConcepto                  
			,Codigo                  
			,Concepto           
			,OrdenCalculo                  
			,IDTipoConcepto                  
			,CantidadMonto                  
			,CantidadDias                  
			,CantidadVeces                  
			,CantidadOtro1                  
			,CantidadOtro2                  
			,ImporteGravado                  
			,ImporteExcento                  
			,ImporteOtro                  
			,ImporteTotal1                 
			,ImporteTotal2                      
			,ImporteAcumuladoTotales                  
		from #tempSumatoriaPeriodo                  
		order by OrdenCalculo                  
                  
		select distinct COUNT(*)NoEmpleados from #tempListaPago            
	END                  
	ELSE                  
	BEGIN                  
		MERGE Nomina.tblDetallePeriodoFiniquito AS TARGET                  
		USING @DetallePeriodo AS SOURCE                  
			ON (TARGET.IDConcepto = SOURCE.IDConcepto                   
			and TARGET.IDEmpleado = SOURCE.IDEmpleado                  
			and TARGET.IDPeriodo = SOURCE.IDPeriodo                  
			and TARGET.Descripcion = SOURCE.Descripcion                  
			and TARGET.IDReferencia = SOURCE.IDReferencia)                  
		WHEN MATCHED Then                  
		update                  
		Set                       
			TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)                  
			,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)                  
			,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)                  
			,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)                  
			,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)                  
			,TARGET.ImporteGravado = isnull(SOURCE.ImporteGravado,0)                  
			,TARGET.ImporteExcento = isnull(SOURCE.ImporteExcento,0)                  
			,TARGET.ImporteOtro    = isnull(SOURCE.ImporteOtro   ,0)                  
			,TARGET.ImporteTotal1  = isnull(SOURCE.ImporteTotal1 ,0)                  
			,TARGET.ImporteTotal2  = isnull(SOURCE.ImporteTotal2 ,0)                  
			,TARGET.Descripcion  = SOURCE.Descripcion                  
			,TARGET.IDReferencia  = SOURCE.IDReferencia                  
                      
		WHEN NOT MATCHED BY TARGET THEN                   
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,CantidadMonto,CantidadDias,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)                  
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDConcepto                  
			,isnull(SOURCE.CantidadMonto ,0)                  
			,isnull(SOURCE.CantidadDias ,0)                  
			,isnull(SOURCE.CantidadVeces ,0)                  
			,isnull(SOURCE.CantidadOtro1 ,0)                  
			,isnull(SOURCE.CantidadOtro2 ,0)                  
			,isnull(SOURCE.ImporteGravado,0)                  
			,isnull(SOURCE.ImporteExcento,0)                  
			,isnull(SOURCE.ImporteOtro ,0)                  
			,isnull(SOURCE.ImporteTotal1 ,0)                  
			,isnull(SOURCE.ImporteTotal2 ,0)                  
			,SOURCE.Descripcion                  
			,SOURCE.IDReferencia)                  
		WHEN NOT MATCHED BY SOURCE and TARGET.IDPeriodo = @IDPeriodoSeleccionado and TARGET.IDEmpleado in (Select IDEmpleado from @Empleados) THEN                   
		DELETE;                  
                  
		if object_id('tempdb..#tempSumatoriaPeriodoFiniquito') is not null drop table #tempSumatoriaPeriodoFiniquito;                  
		
		--ARMAR SUMATORIA          
		select 
			dp.IDPeriodo                  
			,cp.Descripcion as Periodo                  
			,dp.IDConcepto                  
			,ccp.Codigo                  
			,ccp.Descripcion as Concepto                  
			,ccp.IDTipoConcepto                  
			,ccp.OrdenCalculo                  
			,'' as Descripcion--dp.Descripcion                  
			,SUM(isnull(dp.CantidadMonto,0)) as CantidadMonto                  
			,SUM(isnull(dp.CantidadDias,0)) as CantidadDias                  
			,SUM(isnull(dp.CantidadVeces,0)) as CantidadVeces                  
			,SUM(isnull(dp.CantidadOtro1,0)) as CantidadOtro1                  
			,SUM(isnull(dp.CantidadOtro2,0)) as CantidadOtro2                  
			,SUM(isnull(dp.ImporteGravado,0)) as ImporteGravado                  
			,SUM(isnull(dp.ImporteExcento,0)) as ImporteExcento                  
			,SUM(isnull(dp.ImporteOtro,0)) as ImporteOtro                  
			,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1                  
			,SUM(isnull(dp.ImporteTotal2,0)) ImporteTotal2                      
			,(SUM(isnull(dp.ImporteTotal1,0)) * SUM(isnull(dp.ImporteTotal2,0))) as ImporteAcumuladoTotales                     
		INTO #tempSumatoriaPeriodoFiniquito                  
		from @DetallePeriodo dp                
			join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo                  
			join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto                     
			join @empleados e on dp.IDEmpleado = e.IDEmpleado                  
		where cp.IDPeriodo = @IDPeriodoSeleccionado                  
		group by  dp.IDPeriodo                  
			,cp.Descripcion                   
			,dp.IDConcepto                  
			,ccp.Codigo                  
			,ccp.Descripcion                  
			,ccp.IDTipoConcepto                  
			,ccp.OrdenCalculo                  
			
		if object_id('tempdb..#tempListaPagofiniquito') is not null drop table #tempListaPagofiniquito; 

		select distinct E.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as NombreCompleto
			,isnull(dpPercepciones.ImporteTotal1,0) as TotalPercepciones 
			,isnull(dpDeducciones.ImporteTotal1,0) as TotalDeducciones 
			,isnull(dpPago.ImporteTotal1,0) as TotalPagado 
			,isnull(CCPago.Codigo,'000') +' - '+ isnull(CCPago.Descripcion,'NO ASIGNADO') as ConceptoPago
			into #tempListaPagofiniquito
		from @empleados E
			left join @DetallePeriodo dpPercepciones
				on e.IDEmpleado = dpPercepciones.IDEmpleado
					and dpPercepciones.IDPeriodo = @IDPeriodoSeleccionado
					and dpPercepciones.IDConcepto = (Select top 1 IDConcepto from @Conceptos where Codigo = '550')
			left join [Nomina].[tblCatConceptos] CCPercepciones with (nolock)
				on CCPercepciones.IDConcepto = dpPercepciones.IDConcepto

			left join @DetallePeriodo dpDeducciones
				on e.IDEmpleado = dpDeducciones.IDEmpleado
					and dpDeducciones.IDPeriodo = @IDPeriodoSeleccionado
					and dpDeducciones.IDConcepto = (Select top 1 IDConcepto from @Conceptos where Codigo = '560')
			left join [Nomina].[tblCatConceptos] CCDeducciones with (nolock)
				on CCDeducciones.IDConcepto = dpDeducciones.IDConcepto
				  	
			left join @DetallePeriodo dpPago
				on e.IDEmpleado = dpPago.IDEmpleado
					and dpPago.IDPeriodo = @IDPeriodoSeleccionado
					and dpPago.IDConcepto in(Select IDConcepto from @Conceptos where IDTipoConcepto in (select IDTipoConcepto from Nomina.tblCatTipoConcepto where Descripcion = 'CONCEPTOS DE PAGO' ))
			left join [Nomina].[tblCatConceptos] CCPago with (nolock)
				on dpPago.IDConcepto = CCPago.IDConcepto
	             
			select * from #tempListaPagofiniquito
			
			-- SUMATORIA          
			select                   
				IDPeriodo                  
				,Periodo                  
				,IDConcepto                  
				,Codigo                  
				,Concepto                   
				,OrdenCalculo                  
				,IDTipoConcepto                  
				,CantidadMonto                  
				,CantidadDias                  
				,CantidadVeces                  
				,CantidadOtro1                  
				,CantidadOtro2                  
				,ImporteGravado                  
				,ImporteExcento                  
				,ImporteOtro                  
				,ImporteTotal1                  
				,ImporteTotal2                      
				,ImporteAcumuladoTotales                  
			from #tempSumatoriaPeriodoFiniquito                  
			order by OrdenCalculo                  
                  
			select distinct COUNT(*) as NoEmpleados from #tempListaPagofiniquito     
	END

	--IF(@ExcluirBajas = 1)        
	--BEGIN  
		if (@EliminarDetallePeriodo = 1)
		BEGIN
			DELETE dp
			from Nomina.tblDetallePeriodo dp
				--join @empleados e on dp.IDEmpleado = e.IDEmpleado
			where dp.IDEmpleado in 
				(select IDEmpleado from @empleadosEliminarDelCalculo) 
					and IDPeriodo = @IDPeriodoSeleccionado 
				and dp.IDEmpleado not in (Select IDEmpleado 
										from Nomina.tblControlFiniquitos f with (nolock) 
										join Nomina.tblCatEstatusFiniquito ef with (nolock) on f.IDEStatusFiniquito = ef.IDEStatusFiniquito 
										where IDPeriodo = @IDPeriodoSeleccionado and ef.Descripcion = 'Aplicar')        

		END;
	--END
GO
