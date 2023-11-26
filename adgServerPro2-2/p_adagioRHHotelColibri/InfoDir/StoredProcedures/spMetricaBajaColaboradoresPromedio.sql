USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el promedio de baja en colaboradores
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-08
** Parametros		: @IDMetrica
**					: @Json
**					: @IDPeriodo
**					: @FechaDe
**					: @FechaHasta
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

create PROC [InfoDir].[spMetricaBajaColaboradoresPromedio]
(
	@IDMetrica INT,
	@Json NVARCHAR(MAX),
	@IDPeriodo INT,
	@FechaDe DATE,
	@FechaHasta DATE
)
AS
	BEGIN
		
		DECLARE @dtFiltrosMetrica [Nomina].[dtFiltrosRH];
		DECLARE @Condicion VARCHAR(MAX);		
		DECLARE @Qry NVARCHAR(MAX);
		
		
		CREATE TABLE #TempBajas (
			[FechaNormalizacion] DATE,
			[NoBajas] INT,
			[IDCliente] INT,
			[IDRazonSocial] INT,
			[IDRegPatronal] INT,
			[IDCentroCosto] INT,
			[IDDepartamento] INT,
			[IDArea] INT,
			[IDPuesto] INT,
			[IDTipoPrestacion] INT,
			[IDSucursal] INT,
			[IDDivision] INT,
			[IDRegion] INT,
			[IDClasificacionCorporativa] INT
		);

		IF(@IDMetrica <> 0)
			BEGIN				
				-- CONSULTAMOS JSON(FILTROS) Y CONDICION DEL PERIODO DE METRICA
				SELECT @Json = M.ConfiguracionFiltros, 
					   @Condicion = P.Condicion,
					   @FechaDe = M.FechaDe,
					   @FechaHasta = M.FechaHasta  
				FROM [InfoDir].[tblCatMetricas] M
					INNER JOIN [InfoDir].[tblCatPeriodos] P ON M.IDPeriodo = P.IDPeriodo
				WHERE M.IDMetrica = @IDMetrica
			END
		ELSE
			BEGIN
				-- CONSULTAMOS CONDICION DEL PERIODO DE METRICA
				SELECT @Condicion = P.Condicion 
				FROM [InfoDir].[tblCatPeriodos] P
				WHERE P.IDPeriodo = @IDPeriodo
			END


		-- FILTRAMOS POR PERIODICIDAD
		SET @Qry = 'INSERT INTO #TempBajas '
		SET @Qry = @Qry + 'SELECT FechaNormalizacion, '
		SET @Qry = @Qry + 'NoBajas, '
		SET @Qry = @Qry + 'IDCliente, '
		SET @Qry = @Qry + 'IDRazonSocial, '
		SET @Qry = @Qry + 'IDRegPatronal, '
		SET @Qry = @Qry + 'IDCentroCosto, '
		SET @Qry = @Qry + 'IDDepartamento, '
		SET @Qry = @Qry + 'IDArea, '
		SET @Qry = @Qry + 'IDPuesto, '
		SET @Qry = @Qry + 'IDTipoPrestacion, '
		SET @Qry = @Qry + 'IDSucursal, '
		SET @Qry = @Qry + 'IDDivision, '
		SET @Qry = @Qry + 'IDRegion, '
		SET @Qry = @Qry + 'IDClasificacionCorporativa '
		SET @Qry = @Qry + 'FROM [InfoDir].[tblColaboradoresNormalizados] '
		SET @Qry = @Qry + '' + @Condicion + ''		
		--SELECT @Qry
		EXEC SP_EXECUTESQL @Qry, N'@FechaDe DATE, @FechaHasta DATE', @FechaDe, @FechaHasta;


		-- CONVERTIMOS JSON A TABLA
		INSERT @dtFiltrosMetrica(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@Json,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		  
		-- OBTENEMOS PROMEDIO DE METRICA
		SELECT ISNULL(CAST(AVG(CAST(NoBajas AS DECIMAL(18,2))) AS DECIMAL(18,2)), 0) AS Resultado
		--SELECT SUM(NoBajas) AS Resultado
		FROM #TempBajas
		WHERE NoBajas > 0 AND
			 (
				IDCliente IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDCliente'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDCliente' AND ISNULL(Value, '') <> '')
					)
			 )AND
			 (
				IDRazonSocial IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDRazonSocial'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDRazonSocial' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRegPatronal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDRegPatronal'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDRegPatronal' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDCentroCosto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDCentroCosto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDCentroCosto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDDepartamento IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDDepartamento'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDDepartamento' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDArea IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDArea'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDArea' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDPuesto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDTipoPrestacion IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDTipoPrestacion'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDTipoPrestacion' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDSucursal'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDSucursal' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDDivision IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDDivision'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDDivision' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRegion IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDRegion'),','))
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDRegion' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDClasificacionCorporativa IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltrosMetrica WHERE Catalogo = 'IDClasificacionCorporativa'),','))
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltrosMetrica WHERE Catalogo = 'IDClasificacionCorporativa' AND ISNULL(Value, '') <> '')
					)
			 )

	END
GO
