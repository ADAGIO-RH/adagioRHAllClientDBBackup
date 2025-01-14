USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spSwitzerANS] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null

	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare --@dtFiltros [Nomina].[dtFiltrosRH]
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
			,@ValorUMA Decimal(18,2)
			,@SalarioMinimo Decimal(18,2)
	--insert into @dtFiltros(Catalogo,Value)
	--values('Departamentos',@Departamentos)
	--	,('Sucursales',@Sucursales)
	--	,('Puestos',@Puestos)
	--	,('RazonesSociales',@RazonesSociales)
	--	,('RegPatronales',@RegPatronales)
	--	,('Divisiones',@Divisiones)
	--	,('Prestaciones',@Prestaciones)
	--	,('Clientes',@Cliente)

	
	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))




   select top 1 @ValorUMA = isnull(UMA,0) , @SalarioMinimo = isnull(SalarioMinimo,0)-- Aqui se obtiene el valor del Salario Minimo del catalogo de Salarios minimos  
   from Nomina.tblSalariosMinimos  
   where Year(Fecha) = year(@FechaFin)  
   ORder by Fecha Desc  



	set @Titulo = UPPER( 'REPORTE SWITZER ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)
	
	
	if OBJECT_ID('tempdb..#tblTempJefes') is not null drop table #tblTempJefes;

	select  isnull(JE.IDEmpleado,'') as IDEmpleado,
			isnull(Emp.ClaveEmpleado,'') as ClaveEmpleado,
			isnull(Emp.NOMBRECOMPLETO,'') as NombreEmpleado,
			isnull(JE.IDJefe,'') as IDJefe,
			isnull(Em.ClaveEmpleado,'') as ClaveJefe,
			isnull(Em.NOMBRECOMPLETO,'') as NombreJefe
		into #tblTempJefes
	 from rh.tblJefesEmpleados JE
		inner join rh.tblEmpleadosmaster Em
			on JE.IDJefe = Em.IDEmpleado
		inner join rh.tblEmpleadosMaster Emp
			on Emp.IDEmpleado = JE.IDEmpleado
		order by emp.ClaveEmpleado
	
	
	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			  ROW_NUMBER () over(order by M.ClaveEmpleado Asc) as [No.]
			 ,m.ClaveEmpleado as [Emp. No.]
			,concat( isnull (m.Nombre,''),' ',isnull (m.SegundoNombre,'')) AS [Name]
			,concat (isnull(m.Paterno,''),' ',isnull(m.Materno,'')) AS [Last Name]
			--,ISNULL(DEENC.Valor,'') AS [Preferred First Name]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [Birthdate]
			,m.Puesto AS [Job Title]
			,case when charindex ('-',m.Sucursal) = 0 then 'SIN SUCURSAL' ELSE SUBSTRING (m.sucursal,1, charindex ('-',m.Sucursal)-1) END as [DL/IL/SG&A]
			,CASE WHEN M.TipoNomina = 'SEMANAL' THEN 'DIRECT'
			      ELSE 'INDIRECT' END AS [Statutory Classification]
			,m.Departamento AS Departament
			,'MEX' AS [Division Code]
			,CCC.Codigo as [Cost Center]
			,'0000' as [Region Code]
			,m.ClasificacionCorporativa as [corporate classification]
			,De.CuentaContable as [Product Line]
			,case when m.IDEmpleado not in (Select TJ.IDEmpleado from #tblTempJefes) Then 
				       NULL else isnull(TJ.ClaveJefe,'000') End as [Supervisor Number]
			
            -- ,case when m.IDEmpleado not in (Select TJ.IDEmpleado from #tblTempJefes) then
			--  EXT.Valor ELSE isnull(TJ.NombreJefe,'') END as [Supervisor Name]
            ,ISNULL(ISNULL(TJ.NombreJefe,EXT.Valor),' ') AS [Supervisor Name]
			--  EXT.Valor ELSE isnull(TJ.NombreJefe,'') END as [Supervisor Name]
			
            ,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [Hire Date]
			,m.SalarioDiario AS [Daily Salary]
			,cast (case when  M.TipoNomina = 'SEMANAL' THEN
				isnull(m.SalarioDiario,0) * 30.4
			 Else isnull(m.SalarioDiario,0) * 30
			 END as decimal(16,2))as [Monthly Salary]
			,isnull(PD.DiasVacaciones,'0')[Days Off]
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) as [Monthly Christmas Bonus]
			,cast( (((isnull(m.SalarioDiario,0) * isnull(PD.DiasVacaciones,0)) * isnull(PD.PrimaVacacional,0)) /12) as decimal(16,2)) as [Monthly Vacation Premium]
			,cast ((case when M.TipoNomina = 'SEMANAL' then 
							case when (isnull(m.SalarioDiario,0) * 30.4) * 0.10 > ( @ValorUMA * 30) THEN ( @ValorUMA * 30)
							     ELSE (isnull(m.SalarioDiario,0) * 30.4) * 0.10 END
					     else
							case when (isnull(m.SalarioDiario,0) * 30) * 0.10 > ( @ValorUMA * 30) then ( @ValorUMA * 30)
								 else(isnull(m.SalarioDiario,0) * 30) * 0.10 end
							end ) as decimal(16,2)) as [Monthly Food Coupons]
			,cast ((case when M.TipoNomina = 'SEMANAL' then (isnull(m.SalarioDiario,0) * 30.4) * 0.10
						 else(isnull(m.SalarioDiario,0) * 30) * 0.10
							end ) as decimal(16,2)) as [Monthly Saving Fund] 
		   ---------------------------------------------------------------------------------
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) + --Monthly Christmas Bonus
			 cast( (((isnull(m.SalarioDiario,0) * isnull(PD.DiasVacaciones,0)) * isnull(PD.PrimaVacacional,0)) /12) as decimal(16,2)) + --Monthly Vacation Premium
			 cast ((case when M.TipoNomina = 'SEMANAL' then 
							case when (isnull(m.SalarioDiario,0) * 30.4) * 0.10 > ( @ValorUMA * 30) THEN ( @ValorUMA * 30)
							     ELSE (isnull(m.SalarioDiario,0) * 30.4) * 0.10 END
					     else
							case when (isnull(m.SalarioDiario,0) * 30) * 0.10 > ( @ValorUMA * 30) then ( @ValorUMA * 30)
								 else(isnull(m.SalarioDiario,0) * 30) * 0.10 end
							end ) as decimal(16,2)) + --Monthly Food Coupons
			 cast ((case when M.TipoNomina = 'SEMANAL' then (isnull(m.SalarioDiario,0) * 30.4) * 0.10
						 else(isnull(m.SalarioDiario,0) * 30) * 0.10
							end ) as decimal(16,2)) -- Monthly Saving Fund
			as [Total Monthly Benefits]
		---------------------------------------------------------
			,isnull(m.SalarioDiario,0) * 365 as [Annual Salary]
			,Expuesto.Valor as [Salary Grade]
			,'0000' as [Last Review Date]
			,'0000' as [Last Review Score]
			,'0000' as [Next Review Date]
			,'52(33)3836-3700' as [Phone No.]
			,CEExt.Value as [Phone Ext.]
			,'' as [Cel No.]
			,isnull(CE.Value,'') as [E-mail]
			,case When m.Sexo = 'FEMENINO' then 'F'
				  when m.Sexo = 'MASCULINO' then 'M' else '' end AS [Gender]
			,case when CCC.CuentaContable = '01' then 'Operations'
				  when CCC.CuentaContable = '02' then 'Quality'
				  when CCC.CuentaContable = '03' then 'Facilities'
				  when CCC.CuentaContable = '04' then 'I.S.'
				  when CCC.CuentaContable = '05' then 'Human Resources'
				  when CCC.CuentaContable = '06' then 'Finance'
				  when CCC.CuentaContable = '07' then 'Sales'
				  else '' end as [Head Count Category]
			,case when TT.Descripcion  = 'PERMANENTE' THEN 'Regular' 
			      else 'Temporary'end as [Status]
		from RH.tblEmpleadosMaster M with (nolock) 
			left join @dtEmpleados dte on dte.IDEmpleado = m.IDEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on dte.IDTipoPrestacion = TP.IDTipoPrestacion
			
			--inner join [RH].[tblPrestacionesEmpleado] Pre
			--	on Pre.IDEmpleado = M.IDEmpleado
			left join #tblTempJefes TJ
				on TJ.IDEmpleado = M.IDEmpleado
            left join RH.tblDatosExtraEmpleados EXT
                ON EXT.IDEmpleado=M.IDEmpleado AND EXT.IDDatoExtra=1   
			left join [RH].[tblCatTiposPrestacionesDetalle] PD
				on PD.IDTipoPrestacion = TP.IDTipoPrestacion
					and PD.Antiguedad = (select (DATEDIFF(day,M.FechaAntiguedad,@FechaFin) / 365 ) + 1)
			
			
			--left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
			--	on m.IDEmpleado = PTU.IDEmpleado
			--left join RH.tblSaludEmpleado SE with (nolock) 
			--	on SE.IDEmpleado = M.IDEmpleado
			--left join RH.tblDireccionEmpleado direccion with (nolock) 
			--	on direccion.IDEmpleado = M.IDEmpleado
			--	AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			--left join SAT.tblCatColonias c with (nolock) 
			--	on direccion.IDColonia = c.IDColonia
			--left join SAT.tblCatMunicipios Muni with (nolock) 
			--	on muni.IDMunicipio = direccion.IDMunicipio
			--left join SAT.tblCatEstados EST with (nolock) 
			--	on EST.IDEstado = direccion.IDEstado 
			--left join SAT.tblCatLocalidades localidades with (nolock) 
			--	on localidades.IDLocalidad = direccion.IDLocalidad 
			--left join SAT.tblCatCodigosPostales CP with (nolock) 
			--	on CP.IDCodigoPostal = direccion.IDCodigoPostal
			--left join RH.tblCatRutasTransporte rutas with (nolock) 
			--	on direccion.IDRuta = rutas.IDRuta
			--left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
			--	on Infonavit.IDEmpleado = m.IDEmpleado
			--		and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			--left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
			--	on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			--left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
			--	on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			--left join RH.tblPagoEmpleado PE with (nolock) 
			--	on PE.IDEmpleado = M.IDEmpleado
			--		and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			--left join Nomina.tblLayoutPago LP with (nolock) 
			--	on LP.IDLayoutPago = PE.IDLayoutPago
			--		and LP.IDConcepto = PE.IDConcepto
			--left join SAT.tblCatBancos bancos with (nolock) 
			--	on bancos.IDBanco = PE.IDBanco
			----left join RH.tblTipoTrabajadorEmpleado TTE
			----	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
			left join rh.tblCatCentroCosto CCC 
				on CCC.IDCentroCosto = M.IDCentroCosto
			Left join RH.tblDatosExtraEmpleados DEENC
				on DEENC.IDEmpleado = M.IDEmpleado
					and DEENC.IDDatoExtra = 2
			Left join RH.tblcatdepartamentos De
				on De.IDDepartamento = M.IDDepartamento
			Left join RH.tblDatosExtraEmpleados DEESUP
				on DEESUP.IDEmpleado = M.IDEmpleado
					and DEESUP.IDDatoExtra = 1
			left join [RH].[tblContactoEmpleado] CE
				on CE.IDEmpleado = M.IDEmpleado
					and CE.IDTipoContactoEmpleado = 1 and predeterminado = 1
			left join RH.tblCatPuestos Pu
				on Pu.IDPuesto = M.IDPuesto
			left join [RH].[tblContactoEmpleado] CEExt
				on CEExt.IDEmpleado = M.IDEmpleado
					and CEExt.IDTipoContactoEmpleado = 6
			left join [App].[tblValoresDatosExtras] Expuesto  on Expuesto.IDReferencia=Pu.IDPuesto 
				and Expuesto.IDDatoExtra= (select iddatoextra from  [App].[tblCatDatosExtras] where Traduccion like '%nivel salarial%')
		Where 
		m.Vigente=1 and
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		
			select 
			ROW_NUMBER () over(order by M.ClaveEmpleado Asc) as [No.]
			,m.ClaveEmpleado as [Emp. No.]
			,concat( isnull (m.Nombre,''),' ',isnull (m.SegundoNombre,'')) AS [Name]
			,concat (isnull(m.Paterno,''),' ',isnull(m.Materno,'')) AS [Last Name]
			--,ISNULL(DEENC.Valor,'') AS [Preferred First Name]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [Birthdate]
			,m.Puesto AS [Job Title]
			,case when charindex ('-',m.Sucursal) = 0 then 'SIN SUCURSAL' ELSE SUBSTRING (m.sucursal,1, charindex ('-',m.Sucursal)-1) END as [DL/IL/SG&A]
			,CASE WHEN M.IDTipoNomina = 1 THEN 'DIRECT'
			      ELSE 'INDIRECT' END AS [Statutory Classification]
			,m.Departamento AS Departament
			,'MEX' AS [Division Code]
			,CCC.Codigo as [Cost Center]
			,'0000' as [Region Code]
			,m.ClasificacionCorporativa as [corporate classification]
			,De.CuentaContable as [Product Line]
			,isnull(TJ.ClaveJefe,'000') as [Supervisor Number]
			--,isnull(TJ.NombreJefe,'') as [Supervisor Name]
            ,ISNULL(ISNULL(TJ.NombreJefe,EXT.Valor),' ') AS [Supervisor Name]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [Hire Date]
			,m.SalarioDiario AS [Daily Salary]
			,cast (case when  M.IDTipoNomina = 1 THEN
				isnull(m.SalarioDiario,0) * 30.4
			 Else isnull(m.SalarioDiario,0) * 30
			 END as decimal(16,2))as [Monthly Salary]
			,isnull(PD.DiasVacaciones,'0')[Days Off]
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) as [Monthly Christmas Bonus]
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) as [Monthly Christmas Bonus]
			,cast( (((isnull(m.SalarioDiario,0) * isnull(PD.DiasVacaciones,0)) * isnull(PD.PrimaVacacional,0)) /12) as decimal(16,2)) as [Monthly Vacation Premium]
			,cast ((case when M.IDTipoNomina = 1 then 
							case when (isnull(m.SalarioDiario,0) * 30.4) * 0.10 > ( @ValorUMA * 30) THEN ( @ValorUMA * 30)
							     ELSE (isnull(m.SalarioDiario,0) * 30.4) * 0.10 END
					     else
							case when (isnull(m.SalarioDiario,0) * 30) * 0.10 > ( @ValorUMA * 30) then ( @ValorUMA * 30)
								 else(isnull(m.SalarioDiario,0) * 30) * 0.10 end
							end ) as decimal(16,2)) as [Monthly Food Coupons]
			,cast ((case when M.IDTipoNomina = 1 then (isnull(m.SalarioDiario,0) * 30.4) * 0.10
						 else(isnull(m.SalarioDiario,0) * 30) * 0.10
							end ) as decimal(16,2)) as [Monthly Saving Fund] 
		   ---------------------------------------------------------------------------------
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) + --Monthly Christmas Bonus
			 cast( (((isnull(m.SalarioDiario,0) * isnull(PD.DiasVacaciones,0)) * isnull(PD.PrimaVacacional,0)) /12) as decimal(16,2)) + --Monthly Vacation Premium
			 cast ((case when M.IDTipoNomina = 1 then 
							case when (isnull(m.SalarioDiario,0) * 30.4) * 0.10 > ( @ValorUMA * 30) THEN ( @ValorUMA * 30)
							     ELSE (isnull(m.SalarioDiario,0) * 30.4) * 0.10 END
					     else
							case when (isnull(m.SalarioDiario,0) * 30) * 0.10 > ( @ValorUMA * 30) then ( @ValorUMA * 30)
								 else(isnull(m.SalarioDiario,0) * 30) * 0.10 end
							end ) as decimal(16,2)) + --Monthly Food Coupons
			 cast ((case when M.IDTipoNomina = 1 then (isnull(m.SalarioDiario,0) * 30.4) * 0.10
						 else(isnull(m.SalarioDiario,0) * 30) * 0.10
							end ) as decimal(16,2)) -- Monthly Saving Fund
			as [Total Monthly Benefits]
		---------------------------------------------------------
			,isnull(m.SalarioDiario,0) * 365 as [Annual Salary]
			,Expuesto.Valor as [Salary Grade]
			,'0000' as [Last Review Date]
			,'0000' as [Last Review Score]
			,'0000' as [Next Review Date]
			,'52(33)3836-3700' as [Phone No.]
			,CEExt.Value as [Phone Ext.]
			,'' as [Cel No.]
			,isnull(CE.Value,'') as [E-mail]
			,case When m.Sexo = 'FEMENINO' then 'F'
				  when m.Sexo = 'MASCULINO' then 'M' else '' end AS [Gender]
			,case when CCC.CuentaContable = '01' then 'Operations'
				  when CCC.CuentaContable = '02' then 'Quality'
				  when CCC.CuentaContable = '03' then 'Facilities'
				  when CCC.CuentaContable = '04' then 'I.S.'
				  when CCC.CuentaContable = '05' then 'Human Resources'
				  when CCC.CuentaContable = '06' then 'Finance'
				  when CCC.CuentaContable = '07' then 'Sales'
				  else '' end as [Head Count Category]
			,case when TT.Descripcion  = 'PERMANENTE' THEN 'Regular' 
			      else 'Temporary'end as [Status]
			,case when M.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			
			inner join [RH].[tblPrestacionesEmpleado] Pre
				on Pre.IDEmpleado = M.IDEmpleado
			left join #tblTempJefes TJ
				on TJ.IDEmpleado = M.IDEmpleado
            left join RH.tblDatosExtraEmpleados EXT
                ON EXT.IDEmpleado=M.IDEmpleado AND EXT.IDDatoExtra=1    
			left join [RH].[tblCatTiposPrestacionesDetalle] PD
				on PD.IDTipoPrestacion = Pre.IDTipoPrestacion
					and PD.Antiguedad = (select (DATEDIFF(day,M.FechaAntiguedad,@FechaFin) / 365 ) + 1)

			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
			left join rh.tblCatCentroCosto CCC 
				on CCC.IDCentroCosto = M.IDCentroCosto
			Left join RH.tblDatosExtraEmpleados DEENC
				on DEENC.IDEmpleado = M.IDEmpleado
					and DEENC.IDDatoExtra = 2
			Left join RH.tblcatdepartamentos De
				on De.IDDepartamento = M.IDDepartamento
			Left join RH.tblDatosExtraEmpleados DEESUP
				on DEESUP.IDEmpleado = M.IDEmpleado
					and DEESUP.IDDatoExtra = 1
			left join [RH].[tblContactoEmpleado] CE
				on CE.IDEmpleado = M.IDEmpleado
					and CE.IDTipoContactoEmpleado = 1 and predeterminado = 1
			left join RH.tblCatPuestos Pu
				on Pu.IDPuesto = M.IDPuesto
			left join [RH].[tblContactoEmpleado] CEExt
				on CEExt.IDEmpleado = M.IDEmpleado
					and CEExt.IDTipoContactoEmpleado = 6
			left join [App].[tblValoresDatosExtras] Expuesto  on Expuesto.IDReferencia=Pu.IDPuesto 
				and Expuesto.IDDatoExtra= (select iddatoextra from  [App].[tblCatDatosExtras] where Traduccion like '%nivel salarial%')
		Where 
		M.Vigente =0 and
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
			select 
			ROW_NUMBER () over(order by M.ClaveEmpleado Asc) as [No.]
			,m.ClaveEmpleado as [Emp. No.]
			,concat( isnull (m.Nombre,''),' ',isnull (m.SegundoNombre,'')) AS [Name]
			,concat (isnull(m.Paterno,''),' ',isnull(m.Materno,'')) AS [Last Name]
			--,ISNULL(DEENC.Valor,'') AS [Preferred First Name]
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [Birthdate]
			,m.Puesto AS [Job Title]
			,case when charindex ('-',m.Sucursal) = 0 then 'SIN SUCURSAL' ELSE SUBSTRING (m.sucursal,1, charindex ('-',m.Sucursal)-1) END as [DL/IL/SG&A]
			,CASE WHEN M.IDTipoNomina = 1 THEN 'DIRECT'
			      ELSE 'INDIRECT' END AS [Statutory Classification]
			,m.Departamento AS Departament
			,'MEX' AS [Division Code]
			,m.IDCentroCosto as [Cost Center]
			,'0000' as [Region Code]
			,m.ClasificacionCorporativa as [corporate classification]
			,De.CuentaContable as [Product Line]
			,ISNULL(ISNULL(TJ.NombreJefe,EXT.Valor),' ') AS [Supervisor Name]
			,isnull(TJ.NombreJefe,'') as [Supervisor Name]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [Hire Date]
			,m.SalarioDiario AS [Daily Salary]
			,cast (case when  M.IDTipoNomina = 1 THEN
				isnull(m.SalarioDiario,0) * 30.4
			 Else isnull(m.SalarioDiario,0) * 30
			 END as decimal(16,2))as [Monthly Salary]
			,isnull(PD.DiasVacaciones,'0')[Days Off]
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) as [Monthly Christmas Bonus]
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) as [Monthly Christmas Bonus]
			,cast( (((isnull(m.SalarioDiario,0) * isnull(PD.DiasVacaciones,0)) * isnull(PD.PrimaVacacional,0)) /12) as decimal(16,2)) as [Monthly Vacation Premium]
			,cast ((case when M.IDTipoNomina = 1 then 
							case when (isnull(m.SalarioDiario,0) * 30.4) * 0.10 > ( @ValorUMA * 30) THEN ( @ValorUMA * 30)
							     ELSE (isnull(m.SalarioDiario,0) * 30.4) * 0.10 END
					     else
							case when (isnull(m.SalarioDiario,0) * 30) * 0.10 > ( @ValorUMA * 30) then ( @ValorUMA * 30)
								 else(isnull(m.SalarioDiario,0) * 30) * 0.10 end
							end ) as decimal(16,2)) as [Monthly Food Coupons]
			,cast ((case when M.IDTipoNomina = 1 then (isnull(m.SalarioDiario,0) * 30.4) * 0.10
						 else(isnull(m.SalarioDiario,0) * 30) * 0.10
							end ) as decimal(16,2)) as [Monthly Saving Fund] 
		   ---------------------------------------------------------------------------------
			,cast(((isnull(PD.DiasAguinaldo,'0') * ISNULL(m.SalarioDiario,0)) /12) as decimal(16,2)) + --Monthly Christmas Bonus
			 cast( (((isnull(m.SalarioDiario,0) * isnull(PD.DiasVacaciones,0)) * isnull(PD.PrimaVacacional,0)) /12) as decimal(16,2)) + --Monthly Vacation Premium
			 cast ((case when M.IDTipoNomina = 1 then 
							case when (isnull(m.SalarioDiario,0) * 30.4) * 0.10 > ( @ValorUMA * 30) THEN ( @ValorUMA * 30)
							     ELSE (isnull(m.SalarioDiario,0) * 30.4) * 0.10 END
					     else
							case when (isnull(m.SalarioDiario,0) * 30) * 0.10 > ( @ValorUMA * 30) then ( @ValorUMA * 30)
								 else(isnull(m.SalarioDiario,0) * 30) * 0.10 end
							end ) as decimal(16,2)) + --Monthly Food Coupons
			 cast ((case when M.IDTipoNomina = 1 then (isnull(m.SalarioDiario,0) * 30.4) * 0.10
						 else(isnull(m.SalarioDiario,0) * 30) * 0.10
							end ) as decimal(16,2)) -- Monthly Saving Fund
			as [Total Monthly Benefits]
		---------------------------------------------------------
			,isnull(m.SalarioDiario,0) * 365 as [Annual Salary]
			,Expuesto.Valor as [Salary Grade]
			,'0000' as [Last Review Date]
			,'0000' as [Last Review Score]
			,'0000' as [Next Review Date]
			,'52(33)3836-3700' as [Phone No.]
			,CEExt.Value as [Phone Ext.]
			,'' as [Cel No.]
			,isnull(CE.Value,'') as [E-mail]
			,case When m.Sexo = 'FEMENINO' then 'F'
				  when m.Sexo = 'MASCULINO' then 'M' else '' end AS [Gender]
			,case when CCC.CuentaContable = '01' then 'Operations'
				  when CCC.CuentaContable = '02' then 'Quality'
				  when CCC.CuentaContable = '03' then 'Facilities'
				  when CCC.CuentaContable = '04' then 'I.S.'
				  when CCC.CuentaContable = '05' then 'Human Resources'
				  when CCC.CuentaContable = '06' then 'Finance'
				  when CCC.CuentaContable = '07' then 'Sales'
				  else '' end as [Head Count Category]
			,case when TT.Descripcion  = 'PERMANENTE' THEN 'Regular' 
			      else 'Temporary'end as [Status]
			,case when M.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			
			inner join [RH].[tblPrestacionesEmpleado] Pre
				on Pre.IDEmpleado = M.IDEmpleado
			left join #tblTempJefes TJ
				on TJ.IDEmpleado = M.IDEmpleado
            left join rh.tblDatosExtraEmpleados EXT
                on EXT.IDEmpleado=M.IDEmpleado AND EXT.IDDatoExtra=1
			left join [RH].[tblCatTiposPrestacionesDetalle] PD
				on PD.IDTipoPrestacion = Pre.IDTipoPrestacion
					and PD.Antiguedad = (select (DATEDIFF(day,M.FechaAntiguedad,@FechaFin) / 365 ) + 1)
			
			
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
			left join rh.tblCatCentroCosto CCC 
				on CCC.IDCentroCosto = M.IDCentroCosto
			Left join RH.tblDatosExtraEmpleados DEENC
				on DEENC.IDEmpleado = M.IDEmpleado
					and DEENC.IDDatoExtra = 2
			Left join RH.tblcatdepartamentos De
				on De.IDDepartamento = M.IDDepartamento
			Left join RH.tblDatosExtraEmpleados DEESUP
				on DEESUP.IDEmpleado = M.IDEmpleado
					and DEESUP.IDDatoExtra = 1
			left join [RH].[tblContactoEmpleado] CE
				on CE.IDEmpleado = M.IDEmpleado
					and CE.IDTipoContactoEmpleado = 1 and predeterminado = 1
			left join RH.tblCatPuestos Pu
				on Pu.IDPuesto = M.IDPuesto
			left join [RH].[tblContactoEmpleado] CEExt
				on CEExt.IDEmpleado = M.IDEmpleado
					and CEExt.IDTipoContactoEmpleado = 6
			left join [App].[tblValoresDatosExtras] Expuesto  on Expuesto.IDReferencia=Pu.IDPuesto 
				and Expuesto.IDDatoExtra= (select iddatoextra from  [App].[tblCatDatosExtras] where Traduccion like '%nivel salarial%')
		Where 
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END
END
GO
