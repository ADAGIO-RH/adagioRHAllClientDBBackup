USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Calcula el historial de saldos de vacaciones de un colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2019-01-01  
** Paremetros  :                
  
 Si se modifica el result set de este sp será necesario modificar los siguientes SP's:  
  [Asistencia].[spBuscarVacacionesPendientesEmpleado]  
  
** DataTypes Relacionados:   [Asistencia].[dtSaldosDeVacaciones]  
  
  select * from RH.tblEmpleadosMaster where claveEmpleado= 'adg0001'
[Asistencia].[spBuscarSaldosVacacionesPorAnios] 1279,1,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2021-11-30				Aneudy Abreu	Se agrega validación para cuando el colaborador tiene más
										de una Prestación
2022-01-01				Aneudy Abreu	Se agregó validación del historial de prestaciones
2022-01-01				Julio Castillo	Se agregó el parámetro de FechaBaja
***************************************************************************************************/ 
CREATE proc [Reportes].[spSaldosDeVacacionesCustomNomadeVACAS](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
		-- Parámetros
	--declare 
	--	@dtFiltros Nomina.dtFiltrosRH		
	--	,@IDUsuario int = 1
	--;

	--insert @dtFiltros
	--values
	--	('ClaveEmpleadoInicial','03001')
	--	,('ClaveEmpleadoFinal','03001')
	--	,('FechaIni','2021-03-19')
	--	,('FechaFin','2021-03-19')

	declare 
		 @empleados RH.dtEmpleados
		,@FechaIni date --= '2010-01-20'
		,@FechaFin date	--= '2021-01-20'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		,@IDTipoNomina int  
		
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
	SET @IDTipoNomina	= ISNULL((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)    

	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())

	if object_id('tempdb..#tempVacacionesTomadas') is not null drop table #tempVacacionesTomadas;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;  

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario


	--SELECT @FECHAFIN
	;with cteAntiguedad(IDEmpleado,Anio, FechaIni) AS  
    (  
		SELECT IDEmpleado,cast(1.0 as float),FechaAntiguedad
		from @empleados
		UNION ALL  
		SELECT IDEmpleado, Anio + 1.0,dateadd(year,1,FechaIni)  
		FROM cteAntiguedad 
		WHERE Anio <= (select (DATEDIFF(day,FechaAntiguedad,@FechaFin) / 365.2425)
						from @empleados 
						where IDEmpleado = cteAntiguedad.IDEmpleado) -- how many times to iterate  
    )
  


	select a.*
	  ,FechaFin = case when cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) > cast(getdate() as date) then cast(getdate() as date) else cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) end
	     -- ,FechaFin=cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date)
		--,FechaFin = case when cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) > cast(getdate() as date) then cast(getdate() as date) else cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) end
		,Clientes.IDCliente
		,Prestaciones.IDTipoPrestacion
		,cast(isnull(configClientes.Valor,365.00) as Float) VacacionesCaducanEn
		,DiasPorAnio = case when cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) > @FechaFin then cast((datediff(day,a.FechaIni,@FechaFin)/365.2425 * detallePrestacion.DiasVacaciones) as decimal(18,2)) else detallePrestacion.DiasVacaciones end 
		,cast(0 as float) as DiasTomados  
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,detallePrestacion.DiasVacaciones as DiasPorAniosPrestacion
	INTO #tempCTE  
	from cteAntiguedad a
		LEFT JOIN [RH].[tblClienteEmpleado] Clientes WITH(NOLOCK) 
			ON Clientes.IDEmpleado = a.IDEmpleado AND Clientes.FechaIni<= dateadd(year,1, dateadd(day,-1,a.FechaIni)) and Clientes.FechaFin >= dateadd(year,1, dateadd(day,-1,a.FechaIni))
		LEFT JOIN [RH].[TblConfiguracionesCliente] configClientes WITH(NOLOCK)  on configClientes.IDCliente = Clientes.IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn'
		LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) 
			ON Prestaciones.IDEmpleado = a.IDEmpleado AND Prestaciones.FechaIni<= dateadd(year,1, dateadd(day,-1,a.FechaIni)) and Prestaciones.FechaFin >= dateadd(year,1, dateadd(day,-1,a.FechaIni))
		LEFT JOIN [RH].[tblCatTiposPrestacionesDetalle] detallePrestacion WITH(NOLOCK) on detallePrestacion.IDTipoPrestacion = Prestaciones.IDTipoPrestacion and detallePrestacion.Antiguedad = a.Anio
	order by a.IDEmpleado,a.Anio
	option (maxrecursion 0)

	
	--select * from #tempCTE order by Anio
	--return

	--	select a.IDEmpleado,a.Anio,count(ie.IDIncidenciaEmpleado) as Total
	--		from Asistencia.tblIncidenciaEmpleado ie with (nolock)
	--			join #tempCTE a
	--				on ie.IDEmpleado = a.IDEmpleado and ie.Fecha between a.FechaIni and @FechaFin
	--		where ie.IDIncidencia = 'V'
	--		group by a.IDEmpleado,a.Anio



	--select a.IDEmpleado,a.Anio,ie.IDIncidenciaEmpleado,ie.Fecha as Total
	--		from Asistencia.tblIncidenciaEmpleado ie with (nolock)
	--			join #tempCTE a
	--				on ie.IDEmpleado = a.IDEmpleado and ie.Fecha between a.FechaIni and a.FechaFin   -- personalizado
	--		where ie.IDIncidencia = 'V'
	--		group by a.IDEmpleado,a.Anio,ie.IDIncidenciaEmpleado,ie.Fecha

	update c
		set c.DiasTomados = d.Total
	from #tempCTE c
		join (
			select a.IDEmpleado,a.Anio,count(ie.IDIncidenciaEmpleado) as Total
			from Asistencia.tblIncidenciaEmpleado ie with (nolock)
				join #tempCTE a
					on ie.IDEmpleado = a.IDEmpleado and ie.Fecha between a.FechaIni and a.FechaFin   -- personalizado
			where ie.IDIncidencia = 'V'
			group by a.IDEmpleado,a.Anio
		) d on c.IDEmpleado = d.IDEmpleado and c.Anio = d.Anio






	--select * from #tempCTE order by Anio

	--	RETURN
	update #tempCTE  
	set DiasVencidos = case   
							when (DiasTomados > DiasPorAnio) then 0   
							when DATEADD(day,VacacionesCaducanEn,FechaFin) < getdate() then  DiasPorAnio - DiasTomados 
						else 0 end  
		,DiasDisponibles = 999


		select*from #tempCTE return

	select 
		 e.ClaveEmpleado as CLAVE
		,e.NOMBRECOMPLETO as NOMBRE
		,e.DEPARTAMENTO
		,e.SUCURSAL
		,e.PUESTO
		--,e.DIVISION
		,FORMAT(CAST(e.fechaAntiguedad AS DATE),'dd/MM/yyyy') as FECHA_DE_ANTIGUEDAD
		,FORMAT(CAST(@FechaFin AS DATE),'dd/MM/yyyy') AS [FechaFin]
		,vacaciones.Anio							AS [ANTIGUEDAD_AÑOS]
		,vacaciones.ProporcionAlDiaDeHoy 	 AS [VACACIONES_GENERADAS]
		,vacaciones.DiasTomados						AS [DIAS_TOMADOS]
		,(vacaciones.VacacionesGeneradasDesdeIngreso + vacaciones.DiasPorAniosPrestacion) - vacaciones.DiasTomados AS [VACACIONES_POR_DISFRUTAR]
		,vacaciones.DiasPorAniosPrestacion			AS [VACACIONES_AÑO_ACTUAL]
		,vacaciones.DiasPorAnio						AS [VACACIONES_PROPORCIONALES_ANIO_ACTUAL]
		--,vacaciones.DiasDisponibles					AS [VACACIONES_CON_PROPORCION]
	
				--,vacaciones.DiasTomadosAnioActual
	from (
		select t.IDEmpleado
	 
			--,t.IDCliente
			--,t.IDTipoPrestacion
			,Anio = cast((ejercicioActual.Anio - 1)+(datediff(day,ejercicioActual.FechaIni,@FechaFin)/365.4) as decimal(18,2))
			,ejercicioActual.FechaIni
			,ejercicioActual.FechaFin
			,SUM(t.DiasPorAnio)-ejercicioActual.DiasPorAnio as VacacionesGeneradasDesdeIngreso
			,SUM(DiasTomados) as DiasTomados
			, DiasDisponibles = SUM(t.DiasPorAnio) - SUM(DiasTomados)
			,ProporcionAlDiaDeHoy = ejercicioActual.DiasPorAnio 
			,ejercicioActual.DiasPorAnio
			,ejercicioActual.DiasTomadosAnioActual
			,ejercicioActual.DiasPorAniosPrestacion

		from #tempCTE t
			left join (
				select 
					anios.IDEmpleado
					,anios.Anio
					,anios.FechaIni
					,anios.FechaFin
					--,FechaFin = case when anios.FechaFin > cast(getdate() as date) then cast(getdate() as date) else anios.FechaFin end
					,anios.DiasPorAnio
					,anios.DiasPorAniosPrestacion
					,anios.DiasTomados as DiasTomadosAnioActual
					,ROW_NUMBER()OVER(partition By IDEmpleado order by Anio desc) as [Row]
				from #tempCTE anios
			) ejercicioActual on t.IDEmpleado = ejercicioActual.IDEmpleado and ejercicioActual.[Row] = 1
		group by t.IDEmpleado,ejercicioActual.Anio,ejercicioActual.FechaIni,ejercicioActual.FechaFin,ejercicioActual.DiasPorAnio,ejercicioActual.DiasTomadosAnioActual, ejercicioActual.DiasPorAniosPrestacion
	) vacaciones
		join @empleados e on vacaciones.IDEmpleado = e.IDEmpleado
	order by e.ClaveEmpleado, vacaciones.Anio asc


GO
