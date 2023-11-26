USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoCambiosDeDepartamentoNexus](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)
as
	declare 
		@empleados RH.dtEmpleados
		,@FechaIni date --= '2010-01-20'
		,@FechaFin date	--= '2020-01-20'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		
		,@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null    
	;

	SET DATEFIRST 7;      
      
	select top 1 
		@IDIdioma = dp.Valor      
	from Seguridad.tblUsuarios u with (nolock)     
		Inner join App.tblPreferencias p with (nolock)      
			on u.IDPreferencia = p.IDPreferencia      
		Inner join App.tblDetallePreferencias dp with (nolock)      
			on dp.IDPreferencia = p.IDPreferencia      
		Inner join App.tblCatTiposPreferencias tp with (nolock)      
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia      
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'      
      
	select @IdiomaSQL = [SQL]      
	from app.tblIdiomas with (nolock)      
	where IDIdioma = @IDIdioma      
      
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
	begin      
		set @IdiomaSQL = 'Spanish' ;      
	end      
        
	SET LANGUAGE @IdiomaSQL;  

	SET @FechaIni		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)    
	SET @FechaFin		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)  
	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')   

	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())
	
	insert @empleados
	exec RH.spBuscarEmpleados 
		@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@FechaIni		= @FechaIni
		,@FechaFin		= @FechaFin
		,@dtFiltros		= @dtFiltros
		,@IDUsuario		= @IDUsuario

	if object_id('tempdb..#tempDepartamentoActual') is not null drop table #tempDepartamentoActual;
	if object_id('tempdb..#tempDepartamentoAnterior') is not null drop table #tempDepartamentoAnterior;

	select e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Division
		,pe.*
		,p.Codigo as CodigoDepartamentoActual
		,p.Descripcion as DepartamentoActual
	INTO #tempDepartamentoActual
	from RH.tblDepartamentoEmpleado pe
		join @empleados e on pe.IDEmpleado = e.IDEmpleado
		join RH.tblCatDepartamentos p on pe.IDDepartamento = p.IDDepartamento
		left join (
			select m.*,tm.Descripcion as TipoMov
			from IMSS.tblMovAfiliatorios m
				join IMSS.tblCatTipoMovimientos tm on m.IDTipoMovimiento = tm.IDTipoMovimiento
			where tm.Codigo in ('A','R')
		) mov on pe.IDEmpleado = mov.IDEmpleado and pe.FechaIni = mov.Fecha	
	where pe.FechaIni between @FechaIni and @FechaFin and mov.IDMovAfiliatorio is null
	order by e.ClaveEmpleado

	select e.ClaveEmpleado
		,pe.*
		,p.Codigo as CodigoDepartamentoAnterior
		,p.Descripcion as [DepartamentoAnterior]
	INTO #tempDepartamentoAnterior
	from RH.tblDepartamentoEmpleado pe
		join @empleados e on pe.IDEmpleado = e.IDEmpleado
		join #tempDepartamentoActual temp on pe.IDEmpleado = temp.IDEmpleado
		join RH.tblCatCentroCosto p on pe.IDDepartamento = p.IDCentroCosto
	where cast(dateadd(day,-1,temp.FechaIni) as date) between pe.FechaIni and pe.FechaFin
	order by e.ClaveEmpleado
	
	select actual.ClaveEmpleado
		,actual.NOMBRECOMPLETO as Nombre
		,actual.Departamento
		,actual.Division
		,anterior.CodigoDepartamentoAnterior	--as [Código del Puesto Anterior]
		,anterior.DepartamentoAnterior		--as [Puesto Anterior]
		,actual.CodigoDepartamentoActual		--as [Código del Puesto Actual]
		,actual.DepartamentoActual			--as [Puesto Actual]
		,format(actual.FechaIni,'dd/MM/yyyy') as FechaInicial
		,format(actual.FechaFin,'dd/MM/yyyy') as FechaFin
	from #tempDepartamentoActual actual
		join #tempDepartamentoAnterior anterior on actual.IDEmpleado = anterior.IDEmpleado
	order by actual.ClaveEmpleado
GO
