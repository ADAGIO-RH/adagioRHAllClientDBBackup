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
CREATE proc [Reportes].[spSaldosDeVacacionesNomade](
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
  
  --select * from cteAntiguedad
  --return
SELECT a.*
    ,FechaFin = CAST(DATEADD(YEAR, 1, DATEADD(DAY, -1, a.FechaIni)) AS DATE)
    ,Clientes.IDCliente
    ,Prestaciones.IDTipoPrestacion
    ,CAST(ISNULL(configClientes.Valor, 365.00) AS FLOAT) AS VacacionesCaducanEn
    ,DiasPorAnio = CASE 
                    WHEN CAST(DATEADD(YEAR, 1, DATEADD(DAY, -1, a.FechaIni)) AS DATE) > @FechaFin 
                    THEN CAST((DATEDIFF(DAY, a.FechaIni, @FechaFin) / 365.2425 * detallePrestacion.DiasVacaciones) AS DECIMAL(18, 2)) 
                    ELSE detallePrestacion.DiasVacaciones 
                   END
    ,CAST(0 AS FLOAT) AS DiasTomados
    ,CAST(0 AS FLOAT) AS DiasVencidos
    ,CAST(0 AS FLOAT) AS DiasDisponibles
    ,detallePrestacion.DiasVacaciones AS DiasPorAniosPrestacion
INTO #tempCTE
FROM cteAntiguedad a
		LEFT JOIN [RH].[tblClienteEmpleado] Clientes WITH(NOLOCK) 
			ON Clientes.IDEmpleado = a.IDEmpleado AND Clientes.FechaIni<= dateadd(year,1, dateadd(day,-1,a.FechaIni)) and Clientes.FechaFin >= dateadd(year,1, dateadd(day,-1,a.FechaIni))
		LEFT JOIN [RH].[TblConfiguracionesCliente] configClientes WITH(NOLOCK)  on configClientes.IDCliente = Clientes.IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn'
		LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) 
			ON Prestaciones.IDEmpleado = a.IDEmpleado AND Prestaciones.FechaIni<= dateadd(year,1, dateadd(day,-1,a.FechaIni)) and Prestaciones.FechaFin >= dateadd(year,1, dateadd(day,-1,a.FechaIni))
		LEFT JOIN [RH].[tblCatTiposPrestacionesDetalle] detallePrestacion WITH(NOLOCK) on detallePrestacion.IDTipoPrestacion = Prestaciones.IDTipoPrestacion and detallePrestacion.Antiguedad = a.Anio
	order by a.IDEmpleado,a.Anio
	option (maxrecursion 0)

	--select * from #tempCTE order by Anio

	update c
		set c.DiasTomados = d.Total
	from #tempCTE c
		join (
			select a.IDEmpleado,a.Anio,count(ie.IDIncidenciaEmpleado) as Total
			from Asistencia.tblIncidenciaEmpleado ie with (nolock)
				join #tempCTE a
					on ie.IDEmpleado = a.IDEmpleado and ie.Fecha between a.FechaIni and a.FechaFin
			where ie.IDIncidencia = 'V'
			group by a.IDEmpleado,a.Anio
		) d on c.IDEmpleado = d.IDEmpleado and c.Anio = d.Anio


	update #tempCTE  
	set DiasVencidos = case   
							when (DiasTomados > DiasPorAnio) then 0   
							when DATEADD(day,VacacionesCaducanEn,FechaFin) < getdate() then  DiasPorAnio - DiasTomados 
						else 0 end  
		,DiasDisponibles = 999

	SELECT 
    e.ClaveEmpleado AS CLAVE,
    e.NOMBRECOMPLETO AS NOMBRE,
    e.DEPARTAMENTO,
    e.SUCURSAL,
    e.PUESTO,
    FORMAT(CAST(e.fechaAntiguedad AS DATE), 'dd/MM/yyyy') AS FECHA_DE_ANTIGUEDAD,
    vacaciones.Anio AS [ANTIGUEDAD_AÑOS],
    vacaciones.DiasPorAniosPrestacion AS [VACACIONES_AÑO_ACTUAL],
    vacaciones.VacacionesGeneradasDesdeIngreso AS [VACACIONES_GENERADAS],
    vacaciones.DiasTomados AS [DIAS_TOMADOS],
    vacaciones.VacacionesGeneradasDesdeIngreso - vacaciones.DiasTomados AS [VACACIONES_POR_DISFRUTAR],
    vacaciones.DiasPorAnio AS [VACACIONES_PROPORCIONALES],
    vacaciones.DiasDisponibles AS [VACACIONES_CON_PROPORCION],
    FORMAT(@FechaIni, 'dd/MM/yyyy') AS [FECHA_INICIO], -- Set to user-selected start date
    FORMAT(@FechaFin, 'dd/MM/yyyy') AS [FECHA_FINAL]   -- Set to user-selected end date
FROM (
    SELECT 
        t.IDEmpleado,
        Anio = CAST((ejercicioActual.Anio - 1) + (DATEDIFF(DAY, ejercicioActual.FechaIni, @FechaFin) / 365.2425) AS DECIMAL(18, 2)),
        @FechaIni AS FechaIni,  -- Use the user-selected start date
        @FechaFin AS FechaFin,  -- Use the user-selected end date
        SUM(t.DiasPorAnio) - ejercicioActual.DiasPorAnio AS VacacionesGeneradasDesdeIngreso,
        SUM(DiasTomados) AS DiasTomados,
        DiasDisponibles = SUM(t.DiasPorAnio) - SUM(DiasTomados),
        ProporcionAlDiaDeHoy = CAST((DATEDIFF(DAY, @FechaIni, @FechaFin) / 365.2425 * ejercicioActual.DiasPorAnio) AS DECIMAL(18, 2)),
        ejercicioActual.DiasPorAnio,
        ejercicioActual.DiasTomadosAnioActual,
        ejercicioActual.DiasPorAniosPrestacion
    FROM #tempCTE t
    LEFT JOIN (
        SELECT 
            anios.IDEmpleado,
            anios.Anio,
            @FechaIni AS FechaIni,  -- Use the user-selected start date
            @FechaFin AS FechaFin,  -- Use the user-selected end date
            anios.DiasPorAnio,
            anios.DiasPorAniosPrestacion,
            anios.DiasTomados AS DiasTomadosAnioActual,
            ROW_NUMBER() OVER (PARTITION BY IDEmpleado ORDER BY Anio DESC) AS [Row]
        FROM #tempCTE anios
        WHERE anios.FechaIni >= @FechaIni AND anios.FechaFin <= @FechaFin
    ) ejercicioActual 
    ON t.IDEmpleado = ejercicioActual.IDEmpleado AND ejercicioActual.[Row] = 1
    WHERE ejercicioActual.FechaIni >= @FechaIni AND ejercicioActual.FechaFin <= @FechaFin
    GROUP BY 
        t.IDEmpleado, 
        ejercicioActual.Anio, 
        ejercicioActual.DiasPorAnio, 
        ejercicioActual.DiasTomadosAnioActual, 
        ejercicioActual.DiasPorAniosPrestacion
) vacaciones
JOIN @empleados e ON vacaciones.IDEmpleado = e.IDEmpleado
ORDER BY e.ClaveEmpleado, vacaciones.Anio ASC;
GO
