USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoDeNominaPeriodoTotalesAguinaldo](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
--select * from Nomina.tblCatPeriodos
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int
	--insert @dtFiltros
	--values ('TipoNomina',4)
	--	  ,('IDPeriodoInicial',29)

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDCliente int
		,@Cerrado bit = 1
		,@Ejercicio int
		,@fechaIni  date        
		,@fechaFin  date  
		,@FechaIniVigencia date
		,@FechaFinVigencia date
	;  

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
											else 0 END
									
	set @Ejercicio = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))  
					  else DATEPART(YEAR, GETDATE()) 
					END  
	set @fechaIni = cast(@Ejercicio as varchar(4))+'-01-01';
	set @fechaFin = cast(@Ejercicio as varchar(4))+'-12-31';
  
	set @FechaIniVigencia = case when exists (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) THEN (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))  
					  else getdate() 
					END  
	set @FechaFinVigencia = case when exists (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) THEN (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))  
					  else getdate() 
					END  
					

	Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	
	insert into @periodo
	select *
		--IDPeriodo
		--,IDTipoNomina
		--,Ejercicio
		--,ClavePeriodo
		--,Descripcion
		--,FechaInicioPago
		--,FechaFinPago
		--,FechaInicioIncidencia
		--,FechaFinIncidencia
		--,Dias
		--,AnioInicio
		--,AnioFin
		--,MesInicio
		--,MesFin
		--,IDMes
		--,BimestreInicio
		--,BimestreFin
		--,Cerrado
		--,General
		--,Finiquito
		--,isnull(Especial,0)
	from Nomina.tblCatPeriodos with (nolock)
	where IDTipoNomina = @IDTipoNomina and IDPeriodo = @IDPeriodoInicial

	select 
		@fechaIniPeriodo = FechaInicioPago
		,@fechaFinPeriodo = FechaFinPago 
		,@IDTipoNomina = IDTipoNomina 
		,@Cerrado = Cerrado 
	from @periodo
	where IDPeriodo = @IDPeriodoInicial

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = @IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
order by IDEmpleado


	--		select e.*
	--from RH.tblEmpleadosMaster e with (nolock)
	--	join ( select distinct dp.IDEmpleado
	--			from Nomina.tblDetallePeriodo dp with (nolock)
	--			where dp.IDPeriodo = @IDPeriodoInicial
	--	) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
		
    --insert into @empleados      
    --exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(cc.Descripcion		,e.CentroCosto	)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(d.Descripcion		,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
				,e.Puesto			= isnull(p.Descripcion		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(c.NombreComercial	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(a.Descripcion		,e.Area			)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(div.Descripcion	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(r.Descripcion		,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)

		from @empleadosTemp e
			join ( select hep.*
					from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
						join @periodo p on hep.IDPeriodo = p.IDPeriodo
				) historiales on e.IDEmpleado = historiales.IDEmpleado
			left join RH.tblCatCentroCosto cc		with(nolock) on cc.IDCentroCosto = historiales.IDCentroCosto
		 	left join RH.tblCatDepartamentos d		with(nolock) on d.IDDepartamento = historiales.IDDepartamento
			left join RH.tblCatSucursales s			with(nolock) on s.IDSucursal		= historiales.IDSucursal
			left join RH.tblCatPuestos p			with(nolock) on p.IDPuesto			= historiales.IDPuesto
			left join RH.tblCatRegPatronal rp		with(nolock) on rp.IDRegPatronal	= historiales.IDRegPatronal
			left join RH.tblCatClientes c			with(nolock) on c.IDCliente		= historiales.IDCliente
			left join RH.tblEmpresa emp				with(nolock) on emp.IDEmpresa	= historiales.IDEmpresa
			left join RH.tblCatArea a				with(nolock) on a.IDArea		= historiales.IDArea
			left join RH.tblCatDivisiones div		with(nolock) on div.IDDivision	= historiales.IDDivision
			left join RH.tblCatRegiones r			with(nolock) on r.IDRegion		= historiales.IDRegion
			left join RH.tblCatRazonesSociales rs	with(nolock) on rs.IDRazonSocial = historiales.IDRazonSocial
			left join RH.tblCatClasificacionesCorporativas clasificacionC with(nolock)	on clasificacionC.IDClasificacionCorporativa = historiales.IDClasificacionCorporativa

	end;
	
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData') is not null drop table #tempData
	if object_id('tempdb..#tempData2') is not null drop table #tempData2
	if object_id('tempdb..#tempData3') is not null drop table #tempData3
	if object_id('tempdb..#TempDatosAguinaldo') is not null drop table #TempDatosAguinaldo
	if object_id('tempdb..#TempData4') is not null drop table #TempData4

	select distinct 
		c.IDConcepto,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto,
		c.Orden as OrdenCalculo,
		case when c.IDTipoConcepto in (1,4) then 1
			 when c.IDTipoConcepto = 2 then 2
			 when c.IDTipoConcepto = 3 then 3
			 when c.IDTipoConcepto = 6 then 4
			 when c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn
	into #tempConceptos
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		where ccc.Codigo in ('700','701','702','703','704','799','901','904','903','550','560','301','301A','130')
		) c 

		update #tempConceptos set Concepto =  REPLACE(concepto,'TOTAL_','')

		--select * from #tempConceptos
		--return
	
	Select
		e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.TipoNomina AS [TIPO NOMINA]
		,e.Empresa			as RAZON_SOCIAL
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as CENTRO_COSTO
		,e.Area				as AREA
		,c.Concepto
		,c.OrdenCalculo
		,e.IDEmpleado
		,UPPER(isnull(Timbrado.UUID,'')) as UUID
		,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
		,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = p.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
	where c.IDConcepto Not in (87)
	Group by 
		e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.TipoNomina
		,c.Concepto
		,c.OrdenCalculo
		,e.Empresa
		,e.Sucursal 
		,e.Departamento
		,e.Puesto
		,e.Division
		,e.CentroCosto
		,e.Area
		,Timbrado.UUID
		,Estatustimbrado.Descripcion
		,Timbrado.Fecha
	ORDER BY e.ClaveEmpleado ASC

	select
		  Empleados.IDEmpleado
		, [Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin) as [ANIOS CUMPLIDOS]
		, CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin) + 1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+ 1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END [DIAS TRABAJADOS EJERCICIO]
		, [DIAS A PAGAR] = ((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END))

		,[DIAS A PAGAR AGUINALDO] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END
			   ))

		,[SALARIO DIARIO] = Empleados.SalarioDiario

		,[SALARIO DIARIO REAL] = Empleados.SalarioDiarioReal


		into #TempDatosAguinaldo
	from @empleados Empleados
		left join RH.tblCatDepartamentos depto with(nolock)
			on Empleados.IDDepartamento = depto.IDDepartamento
		left join RH.tblCatSucursales Suc with(nolock)
			on Empleados.IDSucursal = Suc.IDSucursal
		left join RH.tblCatPuestos Puestos with(nolock)
			on Empleados.IDPuesto = Puestos.IDPuesto
		left join RH.tblCatTiposPrestaciones TP with(nolock)
			on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD
			on Empleados.IDTipoPrestacion = TPD.IDTipoPrestacion
			and TPD.Antiguedad = CEILING([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)) 
	ORDER BY Empleados.ClaveEmpleado ASC



	Select
		e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.TipoNomina AS [TIPO NOMINA]
		,e.Empresa			as RAZON_SOCIAL
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as CENTRO_COSTO
		,e.Area				as AREA
		,e.IDEmpleado
		,'TOTAL_DEDUCCIONES' as Concepto
		,'1' as OrdenCalculo
		,UPPER(isnull(Timbrado.UUID,'')) as UUID
		,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
		,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		--,SUM(isnull(dp2.ImporteTotal1,0))
		,(isnull(dp2.ImporteTotal1,0))-(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData2
	from @empleados e
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on e.IDEmpleado = dp.IDEmpleado and dp.IDConcepto = 87
		inner join Nomina.tblDetallePeriodo dp2 with (nolock) 
			on e.IDEmpleado = dp2.IDEmpleado and dp2.IDConcepto = 106
		left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = dp.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1    
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado 
	where (dp.IDPeriodo in (select IDPeriodo from @periodo)) and (dp2.IDPeriodo in (select IDPeriodo from @periodo))
	--Group by 
	--	e.ClaveEmpleado
	--	,e.NOMBRECOMPLETO
	--	,c.Codigo
	--	,c.OrdenCalculo
	--	,e.Empresa
	--	,e.Sucursal 
	--	,e.Departamento
	--	,e.Puesto
	--	,e.Division
	--	,e.CentroCosto
	--	,Timbrado.UUID
	--	,Estatustimbrado.Descripcion
	--	,Timbrado.Fecha
	--ORDER BY e.ClaveEmpleado ASC


	select tabla.* 
	into #TempData3
	from(select CLAVE
			,idempleado
			,Nombre
			,[TIPO NOMINA]
			, Concepto
			,RAZON_SOCIAL
			, SUCURSAL
			, AREA
			, PUESTO
			, DIVISION
			, CENTRO_COSTO
			, UUID
			, Estatus_Timbrado
			, Fecha_Timbrado
			, isnull(ROUND(ImporteTotal1,0),0) as ImporteTotal1
		from #tempData
		union all
		select CLAVE
		    ,idempleado
			,Nombre
			,[TIPO NOMINA]
			, Concepto
			,RAZON_SOCIAL
			, SUCURSAL
			, AREA
			, PUESTO
			, DIVISION
			, CENTRO_COSTO
			, UUID
			, Estatus_Timbrado
			, Fecha_Timbrado
			, isnull(ROUND(ImporteTotal1,0),0) as ImporteTotal1
		from #tempData2) tabla

		select td3.*,
			tda.[ANIOS CUMPLIDOS], 
			tda.[DIAS A PAGAR],
			tda.[DIAS A PAGAR AGUINALDO],
			tda.[DIAS TRABAJADOS EJERCICIO],
			tda.[SALARIO DIARIO],
			tda.[SALARIO DIARIO REAL]
		into #TempData4  from #tempdata3 as td3 
			left join #TempDatosAguinaldo tda 
		on tda.IDEmpleado = td3.IDEmpleado
		

		--select * from #tempData
		--return

		insert into #tempConceptos(IDConcepto,Concepto,IDTipoConcepto,TipoConcepto,OrdenCalculo,OrdenColumn)
		values(87106,'TOTAL_DEDUCCIONES',6,'INFORMATIVO',117,3)

		update #tempConceptos set OrdenCalculo = 140 where IDConcepto = 120 --se cambia el orden  se cambia el orden  uno despues
		update #tempConceptos set OrdenCalculo = 139 where IDConcepto = 158 --se cambia el orden a uno antes


	DECLARE @cols AS NVARCHAR(MAX),
		@query1  AS NVARCHAR(MAX),
		@query2  AS NVARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenCalculo,c.OrdenColumn
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenCalculo,c.OrdenColumn
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	set @query1 = 'SELECT CLAVE,NOMBRE,[TIPO NOMINA], RAZON_SOCIAL, SUCURSAL,PUESTO,[ANIOS CUMPLIDOS],[DIAS A PAGAR],[DIAS A PAGAR AGUINALDO],[DIAS TRABAJADOS EJERCICIO]
		,[SALARIO DIARIO],[SALARIO DIARIO REAL],' + @cols + ' from 
				(
					select CLAVE
						,Nombre
						,[TIPO NOMINA]
						, Concepto
						,RAZON_SOCIAL
						, SUCURSAL
						, PUESTO
						,[ANIOS CUMPLIDOS]
						,[DIAS A PAGAR]
						,[DIAS A PAGAR AGUINALDO]
						,[DIAS TRABAJADOS EJERCICIO]
						,[SALARIO DIARIO]
						,[SALARIO DIARIO REAL]
						, UUID
						, Estatus_Timbrado
						, Fecha_Timbrado
						, isnull(ImporteTotal1,0) as ImporteTotal1
					from #tempData4
					
			   ) x'

	set @query2 = '
				pivot 
				(
					 SUM(ImporteTotal1)
					for Concepto in (' + @colsAlone + ')
				) p 
				order by CLAVE
				'

	exec( @query1 + @query2)
GO
