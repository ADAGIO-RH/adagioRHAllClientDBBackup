USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spBuscarPedidosByID](@IDPedido  int = 0
										   ,@IDUsuario int
										   )
as
	 select 
			[P].[IDPedido]
		   ,[P].[Numero]
		   ,[P].[IDRestaurante]
		   ,[R].[Nombre] as                                           [Restaurante]
		   ,[P].[IDEmpleado]
		   ,[E].[ClaveEmpleado]
		   ,[E].[NOMBRECOMPLETO] as                                   [Colaborador]
		   ,isnull([P].[IDEmpleadoRecibe],0) as                       [IDEmpleadoRecibe]
		   ,[Emprecibe].[ClaveEmpleado] as                            [ClaveEmpleadoRecibe]
		   ,[Emprecibe].[NOMBRECOMPLETO] as                           [ColaboradorRecibe]
		   ,[P].[Autorizado]
		   ,isnull([P].[IDEmpleadoAutorizo],0) as                     [IDEmpleadoAutorizo]
		   ,isnull([P].[IDUsuarioAutorizo],0) as                      [IDUsuarioAutorizo]
		   ,isnull([P].[FechaHoraAutorizacion],'1990-01-01 00:00') as [FechaHoraAutorizacion]
		   ,[P].[ComandaImpresa]
		   ,isnull([P].[FechaHoraImpresion],'1990-01-01') as          [FechaHoraImpresion]
		   ,[P].[DescontadaDeNomina]
		   ,isnull([P].[FechaHoraDescuento],'1990-01-01') as          [FechaHoraDescuento]
		   ,isnull([P].[IDPeriodo],0) as                              [IDPeriodo]
		   ,[P].[Cancelada]
		   ,[P].[NotaCancelacion]
		   ,isnull([P].[FechaCancelacion],'1990-01-01 00:00') as      [FechaCancelacion]
		   ,[P].[FechaCreacion]
		   ,[P].[HoraCreacion]
	  from [Comedor].[tblPedidos] [P] with(nolock)
		   join [Comedor].[tblCatRestaurantes] [R] with(nolock) on [R].[IDRestaurante] = [P].[IDRestaurante]
		   join [RH].[tblEmpleadosMaster] [E] with(nolock) on [E].[IDEmpleado] = [P].[IDEmpleado]
		   left join [RH].[tblEmpleadosMaster] [empRecibe] with(nolock) on [empRecibe].[IDEmpleado] = [P].[IDEmpleadoRecibe]
	  where [P].[IDPedido] = isnull(@IDPedido,0);
GO
