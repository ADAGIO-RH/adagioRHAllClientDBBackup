USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarIDSEReporteBAJAS](        
	@FechaIni date = '1900-01-01',                      
	@Fechafin date = '9999-12-31',                      
	@AfectaIDSE bit = 0,        
	@FechaIDSE date = '9999-12-31',           
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY,
	@IDUsuario int     
)        
AS        
BEGIN        
        
	declare @IDRegPatronal int
	 , @dtEmpleados RH.dtEmpleados;

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')   
	
   insert into @dtEmpleados      
   exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario 
      
	IF OBJECT_ID('tempdb..#TempValores') IS NOT NULL DROP TABLE #TempValores;      
        
	select  
		[App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS        
		+ [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL        
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Paterno,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ', 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Materno,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ', 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))    
		+ replace ( replace( replace ( replace  (replace( replace([App].[fnAddString](27, CONVERT(varchar(27),RTRIM(substring(UPPER(COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,27 ))),' ',2), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ), 'Ñ', 'N' ) -- NOMBRE (APELLIDO PATERNO$MATERNO$NOMBRE(S))   
		+ [App].[fnAddString](15,'0','0',2) -- FILLER    
		+ [App].[fnAddString](8,ISNULL(FORMAT(mov.Fecha, 'ddMMyyyy'),''),'0',2) -- FECHA DE MOVIMIENTO       
		+ [App].[fnAddString](5,'','',2) -- FILLER    
		+ [App].[fnAddString](2,'02',' ',2) -- Movimiento    
		+ [App].[fnAddString](5,RTRIM(substring(UPPER(COALESCE(rp.SubDelegacionIMSS,'')+''+COALESCE('400','')),1,27 )),'',2) -- DELEGACION    
		+ [App].[fnAddString](10,e.ClaveEmpleado,' ',2) -- ClaveEmpleado    
		+ [App].[fnAddString](1,CASE WHEN RMA.Descripcion = 'ABANDONO DE TRABAJO' THEN 3    
				WHEN RMA.Descripcion = 'AUSENTISMOS' THEN 7     
				WHEN RMA.Descripcion = 'RENUNCIA VOLUNTARIA' then 2    
				WHEN RMA.Descripcion = 'RESCISION DE CONTRATO' then 8    
				WHEN RMA.Descripcion = 'TERMINO DE CONTRATO' then 1    
				WHEN RMA.Descripcion = 'SEPARACION VOLUNTARIA' then 2    
				ELSE 6 END,'6',2) -- ClaveEmpleado    
		+ [App].[fnAddString](18,'','',2) -- FILLER    
		+ [App].[fnAddString](1,'9','9',2) as valor -- Identificador    
		, mov.IDMovAfiliatorio    
	into #TempValores    
	from IMSS.tblMovAfiliatorios mov
		INNER join @dtEmpleados E on mov.IDEmpleado = e.IDEmpleado
			and mov.Fecha BETWEEN @FechaIni and @Fechafin        
			and mov.IDRegPatronal = @IDRegPatronal   
			and mov.FechaIDSE IS NULL        
		INNER join rh.tblCatRegPatronal rp on rp.IDRegPatronal = @IDRegPatronal    
		INNER join IMSS.tblCatTipoMovimientos tm on mov.IDTipoMovimiento = tm.IDTipoMovimiento        
			and tm.Codigo in ('B')   
		LEFT join IMSS.tblCatRazonesMovAfiliatorios RMA on Mov.IDRazonMovimiento = RMA.IDRazonMovimiento    
		LEFT Join RH.tblContratoEmpleado CE on CE.IDEmpleado = E.IDEmpleado      
			and CE.FechaIni<= @Fechafin and CE.FechaFin >= @Fechafin    
			and CE.IDTipoDocumento <> 3    
		LEFT JOIN Sat.tblCatTiposContrato  CTC on CTC.IDTipoContrato = CE.IDTipoContrato    
        
    
	if @AfectaIDSE = 1     
	BEGIN    
		UPDATE IMSS.tblMovAfiliatorios    
			set FechaIDSE = cast(@FechaIDSE as date)     
		where IDMovAfiliatorio in (Select IDMovAfiliatorio from #TempValores)    
	END    
    
	Select valor from #TempValores     
    
END
GO
