USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: <Autor,varchar,Nombre>
** Email			: <Email,varchar,@adagio.com.mx>
** FechaCreacion	: <FechaCreacion,Date,Fecha>
** Paremetros		:              

	Si se modifica este result set es necesario modificar
		-RH.spIniciarProcesoAutorizacionPosicionesPorPlaza

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2022-30-12			Alejandro Paredes	Se agrego la columna ParentCodigo
***************************************************************************************************/
--[RH].[spBuscarPosiciones]  @IDEmpleado = 390
CREATE proc [RH].[spBuscarPosiciones](
	@IDPosicion int = 0
	,@IDPlaza	int = 0
	,@IDCliente	int = 0
	,@IDEmpleado int = 0
	,@ParentId	int = 0
	,@IDUsuario	int = 0
	,@StringFiltroEstatus varchar(100) =''
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
) as
	SET FMTONLY OFF;  
	
	declare
		@IDTipoCatalogoEstatusPosiciones int = 5
		,@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		,@IDTipoCatalogoEstatusPlazas int = 4
		,@IDIdioma varchar(20)
	;

	IF OBJECT_ID('tempdb..#TempPosiciones') IS NOT NULL DROP TABLE #TempPosiciones

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	declare @tempPosiciones as table (
		IDPosicion int,
		IDPlaza int,
		CodigoPlaza App.SMName,
        IDPuesto int,
        NombrePlaza VARCHAR(100),
		IDCliente int,
		Cliente App.XLName,
		Codigo App.SMName,
		IDEmpleado		int,
		ParentId		int,
		ParentCodigo	varchar(25),
		Temporal		bit,
        DisponibleDesde date,
        DisponibleHasta date,
		UUID			Varchar(max)
	)

	declare @tempEstatusPosiciones as table (
		IDEstatusPosicion int,
		IDPosicion int,
		IDEstatus int,
		Estatus varchar(255),
		DisponibleDesde date,
		DisponibleHasta date,
		IDUsuarioReclutador int,
		IDUsuario int,
		FechaReg datetime,
        ConfiguracionStatus nvarchar(max),
		[ROW] int
	)

	insert @tempPosiciones
	select 
		p.IDPosicion
		,p.IDPlaza
		,plazas.Codigo as CodigoPlaza
		,plazas.IDPuesto
        ,JSON_VALUE(pp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,p.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,p.Codigo
		,p.IDEmpleado
		,p.ParentId
		,ISNULL(p2.Codigo, '0') as ParentCodigo
		,isnull(p.Temporal, 0) Temporal
        ,p.DisponibleDesde
        ,p.DisponibleHasta
		,p.UUID
	from [RH].[tblCatPosiciones] p with (nolock)
		join [RH].[tblCatPlazas] plazas with (nolock) on plazas.IDPlaza = p.IDPlaza
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
        join  RH.tblCatPuestos pp on pp.IDPuesto=plazas.IDPuesto
		left join [RH].[tblCatPosiciones] p2 with(nolock) on p.ParentId = p2.IDPosicion
	where	(p.IDPosicion	= @IDPosicion	or isnull(@IDPosicion, 0)	= 0)
		and (p.IDPlaza		= @IDPlaza		or isnull(@IDPlaza, 0)		= 0)
		and (p.IDCliente	= @IDCliente	or isnull(@IDCliente, 0)	= 0)
		and (p.IDEmpleado	= @IDEmpleado	or isnull(@IDEmpleado, 0)	= 0)
		and (p.ParentId		= @ParentId		or isnull(@ParentId, 0)		= 0)
		and (@query = '""' or contains(pp.*, @query)) 

		--select * from @tempPosiciones

	insert @tempEstatusPosiciones
	select 
		isnull(estatusPosiciones.IDEstatusPosicion,0) AS IDEstatusPosicion
		,posiciones.IDPosicion
		,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
		,isnull(estatusPosiciones.DisponibleDesde, '1990-01-01') as DisponibleDesde
		,isnull(estatusPosiciones.DisponibleHasta, '1990-01-01') as DisponibleHasta
		,isnull(estatusPosiciones.IDUsuarioReclutador,0) as IDUsuarioReclutador
		,isnull(estatusPosiciones.IDUsuario,0) as IDUsuario
		,isnull(estatusPosiciones.FechaReg,'1990-01-01') FechaReg
        ,isnull(estatus.configuracion,'') as ConfiguracionStatus
		,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
	from @tempPosiciones posiciones
		left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
		left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones

	select 
		p.IDPosicion
		,p.IDPlaza
		,p.CodigoPlaza
        ,p.IDPuesto
		,p.NombrePlaza as Plaza
		,p.IDCliente
		,p.Cliente
		,p.Codigo
		,p.ParentId
		,p.ParentCodigo
		,ISNULL(p.Temporal, 0) Temporal
        ,p.DisponibleDesde
        ,p.DisponibleHasta
		,p.UUID
		,ISNULL(p.IDEmpleado, 0) IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
		,estatus.IDEstatusPosicion 
		,estatus.IDEstatus
		,estatus.Estatus
		,estatus.IDUsuario 
        ,estatus.ConfiguracionStatus
		,estatus.FechaReg as FechaRegEstatus
        ,SUBSTRING (e.Nombre, 1, 1) + SUBSTRING (e.Paterno, 1, 1) as Iniciales
	into #TempPosiciones
	from @tempPosiciones p
		left join RH.tblEmpleadosMaster e on e.IDEmpleado = p.IDEmpleado
		left join @tempEstatusPosiciones estatus on estatus.IDPosicion = p.IDPosicion and estatus.[ROW] = 1
		left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = e.IDEmpleado  
    where @StringFiltroEstatus='' or estatus.IDEstatus  in ( Select item from App.Split(@StringFiltroEstatus,',')) 
		and ((p.IDEmpleado	= @IDEmpleado)	or (isnull(@IDEmpleado, 0)	= 0))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempPosiciones

	select @TotalRegistros = cast(COUNT([IDPosicion]) as decimal(18,2)) from #TempPosiciones		
	
	select
		*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end        
        ,cast(@TotalRegistros  as int) as TotalRows
	from #TempPosiciones s
	--order by Codigo asc
    order by  
            case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end ,
            case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'		then Codigo end desc,
            case when @orderByColumn = 'Plaza'			and @orderDirection = 'asc'		then s.Plaza end ,
            case when @orderByColumn = 'Plaza'			and @orderDirection = 'desc'		then s.Plaza end desc  ,                                                                  
            case when @orderByColumn = 'CodigoPlaza'			and @orderDirection = 'asc'		then s.CodigoPlaza end ,
            case when @orderByColumn = 'CodigoPlaza'			and @orderDirection = 'desc'		then s.CodigoPlaza end desc,
            case when @orderByColumn = 'Cliente'			and @orderDirection = 'asc'		then Cliente end ,
            case when @orderByColumn = 'Cliente'			and @orderDirection = 'desc'		then Cliente end desc,
            case when @orderByColumn = 'Temporal'			and @orderDirection = 'asc'		then Temporal end ,
            case when @orderByColumn = 'Temporal'			and @orderDirection = 'desc'		then Temporal end desc,
            case when @orderByColumn = 'DisponibleDesde'			and @orderDirection = 'asc'		then DisponibleDesde end ,
            case when @orderByColumn = 'DisponibleDesde'			and @orderDirection = 'desc'		then DisponibleDesde end desc ,                                                                
            case when @orderByColumn = 'DisponibleHasta'			and @orderDirection = 'asc'		then DisponibleHasta end ,
            case when @orderByColumn = 'DisponibleHasta'			and @orderDirection = 'desc'		then DisponibleHasta end desc ,                                                                
            case when @orderByColumn = 'Empleado.ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end ,
            case when @orderByColumn = 'Empleado.ClaveEmpleado'			and @orderDirection = 'desc'		then ClaveEmpleado end desc ,                                                                
            case when @orderByColumn = 'Empleado.NombreCompleto'			and @orderDirection = 'asc'		then s.Colaborador end ,
            case when @orderByColumn = 'Empleado.NombreCompleto'			and @orderDirection = 'desc'		then Colaborador end desc ,                                                                
            
            case when @orderByColumn = 'Estatus.Estatus'			and @orderDirection = 'asc'		then Estatus end ,
            case when @orderByColumn = 'Estatus.Estatus'			and @orderDirection = 'desc'		then Estatus end desc                                                                 

            

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
