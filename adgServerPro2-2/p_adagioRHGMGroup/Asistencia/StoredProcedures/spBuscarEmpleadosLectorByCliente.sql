USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los lectores de los empleados por Cliente
** Autor			: Denzel Ovando
** Email			: denzel.ovando@adagio.com.mx
** FechaCreacion	: 2020-11-08
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spBuscarEmpleadosLectorByCliente]  (  
 @IDCliente int  
 ,@IDUsuario int = 1
)  
AS  
BEGIN  
	SELECT   
		le.IDLectorEmpleado  
		,em.IDEmpleado  
		,em.ClaveEmpleado  
		,em.NOMBRECOMPLETO  
		,em.Puesto  
		,em.Departamento  
		,em.Sucursal  
		,l.IDLector as IDLector  
		,l.Lector as Lector   
	FROM rh.tblEmpleadosMaster em with (nolock)
		inner join Asistencia.tblLectoresEmpleados le with (nolock) on em.IDEmpleado = le.IDEmpleado  
		inner join Asistencia.tblLectores l with (nolock) on le.IDLector = l.IDLector  
		inner join Rh.tblCatClientes cl with (nolock) on l.IDCliente = cl.IDCliente
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
	where l.IDCliente = @IDCliente
END;
GO
