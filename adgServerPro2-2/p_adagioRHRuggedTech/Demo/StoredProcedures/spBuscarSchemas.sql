USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Demo.spBuscarSchemas as

	select distinct [Schema]
	from Demo.tblInfo
	order by [Schema]
GO
