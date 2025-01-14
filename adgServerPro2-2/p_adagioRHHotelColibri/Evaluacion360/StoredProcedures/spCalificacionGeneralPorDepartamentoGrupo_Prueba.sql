USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
----select * from Evaluacion360.tblEmpleadosProyectos where IDProyecto = 75
CREATE proc [Evaluacion360].[spCalificacionGeneralPorDepartamentoGrupo_Prueba] (
	@IDProyecto int, 
    @IDUsuario int
) as	

SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END


declare 
	@Privacidad bit = 1,
	@ID_TIPO_PROYECTO_CLIMA_LABORAL int = 3
	;


select @Privacidad= case when IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL then 1 else Privacidad end
from Evaluacion360.tblCatProyectos
where IDProyecto = @IDProyecto

if object_id('tempdb..#tempDummy') is not null 
    drop table #tempDummy;

 create table #tempDummy(
        IDProyecto int,
        Nombre varchar(max),
        Departamento VARCHAR(max),
        NombreGrupo varchar(max),
        Porcentaje DECIMAL(10,2)
        );

Insert into #tempDummy(IDProyecto,Nombre,Departamento,NombreGrupo,Porcentaje)
Select  
	IDProyecto,
	case when isnull(@Privacidad, 0) = 1 then 'ANÓMINO' else M.NOMBRECOMPLETO end,
	M.Departamento,catc.Nombre,catc.Porcentaje from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblCatPreguntas catp on catp.IDPregunta = resp.IDPregunta
Inner join Evaluacion360.tblCatGrupos catc on catc.IDGrupo = catp.IDGrupo
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
Where IDProyecto = @IDProyecto



insert into #tempDummy(IDProyecto,Nombre,Departamento,NombreGrupo,Porcentaje)
Select  IDProyecto,
	case when isnull(@Privacidad, 0) = 1 then 'ANÓMINO' else M.NOMBRECOMPLETO end,
	M.Departamento,OpcionRespuesta,(SUM(Valor) * 100) / (COUNT(VALOR) * NUM)  as PORCENTAJE  from Evaluacion360.tblRespuestasPreguntas resp
Inner join Evaluacion360.tblPosiblesRespuestasPreguntas pr on pr.idpregunta = resp.idpregunta  
Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto
Inner join rh.tblEmpleadosMaster M on M.IDEmpleado = ep.IDEmpleado
CROSS JOIN (SELECT MAX(VALOR) AS NUM from Evaluacion360.tblRespuestasPreguntas resp
            Inner join Evaluacion360.tblPosiblesRespuestasPreguntas pr on pr.idpregunta = resp.idpregunta  
            Inner join Evaluacion360.tblEvaluacionesEmpleados eve on eve.IDEvaluacionEmpleado = resp.IDEvaluacionEmpleado
            Inner join Evaluacion360.tblEmpleadosProyectos ep on  ep.IDEmpleadoProyecto = eve.IDEmpleadoProyecto WHERE IDPROYECTO = 18 ) AS CROS
where IDProyecto = @IDProyecto and creadoparaidtipopregunta = 10 
GROUP by IDproyecto,M.NOMBRECOMPLETO,M.DEPARTAMENTO,OPCIONRESPUESTA,NUM


Insert into #tempDummy(IDProyecto,Nombre,Departamento,NombreGrupo,Porcentaje)
Select 0,null,null,null, 100 - SUM(Porcentaje) / COUNT(Porcentaje) from #tempDummy


Select IDProyecto,SUM(Porcentaje)/COUNT(Porcentaje)as Total from #tempDummy
Group by IDProyecto

GO
