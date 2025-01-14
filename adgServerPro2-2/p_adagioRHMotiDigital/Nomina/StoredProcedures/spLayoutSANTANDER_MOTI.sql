USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE  [Nomina].[spLayoutSANTANDER_MOTI] --2,'2018-12-27',8,0    
(    
 @IDPeriodo int,    
 @FechaDispersion date,    
 @IDLayoutPago int,
 @dtFiltros [Nomina].[dtFiltrosRH]  readonly,
 @MarcarPagados bit = 0,     
 @IDUsuario int      
)    
AS    
BEGIN 
	DECLARE 
			@empleados [RH].[dtEmpleados]      
			,@ListaEmpleados Nvarchar(max)    
			,@periodo [Nomina].[dtPeriodos]  
			,@fechaIniPeriodo  date                  
			,@fechaFinPeriodo  date
			,@IDTipoNomina int 
			,@NombrePeriodo Varchar(20)
			,@ClavePeriodo Varchar(16)
			,@CountEmpleados int 

		-- PARAMETROS
			,@NombreEmpresa Varchar(36) --Razon Social
			,@NoCuenta Varchar(20) --Cuenta Cargo


 	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	from Nomina.TblCatPeriodos                  
	where IDPeriodo = @IDPeriodo    
	
                  
	select top 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago , @NombrePeriodo = Descripcion , @ClavePeriodo = ClavePeriodo                
	from @periodo                  
	

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario


	-- CARGAR PARAMETROS EN VARIABLES

	 select @NombreEmpresa = upper(lpp.Valor) COLLATE Cyrillic_General_CI_AI 
	 from Nomina.tblLayoutPago lp  
	  inner join Nomina.tblLayoutPagoParametros lpp  
	   on lp.IDLayoutPago = lpp.IDLayoutPago  
	  inner join Nomina.tblCatTiposLayoutParametros ctlp  
	   on ctlp.IDTipoLayout = lp.IDTipoLayout  
	   and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	 where lp.IDLayoutPago = @IDLayoutPago  
	 and ctlp.Parametro = 'Nombre Empresa'  

	 select @NoCuenta = lpp.Valor  
	 from Nomina.tblLayoutPago lp  
	  inner join Nomina.tblLayoutPagoParametros lpp  
	   on lp.IDLayoutPago = lpp.IDLayoutPago  
	  inner join Nomina.tblCatTiposLayoutParametros ctlp  
	   on ctlp.IDTipoLayout = lp.IDTipoLayout  
	   and ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	 where lp.IDLayoutPago = @IDLayoutPago  
	 and ctlp.Parametro = 'No. Cuenta' 

	 -- CARGAR PARAMETROS EN VARIABLES

	 -- MARCAR EMPLEADOS COMO PAGADOS
		 if object_id('tempdb..#tempempleadosMarcables') is not null    
    drop table #tempempleadosMarcables;    
    
   create table #tempempleadosMarcables(IDEmpleado int,IDPeriodo int, IDLayoutPago int); 
    
	if(isnull(@MarcarPagados,0) = 1)
	BEGIN 
			insert into #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago)
			SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago
				 FROM  @empleados e     
			  INNER join Nomina.tblCatPeriodos p    
			   on p.IDPeriodo = @IDPeriodo   
			  INNER JOIN RH.tblPagoEmpleado pe    
			   on pe.IDEmpleado = e.IDEmpleado
			  left join Sat.tblCatBancos b  
				on pe.IDBanco = b.IDBanco    
			  INNER JOIN  Nomina.tblLayoutPago lp    
			   on lp.IDLayoutPago = pe.IDLayoutPago    
			  inner join Nomina.tblCatTiposLayout tl    
			   --on tl.TipoLayout = 'SCOTIABANK'    
				on lp.IDTipoLayout = tl.IDTipoLayout    
			  INNER JOIN Nomina.tblDetallePeriodo dp    
			   on dp.IDPeriodo = @IDPeriodo    
			   --and lp.IDConcepto = dp.IDConcepto    
			   and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			   and dp.IDEmpleado = e.IDEmpleado    
			 where  pe.IDLayoutPago = @IDLayoutPago  

		MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
		USING #tempempleadosMarcables AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
				and TARGET.IDLayoutPago = SOURCE.IDLayoutPago
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDLayoutPago)  
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago);

	  END
	 -- MARCAR EMPLEADOS COMO PAGADOS

	 -- HEADER 
		  if object_id('tempdb..#tempHeader1') is not null    
			drop table #tempHeader1;    
    
			create table #tempHeader1(Respuesta nvarchar(max)); 

			insert into #tempHeader1(Respuesta)   
			  select     
			   [App].[fnAddString](1,'1','0',2)  --Tipo de registro
			  +[App].[fnAddString](5,Row_Number()OVER(ORDER BY (SELECT 1)),'0',1) --Contador (Num de fila) 
			  +[App].[fnAddString](1,'E','',2)  --Registro
			  +[App].[fnAddString](8,+format(DATEPART(mm,@FechaDispersion),'00')+isnull(format(@FechaDispersion,'ddyyyy'),''),'',2)  --Fecha 
			  +[App].[fnAddString](16,@NoCuenta,'',2) --Cuenta Cargo  
			 --+[App].[fnAddString](5,'',' ',1) --Filler
			  +[App].[fnAddString](8,+format(DATEPART(mm,@FechaDispersion),'00')+isnull(format(@FechaDispersion,'ddyyyy'),''),'',2)  --Fecha  

	 -- HEADER

	 -- CUERPO DE EMPLEADOS

		Declare @SumAll Decimal(16,2)  
  
		  select @SumAll =  SUM(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end)  
		   FROM   @empleados e    
		  INNER join Nomina.tblCatPeriodos p    
		   on p.IDPeriodo = @IDPeriodo   
		  INNER JOIN RH.tblPagoEmpleado pe    
		   on pe.IDEmpleado = e.IDEmpleado  
		  left join Sat.tblCatBancos b  
		 on pe.IDBanco = b.IDBanco    
		  INNER JOIN  Nomina.tblLayoutPago lp    
		   on lp.IDLayoutPago = pe.IDLayoutPago    
		  inner join Nomina.tblCatTiposLayout tl    
		   on tl.TipoLayout = 'SANTANDER'    
		   and lp.IDTipoLayout = tl.IDTipoLayout    
		  INNER JOIN Nomina.tblDetallePeriodo dp    
		   on dp.IDPeriodo = @IDPeriodo    
		   --and lp.IDConcepto = dp.IDConcepto    
		   and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
		   and dp.IDEmpleado = e.IDEmpleado    
		 where  pe.IDLayoutPago = @IDLayoutPago  

		 if object_id('tempdb..#tempBody') is not null    
			drop table #tempBody;    
    
			create table #tempBody(Respuesta nvarchar(max)); 

			insert into #tempBody(Respuesta)   
			  select     
			   [App].[fnAddString](1,'2','',2)  --Tipo de Registro
			  --+[App].[fnAddString](5,Row_Number()OVER(ORDER BY (SELECT (1)))+1,'0',1) --Contador (Num de fila) 
			  +[App].[fnAddString](5,Row_Number()OVER(ORDER BY (SELECT 1))+1,'0',1) --Contador (Num de fila)
			  --+[App].[fnAddString](7, e.ClaveEmpleado, '0', 1) + '  '  -- Clave Trabajador con espacio de 2 caracteres al final
			  +[App].[fnAddString](LEN(e.ClaveEmpleado), e.ClaveEmpleado, '0', 1) + '  '
			  --+[App].[fnAddString](7,isnull(e.ClaveEmpleado,''),' ',2)  --Clave Trabajador	
			  +[App].[fnAddString](30,isnull(e.Paterno,''),' ',2)  --Apellido Paterno
			  +[App].[fnAddString](20,isnull(e.Materno,''),' ',2)  --Apellido Materno
			  +[App].[fnAddString](30,(isnull(E.Nombre,'')+case when e.SegundoNombre<>'' then' ' else '' end+isnull(e.SegundoNombre,'')) COLLATE Cyrillic_General_CI_AI,'',2)   --Nombre
			  +[App].[fnAddString](16,isnull(pe.Cuenta,''),' ',2) --Numero de Cuenta
			  +[App].[fnAddString](18,replace(cast(isnull(case when lp.ImporteTotal = 1 then dp.ImporteTotal1 else dp.ImporteTotal2 end,0) as varchar(max)),'.',''),'0',1)  --Importe 
			  +[App].[fnAddString](2,'01','',2) --Concepto de pago
			 FROM  @empleados e     
			  INNER join Nomina.tblCatPeriodos p    
			   on p.IDPeriodo = @IDPeriodo   
			  INNER JOIN RH.tblPagoEmpleado pe    
			   on pe.IDEmpleado = e.IDEmpleado
			  left join Sat.tblCatBancos b  
				on pe.IDBanco = b.IDBanco    
			  INNER JOIN  Nomina.tblLayoutPago lp    
			   on lp.IDLayoutPago = pe.IDLayoutPago    
			  inner join Nomina.tblCatTiposLayout tl    
			   --on tl.TipoLayout = 'SCOTIABANK'    
				on lp.IDTipoLayout = tl.IDTipoLayout    
			  INNER JOIN Nomina.tblDetallePeriodo dp    
			   on dp.IDPeriodo = @IDPeriodo    
			   --and lp.IDConcepto = dp.IDConcepto    
			   and dp.IDConcepto = case when ISNULL(p.Finiquito,0) = 0 then lp.IDConcepto else lp.IDConceptoFiniquito end
			   and dp.IDEmpleado = e.IDEmpleado    
			 where  pe.IDLayoutPago = @IDLayoutPago    
			 
			  select @CountEmpleados = count(*) from #tempBody

	 -- CUERPO DE EMPLEADOS

	 -- FOOTER
	      
		if object_id('tempdb..#tempFooter') is not null    
			drop table #tempFooter;    
    
		create table #tempFooter(Respuesta nvarchar(max));    
  
		  insert into #tempFooter(Respuesta)  
		  select     
		  [App].[fnAddString](1,'3','',2)--Tipo de Registro
		  --+[App].[fnAddString](5,cast(isnull(@CountEmpleados+2,0) as varchar(6)),'0',1) --Contador (Num de fila) 
		   --+[App].[fnAddString](5,Row_Number()OVER(ORDER BY (SELECT 1)),'0',1) --Contador (Num de fila)
		  --+[App].[fnAddString](5,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1) --Total de registros
		  +[App].[fnAddString](5,cast(isnull(@CountEmpleados,0) as varchar(6))+2,'0',1) --Contador (Num de fila)
		  +[App].[fnAddString](5,cast(isnull(@CountEmpleados,0) as varchar(6)),'0',1) --Total de registros
		  +[App].[fnAddString](18, replace(cast(@SumAll as varchar(max)),'.','') ,'0',1) --Total importe de nómina
  
	 -- FOOTER

	 -- SALIDA

	  if object_id('tempdb..#tempResp') is not null    
		drop table #tempResp;    
    
    create table #tempResp(Respuesta nvarchar(max));   

	 insert into #tempResp(Respuesta)  
	 select respuesta from #tempHeader1  
	 union all  
	 select respuesta from #tempBody  
	  union all  
	 select respuesta from #tempFooter  


	 select * from #tempResp


	 -- SALIDA

END
GO
