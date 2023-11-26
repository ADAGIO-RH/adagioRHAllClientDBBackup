USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----MODIFICACION FILTROS ------
-----ATT.SOPORTE

CREATE PROCEDURE [IMSS].[spGenerarReporteSUAIDSE]    
(    
 @IDReporte int,    
 @FechaIni date = '1900-01-01',                  
 @Fechafin date = '9999-12-31',                  
 @AfectaIDSE bit = 0,    
 @FechaIDSE date = '9999-12-31',                  
 @EmpleadoIni Varchar(20) = '0',                  
 @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',                               
 @dtFiltros [Nomina].[dtFiltrosRH] READONLY,    
 @IDUsuario int     
)    
AS    
BEGIN    

	 DECLARE @dtEmpleados RH.dtEmpleados   ,
	         @dtFiltrosTempt Nomina.dtFiltrosRH;

	 INSERT INTO @dtFiltrosTempt
	 SELECT * FROM @dtFiltros;
    
	 set @EmpleadoIni = case when @EmpleadoIni = '' then '000000' else @EmpleadoIni end    
	 set @EmpleadoFin = case when @EmpleadoFin = '' then 'ZZZZZZZZZZZZZZZZZZZZ' else @EmpleadoFin end    

	 insert into @dtFiltrosTempt VALUES
		 ('ClaveEmpleadoInicial', @EmpleadoIni),
		 ('ClaveEmpleadoFinal'  , @EmpleadoFin); 
    
    
	   --insert into @dtEmpleados      
	   --exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros,@EmpleadoIni = @EmpleadoIni, @EmpleadoFin=@EmpleadoFin, @IDUsuario= @IDUsuario      

    
	 SELECt TOP 1 Descripcion     
	 from IMSS.tblcatReportesSuaIdse    
	 where IDReporte = @IDReporte    


	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'','[IMSS].[spGenerarReporteSUAIDSE]','SUA - IDSE','',''
		
    
	 IF(@IDReporte = 1) -- SUA Trabajadores    
	 BEGIN    
		EXEC IMSS.spGenerarSuaReporteTrabajadores @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario    
	 END    
	 IF(@IDReporte = 2) -- SUA Movimientos Afiliatorios    
	 BEGIN    
	  EXEC IMSS.spGenerarSuaReporteMovimientosAfiliatorios @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario  
	 END    
	 IF(@IDReporte = 3) -- SUA DATOS AFILIATORIOS    
	 BEGIN    
	   EXEC IMSS.spGenerarSuaReporteDatosAfiliatorios @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario     
	 END    
	 IF(@IDReporte = 4) -- SUA Ausentismos    
	 BEGIN    
	  EXEC IMSS.spGenerarSuaReporteAusentismos  @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario   
	 END    
	 IF(@IDReporte = 5) -- SUA Incapacidades    
	 BEGIN    
	   EXEC IMSS.spGenerarSuaReporteIncapacidades @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario     
	 END    
	 IF(@IDReporte = 6) -- SUA Alta Creditos Infonavit    
	 BEGIN    
	   EXEC IMSS.spGenerarSuaReporteCreditosINFONAVIT @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario     
	 END    
	 IF(@IDReporte = 7) -- IDSE Altas    
	 BEGIN    
	   EXEC IMSS.spGenerarIDSEReporteALTA  @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = @AfectaIDSE ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario     
	 END    
	 IF(@IDReporte = 8) -- IDSE Bajas    
	 BEGIN    
	  EXEC IMSS.spGenerarIDSEReporteBAJAS @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = @AfectaIDSE ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario 
	 END    
	 IF(@IDReporte = 9) -- IDSE Movimientos Salariales    
	 BEGIN    
	  EXEC IMSS.spGenerarIDSEReporteMOVIMIENTOSALARIO @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = @AfectaIDSE ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltrosTempt, @IDUsuario= @IDUsuario 
	 END    
	 IF(@IDReporte = 10) -- IDSE Reingresos    
	 BEGIN    
	   EXEC IMSS.spGenerarIDSEReporteREINGRESO @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = @AfectaIDSE ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltrosTempt, @IDUsuario= @IDUsuario 
	 END    
	  IF(@IDReporte = 11) -- SUA ALTAS REINGRESOS    
	 BEGIN    
	  EXEC IMSS.spGenerarSuaReporteAltasReingresos @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario 
	 END   
     IF(@IDReporte = 12) -- SUA INCAPACIDADES COMPLEMENTOS    
	 BEGIN    
	  EXEC IMSS.spGenerarSuaReporteIncapacidadesComplemento @FechaIni = @FechaIni, @Fechafin= @Fechafin, @AfectaIDSE = 0 ,@FechaIDSE = @FechaIDSE,@dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario 
	 END   
    
    
END
GO
