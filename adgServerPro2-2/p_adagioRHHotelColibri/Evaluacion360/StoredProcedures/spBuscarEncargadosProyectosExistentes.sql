USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [Evaluacion360].[spBuscarEncargadosProyectosExistentes] as

select distinct Nombre, Email
from Evaluacion360.tblEncargadosProyectos with (nolock)
GO
