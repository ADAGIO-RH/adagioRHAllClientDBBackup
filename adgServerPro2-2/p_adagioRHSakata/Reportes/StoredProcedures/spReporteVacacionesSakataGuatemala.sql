USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteVacacionesSakataGuatemala](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

)AS

BEGIN

	DECLARE @TempVacacionesSaldos AS TABLE(
		 [IDEmpleado] INT NULL
		,[Anio] FLOAT NULL
		,[FechaIni] DATE NULL
		,[FechaFin] DATE NULL
		,[Dias] FLOAT NULL
		,[DiasGenerados] INT NULL
		,[DiasTomados] FLOAT NULL
		,[DiasVencidos] FLOAT NULL
		,[DiasDisponibles] FLOAT NULL
		,[TipoPrestacion] VARCHAR(50) NULL
		,[FechaIniDisponible] DATE NULL
		,[FechaFinDisponible] DATE NULL
	);
	
	DECLARE 
		 @Counter INT
		,@IDEmpleado INT
		,@Empleados [RH].[dtEmpleados]
	;

	INSERT INTO @Empleados
	SELECT * FROM RH.tblEmpleadosMaster WHERE IDCliente = 4

	SELECT @Counter = MIN(IDEmpleado) FROM @Empleados

	WHILE @Counter <= (SELECT MAX(IDEmpleado) FROM @Empleados)

		BEGIN
			
			SELECT @IDEmpleado = IDEmpleado FROM @Empleados WHERE IDEmpleado = @Counter

			INSERT INTO @TempVacacionesSaldos (Anio,FechaIni,FechaFin,Dias,[DiasGenerados],DiasTomados,DiasVencidoS,DiasDisponibles,TipoPrestacion,FechaIniDisponible,FechaFinDisponible)
			EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = NULL, @FechaBaja = NULL, @IDUsuario = 1

			UPDATE @TempVacacionesSaldos SET IDEmpleado = @IDEmpleado WHERE IDEmpleado IS NULL
			
			SELECT @Counter = MIN(IDEmpleado) FROM @Empleados WHERE IDEmpleado > @Counter

		END

	IF OBJECT_ID('TempDB..#TempAnios') IS NOT NULL DROP TABLE #TempAnios

	SELECT 
	     E.IDEmpleado
		,E.ClaveEmpleado AS Clave
		,E.NOMBRECOMPLETO AS Nombre
		,FORMAT(E.FechaAntiguedad,'dd/MM/yyyy') AS FechaAntiguedad
		,S.Anio AS Año
		,FORMAT(S.FechaIni,'dd/MM/yyyy') AS FechaIni
		,FORMAT(S.FechaFin,'dd/MM/yyyy') AS FechaFin
		,S.Dias
		,S.DiasTomados
		,S.DiasVencidos
		,S.DiasDisponibles
		,S.TipoPrestacion
		,FORMAT(S.FechaIniDisponible,'dd/MM/yyyy') AS FechaIniDisponible
		,FORMAT(S.FechaFinDisponible,'dd/MM/yyyy') AS FechaFinDisponible
		,FechaVencimiento = FORMAT(DATEADD(DAY,365,FechaFin),'dd/MM/yyyy')
		,CASE WHEN DATEADD(DAY,365,FechaFin) < GETDATE() THEN 'Vencido' ELSE '' END AS Estatus
	INTO #TempAnios
	FROM @TempVacacionesSaldos S
	INNER JOIN @Empleados E ON E.IDEmpleado = S.IDEmpleado
	WHERE S.DiasDisponibles <> 0

	SELECT
		 A.Clave
		,A.Nombre
		,A.FechaAntiguedad
		,CAST(A.Año AS INT) AS Año
		,A.FechaIni
		,A.FechaFin
		,CAST(A.Dias AS INT) AS Dias
		,CAST(A.DiasTomados AS INT) AS DiasTomados
		,CAST(A.DiasVencidos AS INT) AS DiasVencidos
		,A.DiasDisponibles
		,A.TipoPrestacion
		,A.FechaVencimiento
		--,A.Estatus
		--,Info = CASE WHEN A.Año IN (SELECT B.Año FROM #TempAnios B WHERE B.IDEmpleado = A.IDEmpleado AND A.Estatus = 'Vencido') THEN 'Activado Por Ajuste Saldos 31/03/2024' ELSE '' END
	FROM #TempAnios A

END
GO
