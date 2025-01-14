USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoDeNominaISNCSM](
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
		,@IDConcepto540 int
        ,@IDRegistroPatronal int
        ,@IDClasificacionCorporativa int
	;  

	select @IDConcepto540 = IDConcepto from Nomina.tblCatConceptos where Codigo = '540'  

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END

     set @IDRegistroPatronal = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))  
						else 0 END   

     set @IDClasificacionCorporativa = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),','))  
						else 0 END                 


	--Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
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
	--where IDTipoNomina = @IDTipoNomina and IDPeriodo = @IDPeriodoInicial
	where   
		
		(IDTipoNomina in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoNomina' and isnull(Value,'')<>''))  )                       
		and (IDMes = (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),',')))
		and (Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')))  
		and Cerrado = 1

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
order by IDEmpleado


	
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@IDTipoNomina	= @IDTipoNomina,
		--@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario

		

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData') is not null drop table #tempData
	if object_id('tempdb..#tempTotal') is not null drop table #tempTotal
	if object_id('tempdb..#tempISN') is not null drop table #tempISN

	
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
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto --and crr.Impresion = 1
			where ccc.IDTipoConcepto = 1 --OR CCC.IDConcepto = @IDConcepto540
			and ccc.IDConcepto not in (select item from app.Split( (select top 1 IDConceptos from Nomina.tblConfigISN where IDEstado = 14),','))
		) c 
	

	Select
		e.IDEmpleado
		,e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		--,e.Empresa			as RAZON_SOCIAL
		--,e.Sucursal			as SUCURSAL
		--,e.Departamento		as DEPARTAMENTO
		--,e.Puesto			as PUESTO
		--,e.Division			as DIVISION
		--,e.CentroCosto		as CENTRO_COSTO
		--,e.ClasificacionCorporativa		as CLASIFICACION_CORPORATIVA
		,c.IDConcepto
		,c.Concepto
		,c.OrdenCalculo
		--,UPPER(isnull(Timbrado.UUID,'')) as UUID
		--,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
		--,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
		
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
        inner join nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDEmpleado=e.IDEmpleado and hist.IDPeriodo=p.IDPeriodo
        where hist.IDRegPatronal=@IDRegistroPatronal or hist.IDClasificacionCorporativa = @IDClasificacionCorporativa
	
		--left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
		--	on Historial.IDPeriodo = p.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		--LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
		--	on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		--LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
		--	on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
	
	Group by 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,c.Concepto
		,c.OrdenCalculo
		,e.IDEmpleado
		,c.IDConcepto
		--,e.Empresa
		--,e.Sucursal 
		--,e.Departamento
		--,e.Puesto
		--,e.ClasificacionCorporativa
		--,e.Division
		--,e.CentroCosto
		--,Timbrado.UUID
		--,Estatustimbrado.Descripcion
		--,Timbrado.Fecha
	ORDER BY e.ClaveEmpleado ASC

	delete c from #tempConceptos c
		where c.IDConcepto not in (select IDConcepto from #tempData where isnull(ImporteTotal1,0) > 0 )

	
	Select
		e.IDEmpleado
		,e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,'TOTAL_PERCEPCIONES-000' as Concepto
		,99 as OrdenCalculo
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
		
	into #tempTotal
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
        inner join nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDEmpleado=e.IDEmpleado and hist.IDPeriodo=p.IDPeriodo
        where hist.IDRegPatronal=@IDRegistroPatronal  or hist.IDClasificacionCorporativa = @IDClasificacionCorporativa  
	Group by 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
	 , e.IDEmpleado
	ORDER BY e.ClaveEmpleado ASC

	Select
		e.IDEmpleado
		,e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,'ISN_540' as Concepto
		,100 as OrdenCalculo
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
		
	into #tempISN
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
			and dp.IDConcepto = @IDConcepto540
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
        inner join nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDEmpleado=e.IDEmpleado and hist.IDPeriodo=p.IDPeriodo
        where hist.IDRegPatronal=@IDRegistroPatronal   or hist.IDClasificacionCorporativa = @IDClasificacionCorporativa     
            
	
	Group by 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
	    , e.IDEmpleado
	ORDER BY e.ClaveEmpleado ASC



	--select * from #tempISN

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

	set @query1 = 'SELECT CLAVE,NOMBRE,' + @cols + ',TOTAL,TOTAL_ISN from 
				(
					select d.CLAVE
						,d.Nombre
						,d.Concepto
						
						, isnull(d.ImporteTotal1,0) as ImporteTotal1
						,isnull(t.ImporteTotal1,0) as TOTAL
						,isnull(I.ImporteTotal1,0) as TOTAL_ISN
						
					from #tempData d
					join #tempTotal t on d.IDEmpleado = t.IDEmpleado
					join #tempISN I on D.IDEmpleado = I.IDEmpleado
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
