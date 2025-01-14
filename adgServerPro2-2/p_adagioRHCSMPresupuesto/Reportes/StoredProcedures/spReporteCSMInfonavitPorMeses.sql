USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteCSMInfonavitPorMeses](        
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int        
) as        
    
	--declare    
	--  @dtFiltros Nomina.dtFiltrosRH     
	--  ,@IDUsuario int = 1    
    
    
	--  insert @dtFiltros    
	--  Values    
	--  --('Departamentos','5')    
	--  --,    
	--  ('IDTipoNomina','4')    
	--  ,('IDPeriodoInicial','76')    
        
	declare 
		@empleados [RH].[dtEmpleados]            
		,@IDPeriodoSeleccionado int=0            
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]            
		,@IDTipoNomina int         
		,@fechaIniPeriodo  date            
		,@fechaFinPeriodo  date 
		,@ConceptoInfonavit varchar(10) = '304'
		,@IDConceptoInfonavit int 
		,@ConceptoSeguro varchar(10) = '305'
		,@IDConceptoSeguro int 


	;        

	select @IDConceptoInfonavit	= IDConcepto from Nomina.tblCatConceptos with(nolock) where Codigo = @ConceptoInfonavit
	select @IDConceptoSeguro	= IDConcepto from Nomina.tblCatConceptos with(nolock) where Codigo = @ConceptoSeguro

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
						else 0  
	END  
      
	/* Se buscan el periodo seleccionado */        
	insert into @periodo      
	select   *    
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
	from Nomina.tblCatPeriodos With (nolock)      
	where      
		(((IDTipoNomina in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoNomina' and isnull(Value,'')<>''))  
		)                       
		and (IDMes between (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
			and (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),','))
		)   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))                      
    
	select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */            
    insert into @empleados            
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario         



	Select e.ClaveEmpleado as CLAVE
		,e.NOMBRECOMPLETO as NOMBRE
		,e.Departamento AS DEPARTAMENTO
		,e.Sucursal as SUCURSAL
		,e.Puesto as PUESTO
		,e.ClasificacionCorporativa as [CLASIFICACION CORPORATIVA]
		,SUM(CASE WHEN C.IDConcepto = @IDConceptoInfonavit then dp.ImporteTotal1 else 0 end) as INFONAVIT
		,SUM(CASE WHEN C.IDConcepto = @IDConceptoSeguro then dp.ImporteTotal1 else 0 end) as [SEGURO INFONAVIT]
		,SUM(CASE WHEN C.IDConcepto = @IDConceptoInfonavit then dp.ImporteTotal1 else 0 end)+SUM(CASE WHEN C.IDConcepto = @IDConceptoSeguro then dp.ImporteTotal1 else 0 end) AS TOTAL
	from Nomina.tblDetallePeriodo dp with(Nolock)
		inner join @periodo P
			on dp.IDPeriodo = p.IDPeriodo
		inner join Nomina.tblCatConceptos c with(nolock)
			on dp.IDConcepto = c.IDConcepto
			and c.IDConcepto in (@IDConceptoInfonavit,@IDConceptoSeguro)
		inner join @empleados e
			on e.IDEmpleado = dp.IDEmpleado
	GROUP BY e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.ClasificacionCorporativa
	ORDER BY e.ClaveEmpleado

GO
