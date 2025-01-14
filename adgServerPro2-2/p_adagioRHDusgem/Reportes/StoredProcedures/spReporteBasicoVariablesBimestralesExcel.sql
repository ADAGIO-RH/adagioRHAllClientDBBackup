USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : 
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-07-31
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [Reportes].[spReporteBasicoVariablesBimestralesExcel](    	             
     @dtFiltros [Nomina].[dtFiltrosRH] READONLY
    ,@IDUsuario                         INT = 0    
)
AS
BEGIN
    DECLARE
         @IDControlCalculoVariables                  INT
        ,@ClasificacionesCorporativas                VARCHAR(MAX) = ''
        ,@Departamentos                              VARCHAR(MAX) = ''
        ,@Divisiones                                 VARCHAR(MAX) = ''
        ,@Puestos                                    VARCHAR(MAX) = ''
        ,@Sucursales                                 VARCHAR(MAX) = ''
        ,@IDBimestre                                 INT
        ,@DescripcionBimestre                        VARCHAR(MAX)
        ,@FechaInicioBimestre                        DATE
        ,@FechaFinBimestre                           DATE
        ,@Ejercicio                                  INT
        ,@SQL                                        NVARCHAR(MAX)
        ,@WhereClause                                NVARCHAR(MAX)
        ,@OrderBy                                    NVARCHAR(MAX) = ' ORDER BY ClaveEmpleado';

    SET @IDControlCalculoVariables = (SELECT TOP 1 CAST(VALUE AS INT) FROM @dtFiltros WHERE CATALOGO = 'IDControlCalculoVariablesVarchar')
    SET @Departamentos = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Departamentos')
    SET @Sucursales = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Sucursales')
    SET @Puestos = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Puestos')
    SET @ClasificacionesCorporativas = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'ClasificacionesCorporativas')
    SET @Divisiones = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Divisiones')



    SELECT
        @IDBimestre     = IDBimestre,           
        @Ejercicio      = Ejercicio
    FROM Nomina.tblControlCalculoVariablesBimestrales
    WHERE IDControlCalculoVariables = @IDControlCalculoVariables;

    SELECT @DescripcionBimestre = Descripcion 
    FROM Nomina.tblCatBimestres WITH (NOLOCK) 
    WHERE IDBimestre = @IDBimestre;

    SELECT @FechaInicioBimestre = MIN(DATEADD(MONTH,IDMes-1,DATEADD(YEAR,@Ejercicio-1900,0)))   
    FROM Nomina.tblCatMeses WITH (NOLOCK)  
    WHERE CAST(IDMes AS VARCHAR) IN (
        SELECT item 
        FROM app.Split(
            (SELECT TOP 1 meses 
             FROM Nomina.tblCatBimestres WITH (NOLOCK) 
             WHERE IDBimestre = @IDBimestre), ',')
        );

    SET @FechaFinBimestre = [Asistencia].[fnGetFechaFinBimestre](@FechaInicioBimestre);
    
    SET @SQL = N'
    SELECT         
        E.ClaveEmpleado                                                       AS [Clave Empleado],
        E.NOMBRECOMPLETO                                                      AS [Nombre Completo],
        E.IMSS                                                                AS [NSS ],
        FORMAT(BM.FechaAntiguedad,''dd/MM/yyyy'')                             AS [Fecha de Antiguedad],            
        BM.SalarioDiario                                                      AS [Salario Diario],
        BM.SalarioVariable                                                    AS [Salario Variable],
        BM.SalarioIntegrado                                                   AS [Salario Integrado],
        BM.NuevoFactor                                                        AS [Nuevo Factor],
        BM.Dias                                                               AS [Dias],
        CASE WHEN BM.VariableCambio = 1 THEN ''SI'' ELSE ''NO'' END           AS [Cambio Variable],
        CASE WHEN BM.FactorCambio = 1 THEN ''SI'' ELSE ''NO'' END             AS [Cambio Factor],
        CASE WHEN BM.Afectar = 1 THEN ''SI'' ELSE ''NO'' END                  AS [Genera M/s],        
        CASE WHEN BM.IDMovAfiliatorio IS NOT NULL THEN ''SI'' ELSE ''NO'' END AS [Movimiento Afiliatorio Generado],
        FORMAT(BM.FechaUltimoMovimiento,''dd/MM/yyyy'')                       AS [Fecha Ultimo Mov],
        BM.AnteriorSalarioDiario                                              AS [Ultimo S.D],
        BM.AnteriorSalarioVariable                                            AS [Ultimo S.V],
        BM.AnteriorSalarioIntegrado                                           AS [Ultimo S.I],
        BM.FactorAntiguo                                                      AS [Ultimo Factor],        
        @DescripcionBimestre                                                  AS [Bimestre],
        @Ejercicio                                                            AS [Ejercicio],                        
        FORMAT(BM.DiaAplicacion,''dd/MM/yyyy'')                               AS [Fecha Aplicación],
        BM.CriterioDias                                                       AS [Criterio de Dias],
        BM.CriterioUMA                                                        AS [Criterio UMA],
        BM.UMA                                                                AS [UMA ],        
        BM.SalarioMinimo                                                      AS [Salario Minimo],      
        CASE WHEN C.Aplicar = 1 THEN ''SI'' ELSE ''NO'' END                   AS [Control de Variables Aplicado]  
    FROM NOMINA.TblCalculoVariablesBimestralesMaster BM
    INNER JOIN Nomina.tblControlCalculoVariablesBimestrales C ON C.IDControlCalculoVariables = BM.IDControlCalculoVariables
    INNER JOIN RH.tblEmpleadosMaster E ON E.IDEmpleado = BM.IDEmpleado';

    SET @WhereClause = N' WHERE BM.IDControlCalculoVariables = @IDControlCalculoVariables';

    IF @ClasificacionesCorporativas <> ''
    BEGIN
        SET @SQL = @SQL + N' LEFT JOIN RH.tblClasificacionCorporativaEmpleado CC ON CC.IDEmpleado = BM.IDEmpleado AND CC.FechaIni <= @FechaFinBimestre AND CC.FechaFin >= @FechaFinBimestre';
        SET @WhereClause = @WhereClause + N' AND CC.IDClasificacionCorporativa IN (SELECT item FROM app.Split(@ClasificacionesCorporativas, '',''))';
    END

    IF @Departamentos <> ''
    BEGIN
        SET @SQL = @SQL + N' LEFT JOIN RH.tblDepartamentoEmpleado DE ON DE.IDEmpleado = BM.IDEmpleado AND DE.FechaIni <= @FechaFinBimestre AND DE.FechaFin >= @FechaFinBimestre';
        SET @WhereClause = @WhereClause + N' AND DE.IDDepartamento IN (SELECT item FROM app.Split(@Departamentos, '',''))';
    END

    IF @Divisiones <> ''
    BEGIN
        SET @SQL = @SQL + N' LEFT JOIN RH.tblDivisionEmpleado DIE ON DIE.IDEmpleado = BM.IDEmpleado AND DIE.FechaIni <= @FechaFinBimestre AND DIE.FechaFin >= @FechaFinBimestre';
        SET @WhereClause = @WhereClause + N' AND DIE.IDDivision IN (SELECT item FROM app.Split(@Divisiones, '',''))';
    END

    IF @Puestos <> ''
    BEGIN
        SET @SQL = @SQL + N' LEFT JOIN RH.tblPuestoEmpleado PUE ON PUE.IDEmpleado = BM.IDEmpleado AND PUE.FechaIni <= @FechaFinBimestre AND PUE.FechaFin >= @FechaFinBimestre';
        SET @WhereClause = @WhereClause + N' AND PUE.IDPuesto IN (SELECT item FROM app.Split(@Puestos, '',''))';
    END

    IF @Sucursales <> ''
    BEGIN
        SET @SQL = @SQL + N' LEFT JOIN RH.tblSucursalEmpleado SUE ON SUE.IDEmpleado = BM.IDEmpleado AND SUE.FechaIni <= @FechaFinBimestre AND SUE.FechaFin >= @FechaFinBimestre';
        SET @WhereClause = @WhereClause + N' AND SUE.IDSucursal IN (SELECT item FROM app.Split(@Sucursales, '',''))';
    END

    SET @SQL = @SQL + @WhereClause
    SET @SQL = @SQL + @OrderBy;

    

    EXEC sp_executesql @SQL, 
        N'@IDControlCalculoVariables INT, @DescripcionBimestre VARCHAR(MAX), @Ejercicio INT, @FechaFinBimestre DATE,
          @ClasificacionesCorporativas VARCHAR(MAX),@Departamentos VARCHAR(MAX), @Divisiones VARCHAR(MAX), @Puestos VARCHAR(MAX), @Sucursales VARCHAR(MAX)', 
        @IDControlCalculoVariables, @DescripcionBimestre, @Ejercicio, @FechaFinBimestre,
        @ClasificacionesCorporativas,@Departamentos, @Divisiones, @Puestos, @Sucursales;
END
GO
