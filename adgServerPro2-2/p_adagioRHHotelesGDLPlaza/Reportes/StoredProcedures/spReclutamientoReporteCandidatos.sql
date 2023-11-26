USE [p_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spReclutamientoReporteCandidatos] (
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

	Declare 
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
			,@IDTipoContactoEmail int

		select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
			from @dtFiltros where Catalogo = 'FechaIni'
		select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
			from @dtFiltros where Catalogo = 'FechaFin'


		select 
		 concat(Candidato.Nombre,' ',Candidato.SegundoNombre) AS [NOMBRE(S)]
		,Candidato.Paterno AS [APELLIDO PATERNO]
		,Candidato.Materno AS [APELLIDO MATERNO]
		,Candidato.Sexo AS [SEXO]
		,FORMAT(Candidato.FechaNacimiento ,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
		,Candidato.RFC AS [RFC  ]
		,Candidato.CURP AS [CURP]
		,Candidato.NSS AS [NSS  ]
		,Candidato.AFORE AS [AFORE]
		,PaisNacimiento.Descripcion AS [PAIS DE NACIMIENTO]
		,EstadoNacimiento.NombreEstado AS [ESTADO DE NACIMIENTO]
		,MunicipioNacimiento.Descripcion AS [MUNICIPIO DE NACIMIENTO]
		,LocalidadNacimiento.Descripcion AS [LOCALIDAD DE NACIMIENTO]
		,EstadoCivil.Descripcion AS [ESTADO CIVIL]
		,Candidato.Estatura AS [ESTATURA]
		,Candidato.Peso AS [PESO]
		,Candidato.TipoSangre AS [TIPO DE SANGRE]
		,EstatusProceso.Descripcion AS [ESTATUS PROCESO]
		,ISNULL(Email.Value, '') AS [EMAIL]
		,ISNULL(Celular.Value, '')  AS [CELULAR]
		,ISNULL(TelFijo.Value, '') AS [TELEFONO FIJO]
		,ISNULL(DireccionCandidato.CodigoPostal, '')  AS [CODIGO POSTAL DE RESIDENCIA]
		,ISNULL(DireccionCandidato.Calle, '') AS [CALLE DE RESIDENCIA]
		,ISNULL(DireccionCandidato.NumExt, '') AS [NUMERO EXT DE RESIDENCIA]
		,ISNULL(DireccionCandidato.NumInt, '') AS [NUMERO INT DE RESIDENCIA]
		,ISNULL(PaisDireccion.Descripcion, '') AS [PAIS DE RESIDENCIA]
		,ISNULL(EstadoDireccion.NombreEstado, '') AS [ESTADO DE RESIDENCIA]
		,ISNULL(MunicipioDireccion.Descripcion, '') AS [MUNICIPIO DE RESIDENCIA]
		,ISNULL(LocalidadDireccion.Descripcion, '') AS [LOCALIDAD DE RESIDENCIA]


		from 
		[Reclutamiento].[tblCandidatos] Candidato
		inner join [Sat].[tblCatPaises] PaisNacimiento on Candidato.IDPaisNacimiento = PaisNacimiento.IDPais
		inner join [Sat].[tblCatEstados] EstadoNacimiento on Candidato.IDEstadoNacimiento = EstadoNacimiento.IDEstado
		inner join [Sat].[tblCatMunicipios] MunicipioNacimiento on Candidato.IDMunicipioNacimiento = MunicipioNacimiento.IDMunicipio
		inner join [Sat].[tblCatLocalidades] LocalidadNacimiento on Candidato.IDLocalidadNacimiento = LocalidadNacimiento.IDLocalidad

		inner join [RH].[tblCatEstadosCiviles] EstadoCivil on Candidato.IDEstadoCivil = EstadoCivil.IDEstadoCivil
		inner join [Reclutamiento].[tblCatEstatusProceso] EstatusProceso on Candidato.IDEstadoNacimiento = EstatusProceso.IDEstatusProceso

		left join [Reclutamiento].[tblContactoCandidato] Celular on Candidato.IDCandidato = Celular.IDCandidato and Celular.IDTipoContacto = 1
		left join [Reclutamiento].[tblContactoCandidato] TelFijo on  Candidato.IDCandidato = TelFijo.IDCandidato and TelFijo.IDTipoContacto = 2
		left join [Reclutamiento].[tblContactoCandidato] Email on  Candidato.IDCandidato = Email.IDCandidato and Email.IDTipoContacto = 3

		left join [Reclutamiento].[tblDireccionCandidato] DireccionCandidato on Candidato.IDCandidato = DireccionCandidato.IDCandidato
		left join [Sat].[tblCatPaises] PaisDireccion on DireccionCandidato.IDPais = PaisDireccion.IDPais
		left join [Sat].[tblCatEstados] EstadoDireccion on DireccionCandidato.IDEstado = EstadoDireccion.IDEstado
		left join [Sat].[tblCatMunicipios] MunicipioDireccion on DireccionCandidato.IDMunicipio = MunicipioDireccion.IDMunicipio
		left join [Sat].[tblCatLocalidades] LocalidadDireccion on DireccionCandidato.IDColonia = LocalidadDireccion.IDLocalidad




	END
GO
