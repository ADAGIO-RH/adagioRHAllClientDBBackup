USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create    view [Dashboard].[vwClimaLaboralProyectos] as
	select *
	from Evaluacion360.tblCatProyectos
	where IDProyecto <> 18
GO
