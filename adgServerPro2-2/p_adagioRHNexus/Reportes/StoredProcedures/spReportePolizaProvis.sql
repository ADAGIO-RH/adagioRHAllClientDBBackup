USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Poliza contable para periodos generales de nomina de manera mensual con multiples agrupamientos.
** Autor			: Julio Castillo
** Email			: jcastillo@adagio.com.mx
** FechaCreacion	: 2023-04-09
** Paremetros		:              

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [Reportes].[spReportePolizaProvis]  (    
		@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
		@IDUsuario int   
	) as   

	declare 
		 @empleados [RH].[dtEmpleados]   
		,@empleadosTemp [RH].[dtEmpleados]        
		,@periodo [Nomina].[dtPeriodos]                     
		,@IDTipoNomina int    
        ,@Ejercicio int 
        ,@IDMes int 
		,@fechaIniPeriodo  date       
		,@fechaFinPeriodo  date  
        ,@DescripcionPeriodo varchar(max)  
        ,@DocumentNo varchar(MAX)
        ,@Mes varchar(3)
		 
		
	
	
		select @IDTipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

        select @Ejercicio = CASE WHEN ISNULL(Value,0) = 0 THEN 0 ELSE  Value END
		from @dtFiltros where Catalogo = 'Ejercicio'

        select @IDMes = CASE WHEN ISNULL(Value,0) = 0 THEN 0 ELSE  Value END
		from @dtFiltros where Catalogo = 'IDMes'

        select @fechaIniPeriodo = CASE WHEN ISNULL(Value,'9999-01-01') = '9999-01-01'  THEN '9999-01-01' ELSE  Value END
		from @dtFiltros where Catalogo = 'FechaIni'
        

		/* Se buscan los periodos qe se requieren en la poliza */    
		insert into @periodo  
		select   
			 IDPeriodo  
			,IDTipoNomina  
			,Ejercicio  
			,ClavePeriodo  
			,Descripcion  
			,FechaInicioPago  
			,FechaFinPago  
			,FechaInicioIncidencia  
			,FechaFinIncidencia  
			,Dias  
			,AnioInicio  
			,AnioFin  
			,MesInicio  
			,MesFin  
			,IDMes  
			,BimestreInicio  
			,BimestreFin  
			,Cerrado  
			,General  
			,Finiquito  
			,isnull(Especial,0)  
		from Nomina.tblCatPeriodos  
		where IDPeriodo in  ( 
                                Select 2584
                                    from Nomina.tblCatPeriodos p 
                                        inner join nomina.tblCatTipoNomina tp
                                         on tp.IDTipoNomina = p.IDTipoNomina 
                                    where Ejercicio = @Ejercicio 
                                        and IDMes = @IDMes 
                                        and Cerrado = 1 
                                        and ( General = 1 or Especial = 1 )
                                        and tp.IDCliente = (Select IDCliente from rh.tblCatClientes where Prefijo = 'MX') 
                                       
                            )   



		/*Fechas del periodo*/
		select top 1 @DescripcionPeriodo = Descripcion from @periodo where General = 1 order by Descripcion asc
        
        /* Descripcion de un campo de la poliza*/
        set @DocumentNo = (Select CONCAT('Prov. Aguin y Prm Vac ',@idmes,' ',@Ejercicio) from Utilerias.tblMeses where idmes = @IDMes)
        
        set @Mes = (select LOWER(Nombre) from Utilerias.tblMeses where idmes = @IDMes)
		
		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado & DENTRO DEL PERIODO SELECCIONADO */      
		--insert into @empleados 
  --      --Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@FechaIni = @fechaIniPeriodo, @FechaFin = @fechaFinPeriodo, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario 
  --      exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina, @IDUsuario = @IDUsuario
		--delete from @empleados where IDEmpleado<>1992


				insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = 2584
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
order by IDEmpleado



		begin
			update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(cc.Descripcion		,e.CentroCosto	)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(d.Descripcion		,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
			--	,e.Puesto			= isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
			--,e.Cliente			= isnull(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(a.Descripcion		,e.Area			)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(div.Descripcion	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(r.Descripcion		,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)
				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)

		from @empleados e
			join ( select hep.*
					from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
						join @periodo p on hep.IDPeriodo = p.IDPeriodo
				) historiales on e.IDEmpleado = historiales.IDEmpleado
			left join RH.tblCatCentroCosto cc		with(nolock) on cc.IDCentroCosto = historiales.IDCentroCosto
		 	left join RH.tblCatDepartamentos d		with(nolock) on d.IDDepartamento = historiales.IDDepartamento
			left join RH.tblCatSucursales s			with(nolock) on s.IDSucursal		= historiales.IDSucursal
			left join RH.tblCatPuestos p			with(nolock) on p.IDPuesto			= historiales.IDPuesto
			left join RH.tblCatRegPatronal rp		with(nolock) on rp.IDRegPatronal	= historiales.IDRegPatronal
			left join RH.tblCatClientes c			with(nolock) on c.IDCliente		= historiales.IDCliente
			left join RH.tblEmpresa emp				with(nolock) on emp.IDEmpresa	= historiales.IDEmpresa
			left join RH.tblCatArea a				with(nolock) on a.IDArea		= historiales.IDArea
			left join RH.tblCatDivisiones div		with(nolock) on div.IDDivision	= historiales.IDDivision
			left join RH.tblCatRegiones r			with(nolock) on r.IDRegion		= historiales.IDRegion
			left join RH.tblCatRazonesSociales rs	with(nolock) on rs.IDRazonSocial = historiales.IDRazonSocial
			left join RH.tblCatClasificacionesCorporativas clasificacionC with(nolock)	on clasificacionC.IDClasificacionCorporativa = historiales.IDClasificacionCorporativa

	end
		insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario
		--select *from @empleados
		--return
		if object_id('tempdb..#percepcionesA') is not null        
			drop table #percepcionesA 

        if object_id('tempdb..#PercepcionesVyPA') is not null        
			drop table #PercepcionesVyPA--Percepciones sin CC

        if object_id('tempdb..#PercepcionesVyPCLientA') is not null        
			drop table #PercepcionesVyPCLientA--Percepciones sin CC

        
        if object_id('tempdb..#percepcionesPV') is not null        
			drop table #percepcionesPV 

        if object_id('tempdb..#PercepcionesVyPPV') is not null        
			drop table #PercepcionesVyPPV--Percepciones sin CC

        if object_id('tempdb..#PercepcionesVyPClientPV') is not null        
			drop table #PercepcionesVyPClientPV--Percepciones sin CC

        
		if object_id('tempdb..#deducciones') is not null        
			drop table #deducciones



/*********************TABLA TEMPORAL AGUINALDO*****************************/		 

SELECT 

            
			
            --@fechaIniPeriodo as PostingDate,	
            --Concat(Conceptos.CuentaCargo,'-',e.CuentaContable) AS G_LAccountNo_,
            --''As DocumentType,
            --@DocumentNo as DocumentNo_,
            CONCAT('Prov. Aguinaldo ',@Mes,' del ',@Ejercicio) as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount--,
            --1 as TransactionNo_,
            --'nrivera' as UserID, 
            --'' as BusinessUnitCode,
            --'' as SourceNo_, 
            --'MXN' as CurrencyCode,
            --'' as OriginalCurrencyFactor,
            --SUM ( detallePeriodo.ImporteTotal1 ) AS Debit--,
			--'0.00' AS Credit,
   --         @fechainiperiodo as DocumentDate,
   --         '' as ExternalDocumentNo_,
   --         '' as sc_Secuence,
   --         '' as ReasonCode,
   --         1 as aaTrxDimID,
   --         'Destination' as aaTrxDim,
   --         Case 
   --             when e.Sucursal = 'CANCUN' THEN 'CUN' 
   --             WHEN e.Sucursal = 'PLAYA DEL CARMEN' THEN 'RIV'
   --             WHEN e.Sucursal = 'SAN JOSE DEL CABO' THEN 'SJD'
   --             WHEN e.Sucursal = 'MAZATLAN' THEN 'MZT'
   --             WHEN e.Sucursal = 'PUERTO VALLARTA' THEN 'PVR'
			--	--WHEN SUC.Descripcion = 'HOLBOX' THEN 'NO ASIGNADO'
   --             end as Dimension,
   --         CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
           --  e.Sucursal
            --,Conceptos.CuentaCargo
            --,e.CuentaContable 
			--	,Empleados.ClaveEmpleado as [Clabe]
			--,Periodo.Descripcion as [descripcionperiodo]
			--,hist.IDHistorialEmpleadoPeriodo as [historial]
			--,hist.IDCentroCosto as [centrocostoid]
            
            
          ,periodo.IDPeriodo            
INTO #percepcionesA
FROM @periodo Periodo
		INNER JOIN Nomina.tblDetallePeriodo detalleperiodo with (nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		--INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		--LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
		--	on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	 --   INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		--INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 
       -- FROM Nomina.tblDetallePeriodo detallePeriodo
       --     INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo 
							--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado

       --         INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
       --             INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        --INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Historial.IDCentroCosto
                        --    Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Historial.IDSucursal
       --                         INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

        /*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
		--WHERE   e.cuentacontable not in ('1101','1103')
		--AND detallePeriodo.Importetotal1 <> 0
    --            and conceptos.Codigo = '530'  
                group by 
				periodo.IDPeriodo
                --e.CuentaContable,
                --e.Sucursal
                --Conceptos.CuentaCargo--,
				--Empleados.ClaveEmpleado,
				--periodo.Descripcion,
				--hist.IDHistorialEmpleadoPeriodo,
				--hist.IDCentroCosto

                
				select*from #percepcionesA
return 

    
                
               
/*********************TABLA TEMPORAL COSTO SOCIAL VEX Y PEGAS DESTINATION*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            case when e.cuentacontable like '%1101%' then '519100-01-1101'
                when e.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Prov. Aguinaldo ',@Mes,' del ',@Ejercicio) as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID,
            '' as BusinessUnitCode,
            '' as SourceNo_,  
            'MXN' as CurrencyCode, 
            '' as OriginalCurrencyFactor,    
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            Case 
                when e.Sucursal = 'CANCUN' THEN 'CUN' 
                WHEN e.Sucursal = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN e.Sucursal = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN e.Sucursal = 'MAZATLAN' THEN 'MZT'
                WHEN e.Sucursal = 'PUERTO VALLARTA' THEN 'PVR'
			--	WHEN SUC.Descripcion = 'HOLBOX' THEN 'NO ASIGNADO'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,e.Sucursal
            ,Conceptos.CuentaCargo
            ,e.CuentaContable
			--,Empleados.ClaveEmpleado as [Clabe]
			--,Periodo.Descripcion as [descripcionperiodo]
			--,hist.IDHistorialEmpleadoPeriodo as [historial]
			--,hist.IDCentroCosto as [centrocostoid]
            
            
            
INTO #PercepcionesVyPA
FROM @periodo Periodo
		INNER JOIN Nomina.tblDetallePeriodo detalleperiodo with (nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 
    --    FROM Nomina.tblDetallePeriodo detallePeriodo
		  --   INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo 
				--			INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado

    --INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
    --                INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
    --                    INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = hist.IDCentroCosto
    --                        Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
    --                            INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   conceptos.Codigo = '530'  
				AND detallePeriodo.Importetotal1 <> 0
                and e.cuentacontable  in ('1101','1103')                             
                group by                
                e.CuentaContable,
				e.Sucursal,
                Conceptos.CuentaCargo--,
				--		Empleados.ClaveEmpleado,
				--periodo.Descripcion,
				--hist.IDHistorialEmpleadoPeriodo,
				--hist.IDCentroCosto


               
/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS CLIENT*****************************/		 

SELECT 

            
				
            @fechaIniPeriodo as PostingDate,
            case when e.cuentacontable like '%1101%' then '519100-01-1101'
                when e.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Prov. Aguinaldo ',@Mes,' del ',@Ejercicio) as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode, 
            '' as SourceNo_, 
            'MXN' as CurrencyCode,  
            '' as OriginalCurrencyFactor,  
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            2 as aaTrxDimID,
            'Client' as aaTrxDim,
            case when e.cuentacontable like '%1101%' then 'VEX'
                when e.cuentacontable like '%1103%' then  'PEGAS' end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
            ,e.Sucursal  
            ,Conceptos.CuentaCargo
            ,e.CuentaContable 
   --         ,Empleados.ClaveEmpleado as [Clabe]
			--,Periodo.Descripcion as [descripcionperiodo]
			--,hist.IDHistorialEmpleadoPeriodo as [historial]
			--,hist.IDCentroCosto as [centrocostoid]
            
            
INTO #PercepcionesVyPCLientA
FROM @periodo Periodo
		INNER JOIN Nomina.tblDetallePeriodo detalleperiodo with (nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 
      --  FROM Nomina.tblDetallePeriodo detallePeriodo
      --INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo   
						--	INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado

      --          INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
      --              INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
      --                  INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = hist.IDCentroCosto
      --                      Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
      --                          INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
                                  
                   
		WHERE   conceptos.Codigo = '530'    --512 y 540       
				AND detallePeriodo.Importetotal1 <> 0
                and e.cuentacontable  in ('1101','1103') 
                group by 
                e.CuentaContable,
                e.Sucursal,
                Conceptos.CuentaCargo--,
				--	Empleados.ClaveEmpleado,
				--periodo.Descripcion,
				--hist.IDHistorialEmpleadoPeriodo,
				--hist.IDCentroCosto

                







/*********************TABLA TEMPORAL ISN*****************************/		 

SELECT 

            
			
            @fechaIniPeriodo as PostingDate,	
            Concat(Conceptos.CuentaCargo,'-',e.CuentaContable) AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Prov. Prima Vac ',@Mes,' del ',@Ejercicio) as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode,
            '' as SourceNo_, 
            'MXN' as CurrencyCode,
            '' as OriginalCurrencyFactor,
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            Case 
                when e.Sucursal = 'CANCUN' THEN 'CUN' 
                WHEN e.Sucursal = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN e.Sucursal = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN e.Sucursal = 'MAZATLAN' THEN 'MZT'
                WHEN e.Sucursal = 'PUERTO VALLARTA' THEN 'PVR'
				--WHEN SUC.Descripcion = 'HOLBOX' THEN 'NO ASIGNADO'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,e.Sucursal
            ,Conceptos.CuentaCargo
            ,e.CuentaContable 
			--  ,Empleados.ClaveEmpleado as [Clabe]
			--,Periodo.Descripcion as [descripcionperiodo]
			--,hist.IDHistorialEmpleadoPeriodo as [historial]
			--,hist.IDCentroCosto as [centrocostoid]
            
            
                      
INTO #percepcionesPV
FROM @periodo Periodo
		INNER JOIN Nomina.tblDetallePeriodo detalleperiodo with (nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 
       -- FROM Nomina.tblDetallePeriodo detallePeriodo
       --             INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo      
							--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado

       --         INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
       --             INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
       --                 INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = hist.IDCentroCosto
       --                     Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
       --                         INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

        /*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
		WHERE   e.cuentacontable not in ('1101','1103')           
				AND detallePeriodo.Importetotal1 <> 0
                and conceptos.Codigo = '531'  
                group by 
                e.CuentaContable,
                e.Sucursal,
                Conceptos.CuentaCargo--,
				--		Empleados.ClaveEmpleado,
				--periodo.Descripcion,
				--hist.IDHistorialEmpleadoPeriodo,
				--hist.IDCentroCosto
                


    
                
               
/*********************TABLA TEMPORAL ISN VEX Y PEGAS DESTINATION*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            case when e.cuentacontable like '%1101%' then '519100-01-1101'
                when e.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Prov. Prima Vac ',@Mes,' del ',@Ejercicio) as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID,
            '' as BusinessUnitCode,
            '' as SourceNo_,  
            'MXN' as CurrencyCode, 
            '' as OriginalCurrencyFactor,    
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            Case 
                when e.Sucursal = 'CANCUN' THEN 'CUN' 
                WHEN e.Sucursal = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN e.Sucursal = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN e.Sucursal = 'MAZATLAN' THEN 'MZT'
                WHEN e.Sucursal = 'PUERTO VALLARTA' THEN 'PVR'
				--WHEN SUC.Descripcion = 'HOLBOX' THEN 'NO ASIGNADO'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,E.Sucursal
            ,Conceptos.CuentaCargo
            ,e.CuentaContable
			--		,Empleados.ClaveEmpleado as [Clabe]
			--,Periodo.Descripcion as [descripcionperiodo]
			--,hist.IDHistorialEmpleadoPeriodo as [historial]
			--,hist.IDCentroCosto as [centrocostoid]
                

            
            
            
INTO #PercepcionesVyPPV
FROM @periodo Periodo
		INNER JOIN Nomina.tblDetallePeriodo detalleperiodo with (nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 
       -- FROM Nomina.tblDetallePeriodo detallePeriodo
       --    INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo     
							--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado

       --         INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
       --             INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
       --                 INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = hist.IDCentroCosto
       --                     Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
       --                         INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   conceptos.Codigo = '531'  
				AND detallePeriodo.Importetotal1 <> 0
                and e.cuentacontable  in ('1101','1103')                             
                group by                
                e.CuentaContable,
                e.Sucursal,
                Conceptos.CuentaCargo--,
				--Empleados.ClaveEmpleado,
				--periodo.Descripcion,
				--hist.IDHistorialEmpleadoPeriodo,
				--hist.IDCentroCosto
            
            
               

/*********************TABLA TEMPORAL ISN VEX Y PEGAS CLIENT*****************************/		 

SELECT 

            
				
            @fechaIniPeriodo as PostingDate,
            case when e.cuentacontable like '%1101%' then '519100-01-1101'
                when e.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Prov. Prima Vac ',@Mes,' del ',@Ejercicio) as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode, 
            '' as SourceNo_, 
            'MXN' as CurrencyCode,  
            '' as OriginalCurrencyFactor,  
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            2 as aaTrxDimID,
            'Client' as aaTrxDim,
            case when e.cuentacontable like '%1101%' then 'VEX'
                when e.cuentacontable like '%1103%' then  'PEGAS' end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
            ,e.Sucursal 
            ,Conceptos.CuentaCargo
            ,e.CuentaContable 
   --         ,Empleados.ClaveEmpleado as [Clabe]
			--,Periodo.Descripcion as [descripcionperiodo]
			--,hist.IDHistorialEmpleadoPeriodo as [historial]
			--,hist.IDCentroCosto as [centrocostoid]
            
            
INTO #PercepcionesVyPClientPV
FROM @periodo Periodo
		INNER JOIN Nomina.tblDetallePeriodo detalleperiodo with (nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 
       -- FROM Nomina.tblDetallePeriodo detallePeriodo
       -- INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo         
							--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado

       --         INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
       --             INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
       --                 INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = hist.IDCentroCosto
       --                     Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
       --                         INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
                                  
                   
                   
		WHERE   conceptos.Codigo = '531'         
				AND detallePeriodo.Importetotal1 <> 0
                and e.cuentacontable  in ('1101','1103') 
                group by 
                e.CuentaContable,
                e.Sucursal,
                Conceptos.CuentaCargo--,
				--Empleados.ClaveEmpleado,
				--periodo.Descripcion,
				--hist.IDHistorialEmpleadoPeriodo,
				--hist.IDCentroCosto


-- Select * from #percepcionesCC
-- union 
-- Select * from #PercepcionesVyPCC
-- Union 
-- Select * from #PercepcionesVyPCLientCC

-- return
               
/*********************TABLA TEMPORAL DEDUCCIONES COSTO SOCIAL*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            Conceptos.CuentaAbono  as G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            case when conceptos.codigo = '531' then CONCAT('Prov. Prima Vac ',@Mes,' del ',@Ejercicio) ELSE CONCAT('Prov. Aguinaldo ',@Mes,' del ',@Ejercicio)  END as [Description],
            - SUM ( detallePeriodo.ImporteTotal1 ) AS Amount, 
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode,  
            '' as SourceNo_, 
            'MXN' as CurrencyCode, 
            '' as OriginalCurrencyFactor,          
            '0.00' AS Debit,
			SUM ( detallePeriodo.ImporteTotal1 ) AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            'CUN' as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
            ,'' as Descripcion
            ,Conceptos.CuentaAbono
            ,0000 as CuentaContable 
			--,Empleados.ClaveEmpleado as [Clabe]
			--,hist.IDSucursal
			--,Periodo.Descripcion as [descripcionperiodo]
			
            --select*from rh.tblCatSucursales
           

            
INTO #deducciones
FROM @periodo Periodo
		INNER JOIN Nomina.tblDetallePeriodo detalleperiodo with (nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 
    --    FROM Nomina.tblDetallePeriodo detallePeriodo
    --            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo
				--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
    --            INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
    --                INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
    --                Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
    --                    INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = hist.IDCentroCosto                       
    --                        INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

		WHERE   Conceptos.Codigo in('530','531') 
				and detallePeriodo.Importetotal1 <> 0 
                group by 
                Conceptos.CuentaAbono,
                Conceptos.Codigo
					--Empleados.ClaveEmpleado,
					--hist.IDSucursal,
				  --periodo.Descripcion


				  --select*from #deducciones
				  --return
---------------------------------------------------------
/*Se creara una tabla temporal con IDENTITY para poder generar el SECNUM de la poliza que tiene que repetirse en VEX y PEGAS*/
create table #Tempaqui
(
        ID INT IDENTITY ,--IMPORTANTE
        [PostingDate] date,
        [G_LAccountNo_]varchar(max),
        [DocumentType]varchar(max),
        [DocumentNo_]varchar(max),
        [Description]varchar(max),
        [Amount]varchar(max),
        [TransactionNo_]varchar(max),
        [UserID]varchar(max),
        [BusinessUnitCode]varchar(max),
        [SourceNo_]varchar(max),
        [CurrencyCode]varchar(max),
        [OriginalCurrencyFactor]varchar(max),
        [Debit]varchar(max),
        [Credit]varchar(max),
        [DocumentDate]date,
        [ExternalDocumentNo_]varchar(max),
        [sc_Secuence]varchar(max),
        [ReasonCode]varchar(max),
        [aaTrxDimID]varchar(max),
        [aaTrxDim]varchar(max),
        [Dimension]varchar(max),
        [BATCH_ID]varchar(max),
        descripcion VARCHAR(MAX),
        cuenta VARCHAR(MAX),
        cuentaC VARCHAR(Max),
        
)

/*Insertamos la Union de nuestras tablas temporales a excepcion de la VEX y PEGAS CLIENT para generar numeros consecutivos*/

insert into #Tempaqui
        Select 
        [PostingDate],
        [G_LAccountNo_],
        [DocumentType],
        [DocumentNo_],
        [Description],
        [Amount],
        [TransactionNo_],
        [UserID],
        [BusinessUnitCode],
        [SourceNo_],
        [CurrencyCode],
        [OriginalCurrencyFactor],
        [Debit],
        [Credit],
        [DocumentDate],
        [ExternalDocumentNo_],
        [sc_Secuence],
        [ReasonCode],
        [aaTrxDimID],
        [aaTrxDim],
        [Dimension],
        [BATCH_ID],
        Sucursal as descripcion,
        CuentaCargo,
        CuentaContable--,
		--Clabe
    
FROM
(
SELECT * from #percepcionesA
        UNION
Select * from #percepcionesVyPA
        UNION
Select * from #percepcionesPV
        UNION 
Select * from #PercepcionesVyPPV
        UNION
SELECT * FROM #deducciones 
) b 
ORDER by Credit

    
set identity_insert #Tempaqui on -- Activamos el ID INSERT para repetir la secuencia de los registros VEX y PEGAS Con un JOIN



Insert into #Tempaqui
(
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
     [Descripcion],
     [Cuenta]
)
SELECT 
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
      Sucursal as [Descripcion],
     [CuentaCargo]
 
FROM 
(
    select 
     t.id, 
     c.*,
     ROW_NUMBER()OVER(Partition by ID order by ID) as rn 
    from #Tempaqui t
        inner join #PercepcionesVyPCLientA c 
            on t.G_LAccountNo_ = c.G_LAccountNo_ 
            and t.cuenta = c.CuentaCargo
            and t.descripcion = c.Sucursal
            and t.[Description] = c.[Description]
            and t.cuentaC = c.CuentaContable
            
) m



Insert into #Tempaqui
(
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
     [Descripcion],
     [Cuenta]
)
SELECT 
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
  Sucursal as [Descripcion],
  [CuentaCargo]
 
FROM 
(
    select 
     t.id, 
     c.*,
     ROW_NUMBER()OVER(Partition by ID order by ID) as rn 
    from #Tempaqui t
        inner join #PercepcionesVyPCLientPV c 
            on t.G_LAccountNo_ = c.G_LAccountNo_ 
            and t.cuenta = c.CuentaCargo
            and t.descripcion = c.Sucursal
            and t.[Description] = c.[Description]
            and t.cuentaC = c.CuentaContable
            
) m
     


      select 
      FORMAT(PostingDate,'dd/MM/yyyy') as [PostingDate],
      [G_LAccountNo_],
      [DocumentType],
      [DocumentNo_],
      [Description],
      CAST(Amount as decimal(18,2)) as [Amount],
      [TransactionNo_],
      [UserID],
      [BusinessUnitCode],
      [SourceNo_],
      [CurrencyCode],
      [OriginalCurrencyFactor],
      CAST(Debit as decimal(18,2)) as [Debit],
      CAST(Credit as decimal(18,2)) as [Credit],
      FORMAT(DocumentDate,'dd/MM/yyyy') as [DocumentDate],
      [ExternalDocumentNo_],
      ID * 500 as EntryNo_,
      [sc_Secuence],
      [ReasonCode],
      ID * 500 as SecNo_,
      [aaTrxDimID],
      [aaTrxDim],
      [Dimension],
      [BATCH_ID]
      from #Tempaqui 
      order by id
GO
