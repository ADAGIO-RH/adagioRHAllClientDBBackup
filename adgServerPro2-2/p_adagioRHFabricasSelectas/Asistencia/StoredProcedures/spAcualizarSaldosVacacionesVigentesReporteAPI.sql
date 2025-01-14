USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Asistencia].[spAcualizarSaldosVacacionesVigentesReporteAPI](


	 @FechaIni DATE = '1900-01-01'
	,@FechaFin DATE = '9999-12-31'
	,@ClaveEmpleadoInicial VARCHAR(20) = '0'
	,@ClaveEmpleadoFinal VARCHAR(20) = 'ZZZZZZZZZZZZZZZZZZZZ'


)
AS

BEGIN

		SET NOCOUNT ON;


		SELECT @FechaIni = CASE WHEN @FechaIni = '1900-01-01' THEN GETDATE() ELSE @FechaIni END
		SELECT @FechaFin = CASE WHEN @FechaFin = '9999-12-31' THEN GETDATE() ELSE @FechaFin END


		DECLARE
			 @IDEmpleado INT
			,@IDUsuario INT = 1
			,@Empleados [RH].[dtEmpleados]
			,@SaldosVacaciones [Asistencia].[dtSaldosDeVacaciones]
			,@Filtros [Nomina].[dtFiltrosRH]


		IF OBJECT_ID('TempDB..#TempSaldos') IS NOT NULL DROP TABLE #TempSaldos
		IF OBJECT_ID('TempDB..#TempSaldosFinal') IS NOT NULL DROP TABLE #TempSaldosFinal

		CREATE TABLE #TempSaldos
		(
			 IDEmpleado INT
			,Anio INT
			,FechaIni DATE
			,FechaFin DATE
			,Dias DECIMAL(18,2)
			,DiasTomados DECIMAL(18,2)
			,DiasVencidos DECIMAL(18,2)
			,DiasDisponibles DECIMAL(18,2)
			,TipoPrestacion VARCHAR(500)
			,Errores VARCHAR(500)
			,Proporcional BIT
		 )

		
		INSERT INTO @Empleados
		EXEC [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @EmpleadoIni = @ClaveEmpleadoInicial, @EmpleadoFin = @ClaveEmpleadoFinal, @dtFiltros = @Filtros, @IDUsuario = @IDUsuario

		
		-----PROPORCIONALES-----
		SELECT @IDEmpleado = MIN(IDEmpleado) FROM @Empleados
		
		WHILE (@IDEmpleado <= (SELECT MAX(IDEmpleado) FROM @Empleados))
		BEGIN
			BEGIN TRY
				INSERT INTO @SaldosVacaciones
				EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = 1, @FechaBaja = NULL, @IDUsuario = @IDUsuario
			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE() 
				INSERT INTO #TempSaldos(IDEmpleado, Errores)
				SELECT @IDEmpleado, ERROR_MESSAGE()
			END CATCH

			INSERT INTO #TempSaldos
			SELECT @IDEmpleado, Anio, FechaIni, FechaFin, Dias, DiasTomados, DiasVencidos, DiasDisponibles, TipoPrestacion, '', 1
			FROM @SaldosVacaciones

			DELETE @SaldosVacaciones

			SELECT @IDEmpleado = MIN(IDEmpleado) FROM @Empleados WHERE IDEmpleado > @IDEmpleado
		END
		-----PROPORCIONALES-----

		

		-----NO PROPORCIONALES-----
		SELECT @IDEmpleado = MIN(IDEmpleado) FROM @Empleados

		WHILE (@IDEmpleado <= (SELECT MAX(IDEmpleado) FROM @Empleados))
		BEGIN
			BEGIN TRY
				INSERT INTO @SaldosVacaciones
				EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = 0, @FechaBaja = NULL, @IDUsuario = @IDUsuario
			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE() 
				INSERT INTO #TempSaldos(IDEmpleado, Errores)
				SELECT @IDEmpleado,ERROR_MESSAGE()
			END CATCH

			INSERT INTO #TempSaldos
			SELECT @IDEmpleado, Anio, FechaIni, FechaFin, Dias, DiasTomados, DiasVencidos, DiasDisponibles, TipoPrestacion, '', 0
			FROM @SaldosVacaciones

			DELETE @SaldosVacaciones

			SELECT @IDEmpleado = MIN(IDEmpleado) FROM @Empleados WHERE IDEmpleado > @IDEmpleado
		END
		-----NO PROPORCIONALES-----


		SELECT
			 IDEmpleado 
			,MAX(Anio) AS Anio
			,MAX(Dias) AS DiasAniosPrestacion
			,SUM(Dias) AS VacacionesGeneradasDesdeIngreso
			,SUM(DiasTomados) AS DiasTomados
			,SUM(DiasVencidos) AS DiasVencidos
			,SUM(DiasDisponibles) AS DiasDisponibles
			,Errores 
			,Proporcional 
		INTO #TempSaldosFinal
		FROM #TempSaldos
		GROUP BY IDEmpleado, Errores, Proporcional


		MERGE [Asistencia].[tblVacacionesReporteAPI] AS TARGET
		USING #TempSaldosFinal AS SOURCE
			ON TARGET.IDEmpleado = SOURCE.IDEmpleado
			AND TARGET.Anio = SOURCE.Anio
			AND TARGET.Proporcional = SOURCE.Proporcional
		WHEN MATCHED THEN
			UPDATE
				SET TARGET.DiasAniosPrestacion = ISNULL(SOURCE.DiasAniosPrestacion,0.)
				   ,TARGET.VacacionesGeneradas = ISNULL(SOURCE.VacacionesGeneradasDesdeIngreso,0)
				   ,TARGET.DiasTomados		   = ISNULL(SOURCE.DiasTomados,0)
				   ,TARGET.DiasVencidos        = ISNULL(SOURCE.DiasVencidos,0)
				   ,TARGET.DiasDisponibles     = ISNULL(SOURCE.DiasDisponibles,0)
				   ,TARGET.Errores			   = ISNULL(SOURCE.Errores,0)
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([IDEmpleado], [Anio], [DiasAniosPrestacion], [VacacionesGeneradas], [DiasTomados], [DiasVencidos], [DiasDisponibles], [Errores], [Proporcional])
			VALUES (SOURCE.IDEmpleado, SOURCE.Anio, SOURCE.DiasAniosPrestacion, SOURCE.VacacionesGeneradasDesdeIngreso, SOURCE.DiasTomados,SOURCE.DiasVencidos, SOURCE.DiasDisponibles, SOURCE.Errores, SOURCE.Proporcional
			)
		WHEN NOT MATCHED BY SOURCE THEN
			DELETE;


END
GO
