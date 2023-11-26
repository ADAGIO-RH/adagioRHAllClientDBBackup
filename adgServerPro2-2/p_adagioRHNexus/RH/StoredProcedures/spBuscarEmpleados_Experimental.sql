USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarEmpleados_Experimental](    
	@FechaIni date = '1900-01-01',
	@Fechafin date = '9999-12-31',
	@IDUsuario int = 0,
	@EmpleadoIni Varchar(20) = '0',
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',
	@IDTipoNomina int = 0,
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY
)
AS
BEGIN
	--SET QUERY_GOVERNOR_COST_LIMIT 0;        
	SET FMTONLY OFF;    

	set @FechaIni = isnull(@FechaIni,'1900-01-01')
	set @Fechafin = isnull(@Fechafin,'9999-12-31')


	DECLARE 
		@dtVigenciaEmpleados [RH].[dtVigenciaEmpleado],
		@dtContratosEmpleado [RH].[dtContratosEmpleados],
		@dtEmpleados [RH].[dtEmpleados],
		@QuerySelect Varchar(Max) = '',
		@QuerySelect2 Varchar(Max) = '',
		@QueryFrom Varchar(Max) = '',
		@QueryFrom2 Varchar(Max) = '',
		@QueryWhere Varchar(Max) = '',
		@LenFrom int,
		@IDIdioma varchar(20),
		@Conjuncion varchar(3) = 'AND'
	;
        
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempFiltros') is not null drop table #tempFiltros;  
	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil    
	if object_id('tempdb..#dtEmpleados') is not null drop table #dtEmpleados

		--

	CREATE table #dtEmpleados(
		[IDEmpleado] [int] NULL INDEX IDX_dtEmpleados_3LKJLKD_ID NONCLUSTERED([IDEmpleado] ASC) ,
		[ClaveEmpleado] [varchar](20) NULL,
		[RFC] [varchar](20) NULL,
		[CURP] [varchar](20) NULL,
		[IMSS] [varchar](20) NULL,
		[Nombre] [varchar](50) NULL,
		[SegundoNombre] [varchar](50) NULL,
		[Paterno] [varchar](50) NULL,
		[Materno] [varchar](50) NULL,
		[NOMBRECOMPLETO] [varchar](50) NULL,
		[IDLocalidadNacimiento] [int] NULL,
		[LocalidadNacimiento] [varchar](100) NULL,
		[IDMunicipioNacimiento] [int] NULL,
		[MunicipioNacimiento] [varchar](100) NULL,
		[IDEstadoNacimiento] [int] NULL,
		[EstadoNacimiento] [varchar](100) NULL,
		[IDPaisNacimiento] [int] NULL,
		[PaisNacimiento] [varchar](100) NULL,
		[FechaNacimiento] [date] NULL,
		[IDEstadoCiviL] [int] NULL,
		[EstadoCivil] [varchar](100) NULL,
		[Sexo] [varchar](15) NULL,
		[IDEscolaridad] [int] NULL,
		[Escolaridad] [varchar](100) NULL,
		[DescripcionEscolaridad] [varchar](100) NULL,
		[IDInstitucion] [int] NULL,
		[Institucion] [varchar](100) NULL,
		[IDProbatorio] [int] NULL,
		[Probatorio] [varchar](100) NULL,
		[FechaPrimerIngreso] [date] NULL,
		[FechaIngreso] [date] NULL,
		[FechaAntiguedad] [date] NULL,
		[Sindicalizado] [bit] NULL,
		[IDJornadaLaboral] [int] NULL,
		[JornadaLaboral] [varchar](100) NULL,
		[UMF] [varchar](10) NULL,
		[CuentaContable] [varchar](50) NULL,
		[IDTipoRegimen] [int] NULL,
		[TipoRegimen] [varchar](200) NULL,
		[IDPreferencia] [int] NULL,
		[IDDepartamento] [int] NULL,
		[Departamento] varchar(255) NULL,
		[IDSucursal] [int] NULL,
		[Sucursal] varchar(255) NULL,
		[IDPuesto] [int] NULL,
		[Puesto] varchar(255) NULL,
		[IDCliente] [int] NULL,
		[Cliente] varchar(255) NULL,
		[IDEmpresa] [int] NULL,
		[Empresa] varchar(255) NULL,
		[IDCentroCosto] [int] NULL,
		[CentroCosto] varchar(255) NULL,
		[IDArea] [int] NULL,
		[Area] varchar(255) NULL,
		[IDDivision] [int] NULL,
		[Division] varchar(255) NULL,
		[IDRegion] [int] NULL,
		[Region] varchar(255) NULL,
		[IDClasificacionCorporativa] [int] NULL,
		[ClasificacionCorporativa] varchar(255) NULL,
		[IDRegPatronal] [int] NULL,
		[RegPatronal] varchar(255) NULL,
		[IDTipoNomina] [int] NULL,
		[TipoNomina] varchar(255) NULL,
		[SalarioDiario] [decimal](18, 2) NULL,
		[SalarioDiarioReal] [decimal](18, 2) NULL,
		[SalarioIntegrado] [decimal](18, 2) NULL,
		[SalarioVariable] [decimal](18, 2) NULL,
		[IDTipoPrestacion] [int] NULL,
		[IDRazonSocial] [int] NULL,
		[RazonSocial] varchar(255) NULL,
		[IDAfore] [int] NULL,
		[Afore] [varchar](max) NULL,
		[Vigente] [bit] NULL,
		[RowNumber] [int] NULL,
		[ClaveNombreCompleto] [varchar](500) NULL,
		[PermiteChecar] [bit] NULL,
		[RequiereChecar] [bit] NULL,
		[PagarTiempoExtra] [bit] NULL,
		[PagarPrimaDominical] [bit] NULL,
		[PagarDescansoLaborado] [bit] NULL,
		[PagarFestivoLaborado] [bit] NULL,
		[IDDocumento] [int] NULL,
		[Documento] [varchar](max) NULL,
		[IDTipoContrato] [int] NULL,
		[TipoContrato] [varchar](max) NULL,
		[FechaIniContrato] [date] NULL,
		[FechaFinContrato] [date] NULL,
		[TiposPrestacion] [varchar](max) NULL,
		[tipoTrabajadorEmpleado] [varchar](max) NULL
	)

	select *
	INTO #tempFiltros
	from @dtFiltros

	delete #tempFiltros
	where Value is null or Value = ''

	if exists(select top 1 1 from #tempFiltros where Catalogo= 'Conjuncion' and LEN([Value]) > 0)
	begin
		select @Conjuncion=Value from #tempFiltros where Catalogo= 'Conjuncion'
	end

	if (@Conjuncion not in ('OR', 'AND'))
	begin
		set @Conjuncion = 'AND'
	end

	if (isnull(@EmpleadoIni,'0') = '0' and isnull(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ') = 'ZZZZZZZZZZZZZZZZZZZZ')
	begin
		SET @EmpleadoIni = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
		SET @EmpleadoFin = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')
	end;

	if ((isnull(@IDTipoNomina,0) = 0) and exists(select top 1 1 from #tempFiltros where Catalogo= 'TiposNomina'))
	begin
		select @IDTipoNomina = cast(Value as int)
		from #tempFiltros where Catalogo= 'TiposNomina'
	end;
  
	

SET @QuerySelect = N' 
	insert into tempdb..#dtEmpleados
 SELECT 
   E.IDEmpleado
   ,UPPER(E.ClaveEmpleado)AS ClaveEmpleado
   ,UPPER(E.RFC) AS RFC
   ,UPPER(E.CURP) AS CURP
   ,UPPER(E.IMSS) AS IMSS
   ,UPPER(E.Nombre) AS Nombre
   ,UPPER(E.SegundoNombre) AS SegundoNombre 
   ,UPPER(E.Paterno) AS Paterno
   ,UPPER(E.Materno) AS Materno            
   ,substring(UPPER(COALESCE(E.Paterno,'''')+'' ''+COALESCE(E.Materno,'''')+'' ''+COALESCE(E.Nombre,'''')+'' ''+COALESCE(E.SegundoNombre,'''')),1,49 ) AS NOMBRECOMPLETO
   ,ISNULL(E.IDLocalidadNacimiento,0) as IDLocalidadNacimiento
   ,UPPER(ISNULL(ISNULL(LOCALIDAD.Descripcion,E.LocalidadNacimiento),'''')) AS LocalidadNacimiento
   ,ISNULL(E.IDMunicipioNacimiento,0) as IDMunicipioNacimiento
   ,UPPER(ISNULL(ISNULL(MUNICIPIO.Descripcion,E.MunicipioNacimiento),'''')) AS MunicipioNacimiento
   ,ISNULL(E.IDEstadoNacimiento,0) as IDEstadoNacimiento
   ,UPPER(ISNULL(ISNULL(ESTADOS.NombreEstado,E.EstadoNacimiento),'''')) AS EstadoNacimiento
   ,ISNULL(E.IDPaisNacimiento,0) as IDPaisNacimiento
   ,UPPER(ISNULL(ISNULL(PAISES.Descripcion,E.PaisNacimiento),'''')) AS PaisNacimiento
   ,isnull(E.FechaNacimiento,''1900-01-01'') as FechaNacimiento
   ,ISNULL(E.IDEstadoCiviL,0) AS IDEstadoCivil
   ,JSON_VALUE(CIVILES.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')) as EstadoCivil
   ,JSON_VALUE(SEXOS.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')) as Sexo
   ,isnull(E.IDEscolaridad,0) as IDEscolaridad
   ,UPPER(isnull(ESTUDIOS.Descripcion,'''')) as Escolaridad
   ,UPPER(E.DescripcionEscolaridad) AS DescripcionEscolaridad
   ,ISNULL(E.IDInstitucion,0) as IDInstitucion
   ,UPPER(isnull(I.Descripcion,'''')) as Institucion
   ,ISNULL(E.IDProbatorio,0) as IDProbatorio
   ,UPPER(isnull(Probatorio.Descripcion,'''')) as Probatorio
   ,isnull(E.FechaPrimerIngreso,''1900-01-01'') as FechaPrimerIngreso
   ,isnull(E.FechaIngreso,''1900-01-01'') as FechaIngreso
   ,isnull(''1900-01-01'',''1900-01-01'') as FechaAntiguedad
   ,isnull(E.Sindicalizado,0) as Sindicalizado
   ,ISNULL(E.IDJornadaLaboral,0)AS IDJornadaLaboral
   ,UPPER(ISNULL(JORNADA.Descripcion,'''')) AS JornadaLaboral
   ,UPPER(E.UMF) AS UMF
   ,UPPER(E.CuentaContable) AS CuentaContable
   ,isnull(E.IDTipoRegimen,0) AS IDTipoRegimen
   ,UPPER(ISNULL(TR.Descripcion,'''')) AS TipoRegimen
   ,ISNULL(E.IDPreferencia,0) AS IDPreferencia
   ,isnull(D.IDDepartamento,0) as  IDDepartamento
   ,UPPER(isnull(D.Descripcion,''SIN DEPARTAMENTO'')) as Departamento
   ,isnull(S.IDSucursal,0) as  IDSucursal
   ,UPPER(isnull(S.Descripcion,''SIN SUCURSAL'')) as Sucursal
   ,isnull(P.IDPuesto,0) as  IDPuesto
   ,UPPER(isnull(JSON_VALUE(P.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')),''SIN PUESTOS'')) as Puesto             
   ,isnull(C.IDCliente,0) as  IDCliente
   ,UPPER(isnull(JSON_VALUE(C.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''NombreComercial'')),''SIN CLIENTE'')) as Cliente
   ,isnull(EMP.IdEmpresa,0) as  IDEmpresa
   ,substring(UPPER(isnull(EMP.NombreComercial,''SIN EMPRESA'')),1,49) as Empresa
'
set @QuerySelect2 = '
   ,isnull(CC.IDCentroCosto,0) as  IDCentroCosto
   ,UPPER(isnull(CC.Descripcion,''SIN CENTRO DE COSTO'')) as CentroCosto
   ,isnull(A.IDArea,0) as  IDArea
   ,UPPER(isnull(A.Descripcion,''SIN ÁREA'')) as Area
   ,isnull(DV.IDDivision,0) as  IDDivision
   ,UPPER(isnull(DV.Descripcion,''SIN DIVISIÓN'')) as Division
   ,isnull(R.IDRegion,0) as  IDRegion
   ,UPPER(isnull(R.Descripcion,''SIN REGIÓN'')) as Region
   ,isnull(CP.IDClasificacionCorporativa,0) as  IDClasificacionCorporativa
   ,UPPER(isnull(CP.Descripcion,''SIN CLASIFICACIÓN CORPORATIVA'')) as ClasificacionCorporativa
   ,isnull(RP.IDRegPatronal,0) as  IDRegPatronal
   ,UPPER(isnull(RP.RazonSocial,''SIN REG. PATRONAL'')) as RegPatronal
   ,isnull(TipoNomina.IDTipoNomina,0) as  IDTipoNomina       
   ,UPPER(isnull(TipoNomina.Descripcion,''SIN TIPO DE NÓMINA'')) as TipoNomina
   ,ISNULL(0.00,0.00) as SalarioDiario
   ,ISNULL(0.00,0.00) as SalarioDiarioReal
   ,ISNULL(0.00,0.00)as SalarioIntegrado
   ,ISNULL(0.00,0.00)as SalarioVariable
   ,ISNULL(Prestaciones.IDTipoPrestacion,0) as IDTipoPrestacion
   ,isnull(RazonSocial.IDRazonSocial,0) as  IDRazonSocial
   ,UPPER(isnull(RazonSocial.RazonSocial,''SIN RAZÓN SOCIAL'')) as RazonSocial
   ,isnull(afore.IDAfore,0) as  IDAfore
   ,UPPER(isnull(afore.Descripcion,''SIN AFORE'')) as Afore
   ,cast(0 as bit) as Vigente       
   ,0 as RowNumber          
   ,NULL as [ClaveNombreCompleto]            
   ,Isnull(E.PermiteChecar,0) as  PermiteChecar             
   ,Isnull(E.RequiereChecar,0) as  RequiereChecar             
   ,Isnull(E.PagarTiempoExtra,0) as  PagarTiempoExtra             
   ,Isnull(E.PagarPrimaDominical,0) as  PagarPrimaDominical             
   ,Isnull(E.PagarDescansoLaborado,0) as  PagarDescansoLaborado             
   ,Isnull(E.PagarFestivoLaborado,0) as  PagarFestivoLaborado          
   ,Isnull(0,0) as IDDocumento             
   ,UPPER(Isnull('''','''')) as Documento             
   ,Isnull(0,0) as IDTipoContrato             
   ,UPPER(Isnull('''','''')) as TipoContrato            
   ,isnull(''1900-01-01'',''1900-01-01'') as FechaIniContrato          
   ,isnull(''1900-01-01'',''1900-01-01'') as FechaFinContrato 
   ,isnull(CatPrestaciones.Descripcion,''SIN PRESTACION'') as TiposPrestacion
   ,isnull(catTipoTrabajador.Descripcion,''SIN TIPO DE TRABAJADOR'') as tipoTrabajadorEmpleado
   '

 SET @QueryFrom =' 
  FROM [RH].[tblEmpleados] E WITH(NOLOCK)   
  JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on dfe.IDEmpleado = E.IDEmpleado and dfe.IDUsuario = '+Cast(@IDUsuario as Varchar(100))+'   
  LEFT JOIN SAT.tblCatTiposRegimen TR WITH(NOLOCK) on E.IDTipoRegimen = TR.IDTipoRegimen
  LEFT JOIN SAT.tblCatLocalidades LOCALIDAD WITH(NOLOCK) ON E.IDLocalidadNacimiento = LOCALIDAD.IDLocalidad
  LEFT JOIN SAT.tblCatMunicipios MUNICIPIO WITH(NOLOCK)ON E.IDMunicipioNacimiento = MUNICIPIO.IDMunicipio
  LEFT JOIN SAT.tblCatEstados ESTADOS WITH(NOLOCK)ON E.IDEstadoNacimiento = ESTADOS.IDEstado
  LEFT JOIN SAT.tblCatPaises PAISES WITH(NOLOCK) ON E.IDPaisNacimiento = PAISES.IDPais
  LEFT JOIN RH.tblCatEstadosCiviles CIVILES WITH(NOLOCK) ON E.IDEstadoCivil = CIVILES.IDEstadoCivil
  LEFT JOIN RH.tblCatGeneros SEXOS WITH(NOLOCK) ON E.Sexo = SEXOS.IDGenero
  LEFT JOIN STPS.tblCatEstudios ESTUDIOS WITH(NOLOCK) ON E.IDEscolaridad = ESTUDIOS.IDEstudio
  LEFT JOIN STPS.tblCatInstituciones I WITH(NOLOCK) on I.IDInstitucion = E.IDInstitucion
  LEFT JOIN STPS.tblCatProbatorios Probatorio WITH(NOLOCK) on Probatorio.IDProbatorio = e.IDProbatorio
  LEFT JOIN SAT.tblCatTiposJornada JORNADA WITH(NOLOCK) ON E.IDJornadaLaboral = JORNADA.IDTipoJornada
  LEFT JOIN [RH].[tblCatAfores] afore  with (nolock) ON afore.IDAfore = e.IDAfore
  LEFT JOIN [RH].[tblDepartamentoEmpleado] DE WITH(NOLOCK) ON E.IDEmpleado = DE.IDEmpleado AND DE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and dE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatDepartamentos] D WITH(NOLOCK) ON D.IDDepartamento = DE.IDDepartamento
  LEFT JOIN [RH].[tblSucursalEmpleado] SE WITH(NOLOCK)ON SE.IDEmpleado = E.IDEmpleado AND SE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and SE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatSucursales] S WITH(NOLOCK) ON SE.IDSucursal = S.IDSucursal
  LEFT JOIN [RH].[tblPuestoEmpleado] PE WITH(NOLOCK) ON PE.IDEmpleado = E.IDEmpleado AND PE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and PE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatPuestos] P WITH(NOLOCK) ON P.IDPuesto = PE.IDPuesto
  LEFT JOIN [RH].[tblClienteEmpleado] CE WITH(NOLOCK) ON CE.IDEmpleado = E.IDEmpleado AND CE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and CE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatClientes] C WITH(NOLOCK) ON C.IDCliente = CE.IDCliente '

Select @QueryFrom2 = '      
  LEFT JOIN [RH].[tblEmpresaEmpleado] EMPE WITH(NOLOCK) ON EMPE.IDEmpleado = E.IDEmpleado AND EMPE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and EMPE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''             
  LEFT JOIN [RH].[tblEmpresa] EMP WITH(NOLOCK) ON EMP.IdEmpresa = EMPE.IDEmpresa
  LEFT JOIN [RH].[tblCentroCostoEmpleado] CCE WITH(NOLOCK) ON CCE.IDEmpleado = E.IDEmpleado AND CCE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and CCE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatCentroCosto] CC WITH(NOLOCK) ON CC.IDCentroCosto = CCE.IDCentroCosto
  LEFT JOIN [RH].[tblAreaEmpleado] AE WITH(NOLOCK) ON AE.IDEmpleado = E.IDEmpleado AND AE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and AE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''         
  LEFT JOIN [RH].[tblCatArea] A WITH(NOLOCK) ON A.IDArea = AE.IDArea
  LEFT JOIN [RH].[tblDivisionEmpleado] DVE WITH(NOLOCK) ON DVE.IDEmpleado = E.IDEmpleado AND DVE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and DVE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatDivisiones] DV WITH(NOLOCK) ON DV.IDDivision = DVE.IDDivision
  LEFT JOIN [RH].[tblRegionEmpleado] RE WITH(NOLOCK) ON RE.IDEmpleado = E.IDEmpleado AND RE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and RE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatRegiones] R WITH(NOLOCK) ON R.IDRegion = RE.IDRegion
  LEFT JOIN [RH].[tblClasificacionCorporativaEmpleado] CPE WITH(NOLOCK) ON CPE.IDEmpleado = E.IDEmpleado AND CPE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and CPE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''            
  LEFT JOIN [RH].[tblCatClasificacionesCorporativas] CP WITH(NOLOCK) ON CP.IDClasificacionCorporativa = CPE.IDClasificacionCorporativa
  LEFT JOIN [RH].[tblRegPatronalEmpleado] RPE WITH(NOLOCK) ON RPE.IDEmpleado = E.IDEmpleado AND RPE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and RPE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatRegPatronal] RP WITH(NOLOCK)ON RP.IDRegPatronal = RPE.IDRegPatronal 
  LEFT JOIN [RH].[tblTipoNominaEmpleado] TipoNominaEmpleado WITH(NOLOCK) on e.IDEmpleado = TipoNominaEmpleado.IDEmpleado and TipoNominaEmpleado.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and TipoNominaEmpleado.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''            
  LEFT JOIN [Nomina].[tblCatTipoNomina] TipoNomina WITH(NOLOCK) on TipoNomina.IDTipoNomina = TipoNominaEmpleado.IDTipoNomina
  LEFT JOIN [RH].[tblRazonSocialEmpleado] RazonSocialEmpleado WITH(NOLOCK) on e.IDEmpleado = RazonSocialEmpleado.IDEmpleado and RazonSocialEmpleado.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and RazonSocialEmpleado.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatRazonesSociales] RazonSocial WITH(NOLOCK)on RazonSocial.IDRazonSocial = RazonSocialEmpleado.IDRazonSocial            
  LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) ON Prestaciones.IDEmpleado = E.IDEmpleado AND Prestaciones.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and Prestaciones.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''           
  LEFT JOIN [RH].[tblCatTiposPrestaciones] CatPrestaciones WITH(NOLOCK) ON Prestaciones.IDTipoPrestacion = CatPrestaciones.IDTipoPrestacion
  LEFT JOIN [RH].[tblTipoTrabajadorEmpleado] tipoTrabajadorEmpleado WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDEmpleado = E.IDEmpleado
  LEFT JOIN [IMSS].[tblCatTipoTrabajador] catTipoTrabajador WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDTipoTrabajador = catTipoTrabajador.IDTipoTrabajador
 '
	 
SET @QueryWhere = N'            
  WHERE (E.ClaveEmpleado BETWEEN '''+@EmpleadoIni+''' AND '''+@EmpleadoFin+''' )  ' +             
   CASE WHEN @IDTipoNomina <> 0 THEN @Conjuncion + ' ((TipoNomina.IDTipoNomina ='+ CAST(@IDTipoNomina as varchar(20))+'))' ELSE '' END +            
  -- 'and ( (M.FechaAlta<='''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and (M.FechaBaja>='''+FORMAT(@FechaIni,'yyyy-MM-dd')+''' or M.FechaBaja is null)) or (M.FechaReingreso<='''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''))'+
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Empleados')						THEN @Conjuncion +' ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Empleados''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Departamentos')					THEN @Conjuncion +' ((D.IDDepartamento in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Departamentos''),'',''))))  ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Sucursales')						THEN @Conjuncion +' ((S.IDSucursal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Sucursales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Puestos')						THEN @Conjuncion +' ((P.IDPuesto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Puestos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Prestaciones')					THEN @Conjuncion +' ((Prestaciones.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Prestaciones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Clientes')						THEN @Conjuncion +' ((C.IDCliente in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Clientes''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TiposContratacion')				THEN @Conjuncion +' ((contratos.IDTipoContrato in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TiposContratacion''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RazonesSociales')				THEN @Conjuncion +' ((EMP.IdEmpresa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RazonesSociales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RegPatronales')					THEN @Conjuncion +' ((RP.IDRegPatronal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RegPatronales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Divisiones')						THEN @Conjuncion +' ((DV.IDDivision in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Divisiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos')					THEN @Conjuncion +' ((CC.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Areas')					        THEN @Conjuncion +' ((AE.IDArea in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Areas''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Regiones')					    THEN @Conjuncion +' ((RE.IDRegion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Regiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos')				    THEN @Conjuncion +' ((CC.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'ClasificacionesCorporativas')	THEN @Conjuncion +' ((CP.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''ClasificacionesCorporativas''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'NombreClaveFilter')				THEN @Conjuncion +' ((COALESCE(E.ClaveEmpleado,'''')+'' ''+ COALESCE(E.Paterno,'''')+'' ''+COALESCE(E.Materno,'''')+'', ''+COALESCE(E.Nombre,'''')+'' ''+COALESCE(E.SegundoNombre,'''')) like ''%''+(Select top 1 Value from #tempFiltros where Catalogo = ''NombreClaveFilter'')+''%'')' ELSE '' END 
   --+ ' order by e.ClaveEmpleado asc' 

	--insert into @dtEmpleados
	--insert into #dtEmpleados
	exec (@querySelect + @QuerySelect2 + @QueryFrom +@queryFrom2 + @QueryWhere)

	/*Vigencia Empleados*/	
		insert into @dtVigenciaEmpleados
		select mm.IDEmpleado
			,FechaAlta
			,FechaBaja
			,case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso
			,FechaReingresoAntiguedad            
			,mm.IDMovAfiliatorio    
			,mmSueldos.SalarioDiario
			,mmSueldos.SalarioVariable
			,mmSueldos.SalarioIntegrado
			,mmSueldos.SalarioDiarioReal
		from (select distinct tm.IDEmpleado,            
				case when(tm.IDEmpleado is not null) then (select top 1 Fecha             
							from [IMSS].[tblMovAfiliatorios] mAlta WITH(NOLOCK)            
						join [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
							where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'
							Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
				case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
							from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
						join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
							where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'
						and mBaja.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')             
				order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
				case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
							from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
						join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
							where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo in('R','A')
						and mReingreso.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')  
						--and isnull(mReingreso.RespetarAntiguedad,0) <> 1
						order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso
				,case when (tm.IDEmpleado is not null) then (select top 1 Fecha             
							from [IMSS].[tblMovAfiliatorios]  mReingresoAnt WITH(NOLOCK)            
						join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingresoAnt.IDTipoMovimiento=c.IDTipoMovimiento            
							where mReingresoAnt.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','R')
						and mReingresoAnt.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')  
						and isnull(mReingresoAnt.RespetarAntiguedad,0) <> 1
						order by mReingresoAnt.Fecha desc, C.Prioridad desc) end as FechaReingresoAntiguedad
				,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
						join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
							where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')      
							and mSalario.Fecha <= FORMAT(@Fechafin,'yyyy-MM-dd')          
							order by mSalario.Fecha desc ) as IDMovAfiliatorio   
			from [IMSS].[tblMovAfiliatorios] tm with (nolocK)
				inner join #dtEmpleados e on e.IDEmpleado = tm.IDEmpleado
			) mm   
				JOIN [IMSS].[tblMovAfiliatorios] mmSueldos with (nolocK) on mm.IDMovAfiliatorio = mmSueldos.IDMovAfiliatorio
		where ( mm.FechaAlta<=@FechaFin and (mm.FechaBaja>=@FechaIni or mm.FechaBaja is null)) or (mm.FechaReingreso<=@FechaFin)

		--UPDATE e
		--	set e.FechaAntiguedad = v.FechaReingresoAntiguedad
		--		,e.SalarioDiario = v.SalarioDiario
		--		,e.SalarioVariable = v.SalarioVariable
		--		,e.SalarioIntegrado = v.SalarioIntegrado
		--		,e.SalarioDiarioReal = v.SalarioDiarioReal
		-- FROM ##dtEmpleados e
		--	inner join @dtVigenciaEmpleados v
				--on e.IDEmpleado = v.IDEmpleado

		MERGE #dtEmpleados AS TARGET                  
			USING @dtVigenciaEmpleados AS SOURCE                  
				ON (TARGET.IDEmpleado = SOURCE.IDEmpleado)                  
			WHEN MATCHED Then                  
				update                  
					Set                       
					TARGET.FechaAntiguedad	= SOURCE.FechaReingresoAntiguedad  
					,TARGET.SalarioDiario				= SOURCE.SalarioDiario  
					,TARGET.SalarioVariable				= SOURCE.SalarioVariable  
					,TARGET.SalarioIntegrado			= SOURCE.SalarioIntegrado  
					,TARGET.SalarioDiarioReal			= SOURCE.SalarioDiarioReal  
                      
			WHEN NOT MATCHED BY SOURCE THEN             
			DELETE ;               

	/*Vigencia Empleados*/	
	/*Contratos*/
		insert into @dtContratosEmpleado
		select *
		from 
			(
			select  ContratoEmpleado.IDContratoEmpleado
					,ContratoEmpleado.IDEmpleado
					,Isnull(documentos.IDDocumento,0) as IDDocumento             
					,UPPER(Isnull(documentos.Descripcion,'')) as Documento             
					,Isnull(tipoContrato.IDTipoContrato,0) as IDTipoContrato             
					,UPPER(Isnull(tipoContrato.Descripcion,'')) as TipoContrato            
					,isnull(ContratoEmpleado.FechaIni,'1900-01-01') as FechaIniContrato          
					,isnull(ContratoEmpleado.FechaFin,'1900-01-01') as FechaFinContrato 
					,ROW_NUMBER()OVER(partition by ContratoEmpleado.IDEmpleado order by ContratoEmpleado.FechaIni desc) as RN
			from #dtEmpleados e 
				inner join [RH].[tblContratoEmpleado] ContratoEmpleado WITH(NOLOCK)
					on e.IDEmpleado = ContratoEmpleado.IDEmpleado
				inner JOIN [RH].[tblCatDocumentos] documentos WITH(NOLOCK)
					ON ContratoEmpleado.IDDocumento = documentos.IDDocumento          
						and documentos.EsContrato = 1
				inner JOIN [sat].[tblCatTiposContrato] tipoContrato WITH(NOLOCK)
					ON ContratoEmpleado.IDTipoContrato = tipoContrato.IDTipoContrato    
			WHERE 
					ContratoEmpleado.FechaIni<= FORMAT(@Fechafin,'yyyy-MM-dd') and ContratoEmpleado.FechaFin >= FORMAT(@Fechafin,'yyyy-MM-dd')       
			) c

		where c.RN = 1
		update e
			set 
				e.IDDocumento		= c.IDDocumento	
				,e.Documento		= c.Documento		
				,e.IDTipoContrato	= c.IDTipoContrato
				,e.TipoContrato		= c.TipoContrato	
				,e.FechaIniContrato	= c.FechaIniContrato    
				,e.FechaFinContrato	= c.FechaFinContrato

		from #dtEmpleados e
			inner join @dtContratosEmpleado c
				on e.IDEmpleado = c.IDEmpleado
	/*Contratos*/

	select e.* 
	from #dtEmpleados e


END
GO
