USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesNexusSalarioMensual] (
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

	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)


	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')		is not null drop table ##tempDatosExtraEmpleados

	select distinct 
		c.IDDatoExtra,
		C.Nombre,
		C.Descripcion
	into #tempDatosExtra
	from (select 
			*
		from RH.tblCatDatosExtra
		) c 

	Select
		M.IDEmpleado
		,CDE.IDDatoExtra
		,CDE.Nombre
		,CDE.Descripcion
		,DE.Valor
	into #tempData
	from RH.tblEmpleadosMaster M
		inner join RH.tblDatosExtraEmpleados DE
			on M.IDEmpleado = DE.IDEmpleado
		inner join RH.tblCatDatosExtra CDE
			on DE.IDDatoExtra = CDE.IDDatoExtra
	


	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Nombre)+',0) AS '+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');


	set @query1 = 'SELECT IDEmpleado, ' + @cols + ' 
					into ##tempDatosExtraEmpleados
					from 
				(
					select IDEmpleado
						,Nombre
						,Valor
					from #tempData
			   ) x'

	set @query2 = '
				pivot 
				(
					 MAX(Valor)
					for Nombre in (' + @colsAlone + ')
				) p 
				order by IDEmpleado
				'

	--select len(@query1) +len( @query2) 
	exec( @query1 + @query2) 

	--select * from ##tempDatosExtraEmpleados


	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select m.ClaveEmpleado as CLAVE
		     ,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]
			 ,m.CentroCosto AS [CENTRO COSTO]
			 ,m.Region AS REGION
			 ,m.Sucursal AS SUCURSAL
			 ,m.Departamento AS DEPARTAMENTO
			 ,m.Puesto AS PUESTO
			 ,m.ClasificacionCorporativa as [CLASIFICACION CORPORATIVA]
			 ,tp.Descripcion as [TIPO PRESTACION]
			 ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as Supervisor
			 ,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			 ,CASE WHEN M.Cliente = 'NEXUS TOURS MÉXICO' THEN m.SalarioDiario * 30 
					WHEN M.Cliente = 'NEXUS TOURS JAMAICA' THEN m.SalarioDiario * 20
					WHEN M.Cliente = 'NEXUS TOURS COSTA RICA' THEN m.SalarioDiario * 30
					WHEN M.Cliente = 'NEXUS TOURS REPUBLICA DOMINICANA' THEN m.SalarioDiario * 30
					WHEN M.Cliente = 'NEXUS TOURS ANTIGUA' THEN m.SalarioDiario * 26
					WHEN M.Cliente = 'NEXUS TOURS ST. LUCIA' THEN m.SalarioDiario * 24
					ELSE m.SalarioDiario * 30
			  END AS [SALARIO MENSUAL]
			   ,isnull(deex.moneda,0) as MONEDA
			  ,m.Division AS DIVISION
			  ,m.Sexo AS SEXO
			  ,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			  ,cte.[Value] as [Email Empresarial]
			  ,m.Area AS AREA
			
		from @dtEmpleados m
		inner join RH.tblEmpleadosMaster Mast with (nolock) 
			on m.IDEmpleado = mast.IDEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
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
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
			left join RH.tblContactoEmpleado ct 
				on m.IDEmpleado = ct.IDEmpleado and ct.IDTipoContactoEmpleado = 1 --EMAIL
			left join RH.tblContactoEmpleado cte
				on m.IDEmpleado = cte.IDEmpleado and cte.IDTipoContactoEmpleado = 5 --EMAIL EMPRESARIAL
			left join RH.tblContactoEmpleado ctt
				on m.IDEmpleado = ctt.IDEmpleado and ctt.IDTipoContactoEmpleado = 4 --TELEFONO
			left join RH.tblContactoEmpleado ctm
				on m.IDEmpleado = ctm.IDEmpleado and ctm.IDTipoContactoEmpleado = 2 --TELEFONO MOVIL
			left join RH.tblContactoEmpleado ctc
				on m.IDEmpleado = ctc.IDEmpleado and ctc.IDTipoContactoEmpleado = 3 --TELEFONO CASA
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDFamiliarBenificiarioEmpleado) as [Row]
						from [RH].[TblFamiliaresBenificiariosEmpleados] with (nolock)  
					) as fbe
				on  fbe.IDEmpleado =m.IDEmpleado and fbe.[Row] = 1 --BENEFICIARIOS


			order by M.ClaveEmpleado asc

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		
			select m.ClaveEmpleado as CLAVE
		     ,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]
			 ,m.CentroCosto AS [CENTRO COSTO]
			 ,m.Region AS REGION
			 ,m.Sucursal AS SUCURSAL
			 ,m.Departamento AS DEPARTAMENTO
			 ,m.Puesto AS PUESTO
			 ,m.ClasificacionCorporativa as [CLASIFICACION CORPORATIVA]
			 ,tp.Descripcion as [TIPO PRESTACION]
			 ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as Supervisor
			 ,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			 ,CASE WHEN M.Cliente = 'NEXUS TOURS MÉXICO' THEN m.SalarioDiario * 30 
			  WHEN M.Cliente = 'NEXUS TOURS JAMAICA' THEN m.SalarioDiario * 20
			  WHEN M.Cliente = 'NEXUS TOURS COSTA RICA' THEN m.SalarioDiario * 30
			  END AS [SALARIO MENSUAL]
			  ,isnull(deex.moneda,0) as MONEDA
			  ,m.Division AS DIVISION
			  ,m.Sexo AS SEXO
			  ,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			  ,cte.[Value] as [Email Empresarial]
			  ,m.Area AS AREA
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
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
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
			left join RH.tblContactoEmpleado ct 
				on m.IDEmpleado = ct.IDEmpleado and ct.IDTipoContactoEmpleado = 1 --EMAIL
			left join RH.tblContactoEmpleado cte
				on m.IDEmpleado = cte.IDEmpleado and cte.IDTipoContactoEmpleado = 5 --EMAIL EMPRESARIAL
			left join RH.tblContactoEmpleado ctt
				on m.IDEmpleado = ctt.IDEmpleado and ctt.IDTipoContactoEmpleado = 4 --TELEFONO
			left join RH.tblContactoEmpleado ctm
				on m.IDEmpleado = ctm.IDEmpleado and ctm.IDTipoContactoEmpleado = 2 --TELEFONO MOVIL
			left join RH.tblContactoEmpleado ctc
				on m.IDEmpleado = ctc.IDEmpleado and ctc.IDTipoContactoEmpleado = 3 --TELEFONO CASA
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDFamiliarBenificiarioEmpleado) as [Row]
						from [RH].[TblFamiliaresBenificiariosEmpleados] with (nolock)  
					) as fbe
				on  fbe.IDEmpleado =m.IDEmpleado and fbe.[Row] = 1 --BENEFICIARIOS


			--order by M.ClaveEmpleado asc

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
		and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
			select m.ClaveEmpleado as CLAVE
		     ,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]
			 ,m.CentroCosto AS [CENTRO COSTO]
			 ,m.Region AS REGION
			 ,m.Sucursal AS SUCURSAL
			 ,m.Departamento AS DEPARTAMENTO
			 ,m.Puesto AS PUESTO
			 ,m.ClasificacionCorporativa as [CLASIFICACION CORPORATIVA]
			 ,tp.Descripcion as [TIPO PRESTACION]
			 ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as Supervisor
			 ,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
			 ,CASE WHEN M.Cliente = 'NEXUS TOURS MÉXICO' THEN m.SalarioDiario * 30 
			  WHEN M.Cliente = 'NEXUS TOURS JAMAICA' THEN m.SalarioDiario * 20
			  WHEN M.Cliente = 'NEXUS TOURS COSTA RICA' THEN m.SalarioDiario * 30
			  END AS [SALARIO MENSUAL]
			   ,isnull(deex.moneda,0) as MONEDA
			  ,m.Division AS DIVISION
			  ,m.Sexo AS SEXO
			  ,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			  ,cte.[Value] as [Email Empresarial]
			  ,m.Area AS AREA
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
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
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
			left join RH.tblContactoEmpleado ct 
				on m.IDEmpleado = ct.IDEmpleado and ct.IDTipoContactoEmpleado = 1 --EMAIL
			left join RH.tblContactoEmpleado cte
				on m.IDEmpleado = cte.IDEmpleado and cte.IDTipoContactoEmpleado = 5 --EMAIL EMPRESARIAL
			left join RH.tblContactoEmpleado ctt
				on m.IDEmpleado = ctt.IDEmpleado and ctt.IDTipoContactoEmpleado = 4 --TELEFONO
			left join RH.tblContactoEmpleado ctm
				on m.IDEmpleado = ctm.IDEmpleado and ctm.IDTipoContactoEmpleado = 2 --TELEFONO MOVIL
			left join RH.tblContactoEmpleado ctc
				on m.IDEmpleado = ctc.IDEmpleado and ctc.IDTipoContactoEmpleado = 3 --TELEFONO CASA
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDFamiliarBenificiarioEmpleado) as [Row]
						from [RH].[TblFamiliaresBenificiariosEmpleados] with (nolock)  
					) as fbe
				on  fbe.IDEmpleado =m.IDEmpleado and fbe.[Row] = 1 --BENEFICIARIOS

			--order by M.ClaveEmpleado asc

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
		 and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END
END
GO
