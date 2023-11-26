USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Reportes.spBuscarBajasPorFecha  '2019-01-01', '2019-01-31'

CREATE PROC Reportes.spBuscarBajasPorFecha 
(
	@FechaIni date, 
	@FechaFin date
)
AS 
BEGIN
	
	if OBJECT_ID ('tempdb..#temp') IS NOT NULL 
		drop table #temp;

	SELECT * , ROW_NUMBER () OVER (ORDER BY FECHA) AS ULTIMOMOVIMIENTO FROM IMSS.tblMovAfiliatorios
		WHERE Fecha >= @FechaIni AND Fecha <= @FechaFin AND IDTipoMovimiento =  3


END
GO
