USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBorrarArticulos](
	@IDArticulo int
)
as
begin
	declare @ID_CAT_ESTATUS_ARTICULO_ASIGNADO int = 2, @IDDetallesArticulos int;
	set @IDDetallesArticulos = (select count(IDDetalleArticulo) from ControlEquipos.tblDetalleArticulos where IDArticulo = @IDArticulo)
	--select @IDDetallesArticulos as numero
	--return

	if exists(select top 1 1 from [ControlEquipos].[tblArticulos] where IDArticulo = @IDArticulo)
	begin
	if @IDDetallesArticulos > 0 
		begin
			declare @error varchar(200) = 'Existen ' + cast(@IDDetallesArticulos as varchar(10)) + ' detalle(s) de artículo(s) relacionado(s) a este artículo, por lo tanto no puedes borrar este artículo hasta que borres todos los detalles relacionados a este artículo.'
			raiserror(@error,16,1)
			return
		end
	delete from [ControlEquipos].[tblArticulos] where IDArticulo = @IDArticulo
	end
end


/**
exec [ControlEquipos].[spBorrarArticulos]@IDArticulo= 1


*/
GO
