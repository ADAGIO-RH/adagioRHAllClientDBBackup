USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteArticulosVendidos](
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int 
) as
	declare 
		@FechaIni date,
		@FechaFin date

	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	
	select *
	from (
		select dpa.Nombre as ARTICULO
			,dpa.PrecioUnidad as [PRECIO UNIDAD]
			,cast((dpa.PrecioUnidad / 1.160) as decimal(18,2)) as [PRECIO UNIDAD SIN IVA]
			,count(dpa.IDArticulo) as [TOTAL UNIDADES]
			,sum(dpa.PrecioUnidad * dpa.Cantidad) as [PRECIO TOTAL]
			,cast(sum(dpa.PrecioUnidad * dpa.Cantidad) / 1.160 as decimal(18,2)) as [PRECIO TOTAL SIN IVA]
		from Comedor.tblPedidos p with (nolock)
			join Comedor.tblDetallePedidoArticulos dpa with (nolock) on dpa.IDPedido = p.IDPedido
		where p.FechaCreacion between @FechaIni and @FechaFin
			and isnull([p].Autorizado,0) = 1
			and isnull([p].Cancelada,0) = 0
		group by dpa.Nombre, dpa.PrecioUnidad
	) as info
	order by ltrim(ARTICULO)
GO
