USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReportePrestamosCajaDeAhorro](


	 @Filtros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT


)
AS

BEGIN

		SET NOCOUNT ON;

		DECLARE
			 @IDTipoNomina INT
			,@FechaIni DATE
			,@FechaFin DATE
			,@Empleados [RH].[dtEMpleados]
			,@Codigo_Concepto_Prestamo_Caja_De_Ahorro VARCHAR(10) = '321'
			,@IDPrestamoCajaDeAhorro INT = 14


		SELECT @IDTipoNomina = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @Filtros WHERE Catalogo = 'TIpoNomina'),',')),0)
		SELECT @FechaIni = ISNULL((SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @Filtros WHERE Catalogo = 'FechaIni'),',')),'1900-01-01')
		SELECT @FechaFin = ISNULL((SELECT CAST(Item AS DATE) FROM App.Split((SELECT TOP 1 Value FROM @Filtros WHERE Catalogo = 'FechaFin'),',')),'9999-12-31')


		INSERT INTO @Empleados 
		EXEC [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina, @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @Filtros, @IDUsuario = @IDUsuario


		IF OBJECT_ID('TempDB..#TempPrestamos') IS NOT NULL DROP TABLE #TempPrestamos


		SELECT
			 P.IDEmpleado
			,E.ClaveEmpleado
			,E.NOMBRECOMPLETO
			,P.IDPrestamo
			,P.Codigo
			,TP.Descripcion AS Prestamo
			,EP.Descripcion AS Estatus
			,P.MontoPrestamo
			,P.Intereses
			,P.CantidadCuotas
			,P.Cuotas
			,P.Descripcion AS DetallePrestamo
			,FORMAT(P.FechaCreacion,'dd/MM/yyyy') AS FechaCreacion
			,FORMAT(P.FechaInicioPago,'dd//MM/yyyy') AS FechaInicioPago
			,(P.MontoPrestamo + P.Intereses) AS TotalPrestamo
			,(SELECT SUM(MontoCuota) FROM Nomina.fnPagosPrestamo(IDPrestamo)) AS Pagado
			,(P.MontoPrestamo + P.Intereses) - (SELECT SUM(MontoCuota) FROM Nomina.fnPagosPrestamo(IDPrestamo)) AS Saldo
			,ROW_NUMBER() OVER(PARTITION BY P.IDEmpleado ORDER BY P.IDEmpleado ASC) AS Contador
		INTO #TempPrestamos
		FROM @Empleados E
			INNER JOIN Nomina.tblPrestamos P WITH (NOLOCK)
				ON E.IDEmpleado = P.IDEmpleado
				AND P.IDTipoPrestamo = @IDPrestamoCajaDeAhorro
			INNER JOIN Nomina.tblCatTiposPrestamo TP WITH (NOLOCK)
				ON TP.IDTipoPrestamo = P.IDTipoPrestamo
			INNER JOIN Nomina.tblCatEstatusPrestamo EP WITH (NOLOCK)
				ON EP.IDEstatusPrestamo = P.IDEstatusPrestamo


		SELECT
			 ClaveEmpleado AS Clave
			,NOMBRECOMPLETO AS Nombre
			,Codigo AS Prestamo
			,Prestamo AS [Tipo Prestamo]
			,Estatus 
			,MontoPrestamo AS [Monto Prestamo]
			,Intereses 
			,TotalPrestamo AS [Total Prestamo]
			,Pagado
			,Saldo
		FROM #TempPrestamos
		ORDER BY ClaveEmpleado

END
GO
