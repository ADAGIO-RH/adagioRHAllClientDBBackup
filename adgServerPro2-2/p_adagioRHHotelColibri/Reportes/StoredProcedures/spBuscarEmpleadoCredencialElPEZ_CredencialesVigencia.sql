USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarEmpleadoCredencialElPEZ_CredencialesVigencia] --20340      
(      
 @ClaveEmpleado varchar(20),
 @IDUsuario int = null    
)      
AS      
BEGIN     
SELECT  TOP 1       
      
   em.IDEmpleado        
  ,em.ClaveEmpleado        
  ,CASE WHEN LEN(em.NOMBRECOMPLETO) > 29 THEN ISNULL(em.Paterno,'') + ' ' + ISNULL(em.Nombre,'') ELSE em.NOMBRECOMPLETO end as NOMBRECOMPLETO        
  ,em.Nombre        
  ,em.SegundoNombre      
  ,ISNULL(em.Nombre,'') + ' ' + ISNULL(em.SegundoNombre,'') AS Nombres  
  ,em.Paterno        
  ,em.Materno  
  ,ISNULL(em.Paterno,'') + ' ' + ISNULL(em.Materno,'') AS Apellidos        
  ,em.Puesto        
  ,em.Departamento        
  ,em.Sucursal        
  ,em.IMSS      
  ,em.RFC      
  ,em.CURP     
  ,em.Empresa     
  ,FBE.NombreCompleto NombreEmergencia      
  ,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
  ,cg.Valor + em.ClaveEmpleado+'.jpg' as Foto    
  ,REPLACE(cg.Valor,'Empleados/','nofoto.jpg') as NoFoto  
  ,ISNULL(DE.Valor,'') AS VigenciaCredencial
FROM rh.tblEmpleadosMaster em  
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
		on EM.IDEmpleado = FEU.IDEmpleado
		and FEU.IDUsuario = @IDUsuario      
 left join RH.TblFamiliaresBenificiariosEmpleados FBE      
  on FBE.IDEmpleado = EM.IDEmpleado      
   and FBE.Emergencia = 1 
  left join RH.tblDatosExtraEmpleados DE on DE.IDEmpleado = em.IDEmpleado and DE.IDDatoExtra = 10
 Cross Apply App.tblConfiguracionesGenerales cg      
where EM.ClaveEmpleado = @ClaveEmpleado      
 and cg.IDConfiguracion = 'PathFotos'      
END
GO
