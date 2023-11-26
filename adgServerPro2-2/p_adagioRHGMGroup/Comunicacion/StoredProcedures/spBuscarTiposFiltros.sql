USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comunicacion].[spBuscarTiposFiltros]  
 as  
  if object_id('tempdb..#tempFiltros') is not null  
   drop table #tempFiltros;  
   
  create table #tempFiltros(  
   Filtro varchar(255)  
   ,DOMElementID varchar(255)  
  );  
  
	insert into #tempFiltros(filtro,DOMElementID)  
	select  'Empleados','divFiltrosEmpleados'  
  
	insert into #tempFiltros(filtro,DOMElementID)  
	select  'Excluir Empleados','divFiltrosEmpleados'  

	insert into #tempFiltros(filtro,DOMElementID)  
	select  'Departamentos','divFiltrosDepartamentos'  
  
	insert into #tempFiltros(filtro,DOMElementID)  
	select  'Sucursales','divFiltrosSucursales'  
  
	insert into #tempFiltros(filtro,DOMElementID)  
	select  'Puestos','divFiltrosPuestos'  
                              
    select *  
    from #tempFiltros
GO
