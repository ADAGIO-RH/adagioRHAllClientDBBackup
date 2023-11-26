USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp obtiene la información de los empleados de la plaza, obteniendo una comparacion 
                        de sus configuraciones.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com
** FechaCreacion	: 2023-01-08
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarPlazaDetalleEmpleados]
    @IDPlaza int,
    @IDUsuario int,
    @BanderaTotal bit
AS
BEGIN
    DECLARE @json varchar(max),
    @QuerySelect varchar(max)

    declare @dtConfiguraciones as table(
        NombreConfiguracion varchar(255),
        Valor VARCHAR(255),
        Descripcion VARCHAR(255),
        NameKey VARCHAR(100),
        RowNumber int
    )

    declare @dtEmpleados as table(
        IDEmpleado int ,
        ClaveEmpleado varchar(100),
        NombreCompleto varchar(100),
        IDDepartamento int,        
        IDSucursal INT,
        IDTipoPrestacion int ,
        IDRegPatronal int ,
        IDEmpresa int ,
        IDCentroCosto int ,
        IDArea int ,
        IDDivision int,
        IDRegion int ,
        IDClasificacionCorporativa int,
        Departamento varchar(200),        
        Sucursal varchar(200),
        TipoPrestacion varchar(200) ,
        RegPatronal varchar(200) ,
        Empresa varchar(200) ,
        CentroCosto varchar(200) ,
        Area varchar(200) ,
        Division varchar(200),
        Region varchar(200) ,
        ClasificacionCorporativa varchar(200)          
    )

    SELECT @json=Configuraciones
    from rh.tblCatPlazas
    where IDPlaza=@IDPlaza

    insert into @dtConfiguraciones
        (NombreConfiguracion,Valor,Descripcion,NameKey,RowNumber)
    select
        ctcp.Nombre as TipoConfiguracionPlaza		                
        , t.Valor      				 
            , ff.descripcion               
            , JSON_VALUE(Configuracion,'$.fieldValue')
            , ROW_NUMBER()over(order by Orden)
    from [RH].[tblCatTiposConfiguracionesPlazas] ctcp with (nolock)
        left join (
            SELECT IDTipoConfiguracionPlaza, Valor
        FROM OPENJSON(@json )
                WITH (   
                    IDTipoConfiguracionPlaza   varchar(200) '$.IDTipoConfiguracionPlaza' ,                
                    Valor int          '$.Valor' 
                )                     
        ) as t on t.IDTipoConfiguracionPlaza = ctcp.IDTipoConfiguracionPlaza    
    outer APPLY 
        [RH].[fnGetValueMemberFromTable](ctcp.TableName,t.Valor)  as ff
    where 
        ctcp.Disponible=1 and ctcp.IDTipoConfiguracionPlaza<>'PosicionJefe'
    order by ctcp.Orden


    insert into @dtEmpleados
        (IDEmpleado,ClaveEmpleado,NombreCompleto,[IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa],
            [Departamento], [Sucursal], [TipoPrestacion], [RegPatronal], [Empresa], [CentroCosto], [Area], [Division], [Region], [ClasificacionCorporativa])
    select m.IDEmpleado,ClaveEmpleado, NOMBRECOMPLETO, IDDepartamento, IDSucursal, IDTipoPrestacion, IDRegPatronal, IDEmpresa, IDCentroCosto, IDArea, IDDivision, IDRegion, IDClasificacionCorporativa,
            Departamento, Sucursal, m.TiposPrestacion, RegPatronal, Empresa, CentroCosto, Area, Division, Region, ClasificacionCorporativa
    From rh.tblCatPosiciones cp
        inner join rh.tblEmpleadosMaster m on cp.IDEmpleado = m.IDEmpleado
    where IDPlaza=@IDPlaza


    insert into @dtEmpleados
        (ClaveEmpleado,[IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa])
    SELECT 'Plaza' AS ClaveEmpleado,
        [IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa]
    FROM
        (SELECT Valor, NameKey
        FROM @dtConfiguraciones) AS SourceTable
    PIVOT
    (
        max(Valor)
        FOR NameKey IN ([IDDepartamento], [IDSucursal], [IDTipoPrestacion], [IDRegPatronal], [IDEmpresa], [IDCentroCosto], [IDArea], [IDDivision], [IDRegion], [IDClasificacionCorporativa])
    ) AS PivotTable

    if  @BanderaTotal =0  
    BEGIN

        SELECT de.IDEmpleado,de.ClaveEmpleado,
            de.NombreCompleto,
            IIF(de.IDDepartamento=dd.IDDepartamento,1,0) as [1], --[Departamento],
            IIF(de.IDSucursal=dd.IDSucursal,1,0) as [2], --[Sucursal],
            IIF(de.IDTipoPrestacion=dd.IDTipoPrestacion,1,0) [3] , --as [Prestaciones],
            IIF(de.IDRegPatronal=dd.IDRegPatronal,1,0) as [4], --[Registro Patronal],
            IIF(de.IDEmpresa=dd.IDEmpresa,1,0) as [5], --[Empresa],
            IIF(de.IDCentroCosto=dd.IDCentroCosto,1,0) as [6], --[Centro de Costo],
            IIF(de.IDArea=dd.IDArea,1,0) as [7], --[Area],
            IIF(de.IDDivision=dd.IDDivision,1,0) as [8], --[Division],
            IIF(de.IDRegion=dd.IDRegion,1,0) [9] , --as [Región],
            IIF(de.IDClasificacionCorporativa=dd.IDClasificacionCorporativa,1,0) [10],--as [Clasificación Corporativa]

            de.Departamento as [d1], --[Departamento],
            de.Sucursal as [d2], --[Sucursal],
            de.TipoPrestacion [d3] , --as [Prestaciones],
            de.RegPatronal as [d4], --[Registro Patronal],
            de.Empresa as [d5], --[Empresa],
            de.CentroCosto as [d6], --[Centro de Costo],
            de.Area as [d7], --[Area],
            de.Division as [d8], --[Division],
            de.Region [d9] , --as [Región],
            de.ClasificacionCorporativa [d10]--as [Clasificación Corporativa]
        FROM @dtEmpleados de
            inner join @dtEmpleados dd on dd.ClaveEmpleado='Plaza'                        
        where de.ClaveEmpleado!='Plaza'

    end
    else 
    begin
        select 
            RowNumber,
            NombreConfiguracion,
            isnull(conf.Descripcion,'- No asignado -') as Descripcion,
            isnull(valueConfig,0) as [Total]
            
        From @dtConfiguraciones  conf
            left join (     
                    select
                indexConfig,
                valueConfig
            from ( SELECT
                    sum(IIF(de.IDDepartamento=dd.IDDepartamento,1,0)) as [1], --[Departamento],
                    sum(IIF(de.IDSucursal=dd.IDSucursal,1,0)) as [2], --[Sucursal],
                    sum(IIF(de.IDTipoPrestacion=dd.IDTipoPrestacion,1,0)) [3] , --as [Prestaciones],
                    sum(IIF(de.IDRegPatronal=dd.IDRegPatronal,1,0)) as [4], --[Registro Patronal],
                    sum(IIF(de.IDEmpresa=dd.IDEmpresa,1,0)) as [5], --[Empresa],
                    sum(IIF(de.IDCentroCosto=dd.IDCentroCosto,1,0)) as [6], --[Centro de Costo],
                    sum(IIF(de.IDArea=dd.IDArea,1,0)) as [7], --[Area],
                    sum(IIF(de.IDDivision=dd.IDDivision,1,0)) as [8], --[Division],
                    sum(IIF(de.IDRegion=dd.IDRegion,1,0)) [9] , --as [Región],
                    sum(IIF(de.IDClasificacionCorporativa=dd.IDClasificacionCorporativa,1,0)) [10]--as [Clasificación Corporativa]
                FROM @dtEmpleados de
                    inner join @dtEmpleados dd on dd.ClaveEmpleado='Plaza'
                where de.ClaveEmpleado!='Plaza'
        ) as tabla
            unpivot
        (
            valueConfig
            for indexConfig in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10])
        ) unpiv) tblTotal on tblTotal.indexConfig=conf.RowNumber;
    end

END
GO
