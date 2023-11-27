USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Imss].[spBuscarTiposLesiones](
    @IDTipoLesion int = 0
) as
    select IDTipoLesion
	   ,Codigo
	   ,Descripcion
    from [Imss].[tblCatTiposLesiones]    
    where (IDTipoLesion = @IDTipoLesion) or (@IDTipoLesion = 0)
GO
