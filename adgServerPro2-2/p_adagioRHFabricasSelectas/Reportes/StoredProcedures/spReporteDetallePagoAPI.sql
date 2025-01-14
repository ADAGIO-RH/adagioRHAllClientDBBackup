USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteDetallePagoAPI](

	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT

)
AS

BEGIN


		SET NOCOUNT ON;


		DECLARE
			 @FechaIni DATE
			,@FechaFin DATE


		SELECT @FechaIni = ISNULL((SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaIni'),',')),'1900-01-01')
		SELECT @FechaFin = ISNULL((SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'FechaFin'),',')),'1900-01-01')


		IF OBJECT_ID('TempDB..#TempPagos') IS NOT NULL DROP TABLE #TempPagos


		SELECT
			 ROW_NUMBER() OVER(PARTITION BY M.ClaveEmpleado ORDER BY P.FechaFinPago ASC) AS Contador
			,HEP.IDHistorialEmpleadoPeriodo
			,HEP.IDPeriodo
			,FORMAT(P.FechaFinPago,'dd/MM/yyyy') AS Fecha
			,HEP.IDEmpleado
			,M.ClaveEmpleado AS Empleado
			,CASE WHEN P.General			   = 1 THEN 'Pago Nomina General'
				  WHEN P.Finiquito			   = 1 THEN 'Pago Nomina Finiquito'
				  WHEN P.Especial			   = 1 THEN 'Pago Nomina Especial'
				  WHEN P.Aguinaldo			   = 1 THEN 'Pago Aguinaldo'
				  WHEN P.PTU				   = 1 THEN 'Pago PTU'
				  WHEN P.DevolucionFondoAhorro = 1 THEN 'Pago Fondo De Ahorro'
			 ELSE 'Presupuesto' END AS Movimiento
			,SUM(ISNULL(DP.ImporteTotal1,0)) AS ImporteTotal1
		INTO #TempPagos
		FROM Nomina.tblHistorialesEmpleadosPeriodos HEP WITH (NOLOCK)
			INNER JOIN Nomina.tblCatPeriodos P WITH (NOLOCK)
				ON HEP.IDPeriodo = P.IDPeriodo
			INNER JOIN RH.tblEmpleadosMaster M WITH (NOLOCK)
				ON M.IDEmpleado = HEP.IDEmpleado
			LEFT JOIN Nomina.tblDetallePeriodo DP WITH (NOLOCK)
				ON DP.IDEmpleado = HEP.IDEmpleado
				AND DP.IDPeriodo = HEP.IDPeriodo
				AND DP.IDConcepto IN (SELECT IDConcepto FROM Nomina.tblCatConceptos WITH (NOLOCK) WHERE IDTipoConcepto = 5)
		WHERE P.FechaFinPago BETWEEN @FechaIni AND @FechaFin
		GROUP BY
			 HEP.IDEmpleado
			,HEP.IDHistorialEmpleadoPeriodo
			,HEP.IDPeriodo
			,P.FechaFinPago
			,HEP.IDEmpleado
			,M.ClaveEmpleado
			,P.General			  
			,P.Finiquito			  
			,P.Especial			  
			,P.Aguinaldo			  
			,P.PTU				  
			,P.DevolucionFondoAhorro
		HAVING SUM(ISNULL(DP.ImporteTotal1,0)) > 0
		ORDER BY M.ClaveEmpleado, P.FechaFinPago


		SELECT Empleado, Movimiento, Fecha FROM #TempPagos ORDER BY Empleado, Fecha


END
GO
