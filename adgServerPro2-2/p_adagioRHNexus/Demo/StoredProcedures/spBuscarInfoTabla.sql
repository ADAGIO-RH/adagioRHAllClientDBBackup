USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc Demo.spBuscarInfoTabla(
	@Tabla varchar(255) 
) as
	declare @bkTable Table (
		Mensaje varchar(110)
	);


	declare @sql varchar(max) = 'select * from '+coalesce(@Tabla,'');

	execute(@sql)
GO
