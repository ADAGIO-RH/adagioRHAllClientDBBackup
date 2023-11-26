USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Imss].[spBuscarTipoRiesgoIncapacidad](
    @IDTipoRiesgoIncapacidad int = 0
) as
    select IDTipoRiesgoIncapacidad
	   ,Codigo
	   ,Nombre 
    from [Imss].[tblCatTipoRiesgoIncapacidad]
    where ((IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad) or (@IDTipoRiesgoIncapacidad = 0))
GO
