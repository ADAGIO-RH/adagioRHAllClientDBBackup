USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los usuarios registrados en la base de datos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2017-12-31
** Paremetros		:              

** DataTypes Relacionados: 
	[Seguridad].[dtUsuarios]

	Si se modifica el result set de este sp será necesario modificar los siguientes sp:
		[App].[INotificacionActivarCuenta]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-13		Aneudy Abreu		Se agregó el campo de Sexo a la tabla de usuarios los campos
									Nombre, Apellido y Sexo se toman de la tabla de Usuarios y ya
									no de la tabla de empleados
2023-10-25		Aneudy Abreu		Agrega parámetro de filtro @Email
***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spBuscarUsuario]
(
	@IDUsuario int = 0,
	@Email varchar(255) = null
)
AS
BEGIN
	select 
		u.IDUsuario
		,isnull(u.IDEmpleado,0) as IDEmpleado
		,coalesce(e.ClaveEmpleado,'') as ClaveEmpleado
		,u.Cuenta
		,null as [Password]
		,isnull(u.IDPreferencia,0) as IDPreferencia
		,u.Nombre
		,u.Apellido
		,NombreCompleto = coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')
		,coalesce(u.Sexo,'') as Sexo
		,u.Email
		,isnull(u.Activo,0) as Activo 
		,EsColaborador = case when isnull(u.IDEmpleado,0) <> 0 then cast(1 as bit) else cast(0 as bit) end
		,isnull(e.Vigente,cast(0 as bit)) as Vigente 
		,ISNULL(U.IDPerfil,0) as IDPerfil
		,P.Descripcion as Perfil
		,'' as [URL]
		,isnull(u.Supervisor,0) as Supervisor 
		,isnull(candidato.IDCandidato,0) as IDCandidato 
		,1 as TotalPaginas
	from Seguridad.tblUsuarios u with (nolock) 
		inner join Seguridad.tblCatPerfiles P with (nolock) on U.IDPerfil = P.IDPerfil
		left join [RH].[tblEmpleadosMaster] e with (nolock) on u.IDEmpleado = e.IDEmpleado
		left join Reclutamiento.tblCandidatos candidato on Candidato.IDEmpleado = e.IDEmpleado
	Where (u.IDUsuario = @IDUsuario OR @IDUsuario = 0) 
		and (u.Email = @Email or isnull(@Email, '') = '')
END
GO
