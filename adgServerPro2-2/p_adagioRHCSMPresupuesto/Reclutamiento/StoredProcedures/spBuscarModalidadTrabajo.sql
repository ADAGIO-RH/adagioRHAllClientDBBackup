USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Reclutamiento].[spBuscarModalidadTrabajo]  
  
	AS
BEGIN  
 

   select     
   IDModalidadTrabajo,
	Descripcion         
   from [Reclutamiento].[tblCatModalidadTrabajo]
 
END
GO
